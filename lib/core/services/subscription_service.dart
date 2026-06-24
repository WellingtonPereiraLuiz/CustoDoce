import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:custo_doce/core/constants/app_constants.dart';

class SubscriptionService {
  static const String entitlementId = 'CustoDoce Pro';
  static const String publicAppleApiKey = AppConstants.revenueCatAppleApiKey;
  static const String publicGoogleApiKey = AppConstants.revenueCatAndroidApiKey;

  bool get hasValidApiKeyForCurrentPlatform {
    final apiKey = _apiKeyForCurrentPlatform;
    return apiKey.isNotEmpty && !apiKey.startsWith('YOUR_');
  }

  String? get configurationIssue {
    if (kIsWeb) return 'RevenueCat nao e usado na web.';
    if (hasValidApiKeyForCurrentPlatform) return null;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'RevenueCat Android nao configurado. Defina --dart-define=REVENUECAT_GOOGLE_API_KEY=...';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return 'RevenueCat Apple nao configurado. Defina --dart-define=REVENUECAT_APPLE_API_KEY=...';
      default:
        return 'Plataforma sem configuracao de assinatura.';
    }
  }

  Future<void> init() async {
    if (kIsWeb) {
      debugPrint('RevenueCat is not supported on web.');
      return;
    }

    await Purchases.setLogLevel(LogLevel.debug);

    final apiKey = _apiKeyForCurrentPlatform;
    if (!hasValidApiKeyForCurrentPlatform) {
      debugPrint('RevenueCat skipped: ${configurationIssue ?? 'missing API key'}');
      return;
    }

    PurchasesConfiguration? configuration;
    if (apiKey.isNotEmpty) {
      configuration = PurchasesConfiguration(apiKey);
    }

    if (configuration != null) {
      await Purchases.configure(configuration);
    }
  }

  Future<CustomerInfo?> getCustomerInfo() async {
    if (kIsWeb) return null;
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      debugPrint('Error fetching customer info: $e');
      return null;
    }
  }

  Future<bool> checkProStatus() async {
    if (kIsWeb) {
      // TODO: Integrate Stripe Webhooks for web subscriptions later.
      // Temporarily allowing pro access on web to bypass native paywalls.
      return true;
    }
    if (!hasValidApiKeyForCurrentPlatform) {
      return false;
    }
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final entitlement = customerInfo.entitlements.all[entitlementId];
      return entitlement != null && entitlement.isActive;
    } catch (e) {
      debugPrint('Error checking pro status: $e');
      return false;
    }
  }


  Future<bool> restorePurchases() async {
    if (kIsWeb) return false;
    if (!hasValidApiKeyForCurrentPlatform) return false;
    try {
      final customerInfo = await Purchases.restorePurchases();
      final entitlement = customerInfo.entitlements.all[entitlementId];
      return entitlement != null && entitlement.isActive;
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
      return false;
    }
  }

  Future<PaywallAvailability> getPaywallAvailability() async {
    if (kIsWeb) {
      return const PaywallAvailability.unavailable(
        'Pagamentos reais ficam disponiveis apenas no app mobile.',
      );
    }

    final issue = configurationIssue;
    if (issue != null) {
      return PaywallAvailability.unavailable(issue);
    }

    try {
      final offerings = await Purchases.getOfferings();
      final currentOffering = offerings.current;
      if (currentOffering == null) {
        return const PaywallAvailability.unavailable(
          'Nenhuma oferta ativa foi encontrada no RevenueCat.',
        );
      }
      if (currentOffering.availablePackages.isEmpty) {
        return const PaywallAvailability.unavailable(
          'A oferta atual nao possui pacotes disponiveis.',
        );
      }
      return const PaywallAvailability.available();
    } catch (e) {
      return PaywallAvailability.unavailable(
        'Nao foi possivel carregar os planos agora. Detalhe: $e',
      );
    }
  }

  String get _apiKeyForCurrentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return publicGoogleApiKey;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return publicAppleApiKey;
      default:
        return AppConstants.revenueCatApiKey;
    }
  }
}

class PaywallAvailability {
  final bool canShowNativePaywall;
  final String? reason;

  const PaywallAvailability._({
    required this.canShowNativePaywall,
    this.reason,
  });

  const PaywallAvailability.available()
      : this._(canShowNativePaywall: true);

  const PaywallAvailability.unavailable(String reason)
      : this._(canShowNativePaywall: false, reason: reason);
}

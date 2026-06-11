import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:custo_doce/core/services/subscription_service.dart';

final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return SubscriptionService();
});

class SubscriptionNotifier extends StateNotifier<bool> {
  final SubscriptionService _service;

  SubscriptionNotifier(this._service) : super(false) {
    _init();
  }

  Future<void> _init() async {
    if (kIsWeb) return;

    // Check initial status
    final isPro = await _service.checkProStatus();
    state = isPro;

    // Listen to updates
    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      final entitlement = customerInfo.entitlements.all[SubscriptionService.entitlementId];
      final isNowPro = entitlement != null && entitlement.isActive;
      if (state != isNowPro) {
        state = isNowPro;
      }
    });
  }

  Future<void> checkStatus() async {
    final isPro = await _service.checkProStatus();
    if (state != isPro) {
      state = isPro;
    }
  }

  Future<void> restorePurchases() async {
    final isPro = await _service.restorePurchases();
    if (state != isPro) {
      state = isPro;
    }
  }

  /// Somente para uso em web/demo — troca o estado manualmente
  void setProStatus(bool value) {
    if (kIsWeb) {
      state = value;
    }
  }
}

final subscriptionNotifierProvider =
    StateNotifierProvider<SubscriptionNotifier, bool>((ref) {
  final service = ref.watch(subscriptionServiceProvider);
  return SubscriptionNotifier(service);
});

// Alias to replace the old mock isProUserProvider
final isProUserProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionNotifierProvider);
});

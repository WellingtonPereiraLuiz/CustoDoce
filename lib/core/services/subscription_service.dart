import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionService {
  static const String entitlementId = 'CustoDoce Pro';
  static const String publicAppleApiKey = 'test_eTHPAxSRSphzYTUcuLXyYjMDtgo';
  static const String publicGoogleApiKey = 'YOUR_GOOGLE_API_KEY_HERE'; // Placeholder for Android

  Future<void> init() async {
    if (kIsWeb) {
      debugPrint('RevenueCat is not supported on web.');
      return;
    }

    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration? configuration;
    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(publicGoogleApiKey);
    } else if (Platform.isIOS || Platform.isMacOS) {
      configuration = PurchasesConfiguration(publicAppleApiKey);
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
    if (kIsWeb) return false;
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
    try {
      final customerInfo = await Purchases.restorePurchases();
      final entitlement = customerInfo.entitlements.all[entitlementId];
      return entitlement != null && entitlement.isActive;
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
      return false;
    }
  }
}

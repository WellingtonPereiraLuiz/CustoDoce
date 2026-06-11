import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:custo_doce/core/services/subscription_service.dart';
import 'package:custo_doce/core/models/subscription_plan.dart';

final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return SubscriptionService();
});

class SubscriptionNotifier extends StateNotifier<SubscriptionPlan> {
  final SubscriptionService _service;

  SubscriptionNotifier(this._service) : super(SubscriptionPlan.free) {
    _init();
  }

  Future<void> _init() async {
    if (kIsWeb) {
      // Em web começa como free; usuário troca pelo seletor de planos
      state = SubscriptionPlan.free;
      return;
    }

    final isPro = await _service.checkProStatus();
    state = isPro ? SubscriptionPlan.pro : SubscriptionPlan.free;

    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      final entitlement =
          customerInfo.entitlements.all[SubscriptionService.entitlementId];
      final isNowPro = entitlement != null && entitlement.isActive;
      final newPlan = isNowPro ? SubscriptionPlan.pro : SubscriptionPlan.free;
      if (state != newPlan) state = newPlan;
    });
  }

  Future<void> checkStatus() async {
    if (kIsWeb) return;
    final isPro = await _service.checkProStatus();
    final newPlan = isPro ? SubscriptionPlan.pro : SubscriptionPlan.free;
    if (state != newPlan) state = newPlan;
  }

  /// Somente web/demo — troca o plano manualmente para testes
  void setPlan(SubscriptionPlan plan) {
    if (kIsWeb) {
      state = plan;
    }
  }

  Future<void> restorePurchases() async {
    if (kIsWeb) return;
    final isPro = await _service.restorePurchases();
    final newPlan = isPro ? SubscriptionPlan.pro : SubscriptionPlan.free;
    if (state != newPlan) state = newPlan;
  }
}

final subscriptionNotifierProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionPlan>((ref) {
  final service = ref.watch(subscriptionServiceProvider);
  return SubscriptionNotifier(service);
});

/// Plano atual completo com limites
final currentPlanProvider = Provider<PlanLimits>((ref) {
  final plan = ref.watch(subscriptionNotifierProvider);
  return PlanLimits.forPlan(plan);
});

/// Compatibilidade: true se NÃO for free (qualquer plano pago)
final isProUserProvider = Provider<bool>((ref) {
  final plan = ref.watch(subscriptionNotifierProvider);
  return plan != SubscriptionPlan.free;
});

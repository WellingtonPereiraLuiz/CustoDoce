import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PlanGate {
  /// Retorna true se pode prosseguir. Se bloqueado, mostra dialog e retorna false.
  static bool checkLimit({
    required BuildContext context,
    required int currentCount,
    required int limit, // -1 = ilimitado
    required String featureName, // ex: "receitas"
    required String planName,
  }) {
    if (limit == -1) return true;
    if (currentCount < limit) return true;
    _showUpgradeDialog(context, featureName, limit, planName);
    return false;
  }

  /// Para features booleanas (relatórios, cardápio, etc)
  static bool checkFeature({
    required BuildContext context,
    required bool hasAccess,
    required String featureName,
    required String requiredPlan,
  }) {
    if (hasAccess) return true;
    _showFeatureDialog(context, featureName, requiredPlan);
    return false;
  }

  static void _showUpgradeDialog(
      BuildContext context, String feature, int limit, String planName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.lock_outline_rounded, size: 40),
        title: const Text('Limite atingido'),
        content: Text(
          'Seu plano $planName permite até $limit $feature.\n\n'
          'Faça upgrade para adicionar mais.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Agora não'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.push('/paywall');
            },
            child: const Text('Ver planos'),
          ),
        ],
      ),
    );
  }

  static void _showFeatureDialog(
      BuildContext context, String feature, String requiredPlan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.workspace_premium_rounded, size: 40),
        title: Text('Recurso $requiredPlan'),
        content: Text(
          '$feature está disponível no plano $requiredPlan.\n\n'
          'Faça upgrade para desbloquear.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Agora não'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.push('/paywall');
            },
            child: const Text('Ver planos'),
          ),
        ],
      ),
    );
  }
}

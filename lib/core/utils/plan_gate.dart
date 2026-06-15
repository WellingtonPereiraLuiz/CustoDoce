import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:custo_doce/core/providers/auth_provider.dart';
import 'package:custo_doce/core/providers/guest_mode_provider.dart';

class PlanGate {
  /// Retorna true se pode prosseguir. Se bloqueado, mostra dialog e retorna false.
  static bool checkLimit({
    required BuildContext context,
    required WidgetRef ref,
    required int currentCount,
    required int limit, // -1 = ilimitado
    required String featureName, // ex: "receitas"
    required String planName,
  }) {
    if (limit == -1) return true;
    if (currentCount < limit) return true;
    _showUpgradeDialog(context, ref, featureName, limit, planName);
    return false;
  }

  /// Para features booleanas (relatórios, cardápio, etc)
  static bool checkFeature({
    required BuildContext context,
    required WidgetRef ref,
    required bool hasAccess,
    required String featureName,
    required String requiredPlan,
  }) {
    if (hasAccess) return true;
    _showFeatureDialog(context, ref, featureName, requiredPlan);
    return false;
  }

  static void _showUpgradeDialog(
      BuildContext context, WidgetRef ref, String feature, int limit, String planName) {
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
              navigateToPaywall(context, ref);
            },
            child: const Text('Ver planos'),
          ),
        ],
      ),
    );
  }

  static void _showFeatureDialog(
      BuildContext context, WidgetRef ref, String feature, String requiredPlan) {
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
              navigateToPaywall(context, ref);
            },
            child: const Text('Ver planos'),
          ),
        ],
      ),
    );
  }

  static void navigateToPaywall(BuildContext context, WidgetRef ref) {
    final isGuest = ref.read(guestModeProvider);
    final user = ref.read(currentUserProvider);
    if (isGuest || user == null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Login necessário'),
          content: const Text(
            'Para assinar um plano, você precisa estar logado.\n'
            'Crie uma conta ou entre com sua conta Google.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/login', extra: {'redirect': '/paywall'});
              },
              child: const Text('Fazer login'),
            ),
          ],
        ),
      );
    } else {
      context.push('/paywall');
    }
  }
}


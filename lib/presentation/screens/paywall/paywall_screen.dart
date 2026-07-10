import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:custo_doce/core/providers/subscription_provider.dart';
import 'package:custo_doce/core/models/subscription_plan.dart';
import 'package:custo_doce/core/services/subscription_service.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const _WebPlanSelector();
    }
    final service = ref.watch(subscriptionServiceProvider);

    return FutureBuilder<PaywallAvailability>(
      future: service.getPaywallAvailability(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: SafeArea(
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final availability = snapshot.data!;
        if (!availability.canShowNativePaywall) {
          return _WebPlanSelector(
            headline: 'Planos indisponiveis no checkout nativo',
            helperText: availability.reason,
          );
        }

        return Scaffold(
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SafeArea(
                child: PaywallView(
                  onPurchaseCompleted: (customerInfo, storeTransaction) {
                    ref
                        .read(subscriptionNotifierProvider.notifier)
                        .checkStatus();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Bem-vindo ao CustoDoce Pro! 🚀')),
                      );
                      context.pop();
                    }
                  },
                  onRestoreCompleted: (customerInfo) {
                    ref
                        .read(subscriptionNotifierProvider.notifier)
                        .checkStatus();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Compras restauradas com sucesso.')),
                      );
                      context.pop();
                    }
                  },
                  onDismiss: () {
                    if (context.mounted) {
                      context.pop();
                    }
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WebPlanSelector extends ConsumerWidget {
  final String? headline;
  final String? helperText;

  const _WebPlanSelector({
    this.headline,
    this.helperText,
  });

  List<({String label, bool ok})> _featureRows(PlanLimits p) => [
        (
          label: p.isUnlimitedRecipes
              ? 'Receitas ilimitadas'
              : '${p.recipeLimit} receitas',
          ok: true,
        ),
        (
          label: p.isUnlimitedIngredients
              ? 'Ingredientes ilimitados'
              : '${p.ingredientLimit} ingredientes',
          ok: true,
        ),
        (label: 'Preço de venda personalizado', ok: p.hasCustomSellingPrice),
        (label: 'Backup em nuvem', ok: p.hasCloudBackup),
        (label: 'Cardápio digital', ok: p.hasDigitalMenu),
        (label: 'Exportar PDF', ok: p.hasExportPdf),
        (label: 'Assistente de IA', ok: p.hasChatAi),
      ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = colorScheme.secondaryContainer;
    final onAccent = colorScheme.onSecondaryContainer;
    final currentPlan = ref.watch(subscriptionNotifierProvider);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surface,
              colorScheme.surfaceContainerLow,
              colorScheme.surfaceContainer,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Header
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: Icon(Icons.close_rounded, color: accent),
                        onPressed: () => context.pop(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Icon(Icons.workspace_premium_rounded,
                        color: accent, size: 40),
                    const SizedBox(height: 12),
                    Text(
                      headline ?? 'Escolha seu plano',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 28,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      helperText ??
                          'Modo demonstração — pagamentos reais no app mobile.',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Plan cards
                    ...PlanLimits.all.map((plan) {
                      final isSelected = currentPlan == plan.plan;
                      final rows = _featureRows(plan);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? accent.withAlpha(isDark ? 20 : 12)
                                : Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest
                                    .withAlpha(isDark ? 200 : 180),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? accent
                                  : Theme.of(context)
                                      .colorScheme
                                      .outlineVariant,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Name + price + badge
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            plan.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineSmall
                                                ?.copyWith(
                                                  color: isSelected
                                                      ? accent
                                                      : Theme.of(context)
                                                          .colorScheme
                                                          .onSurface,
                                                ),
                                          ),
                                          Text(
                                            plan.priceLabel,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: accent,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          'ATUAL',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            color: onAccent,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Feature rows
                                ...rows.map((row) => Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Row(
                                        children: [
                                          Icon(
                                            row.ok
                                                ? Icons.check_rounded
                                                : Icons.close_rounded,
                                            size: 16,
                                            color: row.ok
                                                ? accent
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withAlpha(60),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            row.label,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: row.ok
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                      .withAlpha(80),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                const SizedBox(height: 16),

                                // Select button
                                SizedBox(
                                  width: double.infinity,
                                  child: isSelected
                                      ? OutlinedButton(
                                          onPressed: null,
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(color: accent),
                                            foregroundColor: accent,
                                          ),
                                          child: const Text('Plano atual'),
                                        )
                                      : ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: accent,
                                            foregroundColor: onAccent,
                                          ),
                                          onPressed: () {
                                            ref
                                                .read(
                                                    subscriptionNotifierProvider
                                                        .notifier)
                                                .setPlan(plan.plan);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    '✅ Plano ${plan.name} ativado!'),
                                                backgroundColor: Theme.of(
                                                        context)
                                                    .colorScheme
                                                    .secondaryContainer,
                                              ),
                                            );
                                            context.pop();
                                          },
                                          child: const Text('Assinar Agora'),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

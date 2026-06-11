import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:custo_doce/core/providers/subscription_provider.dart';
import 'package:custo_doce/core/models/subscription_plan.dart';
import 'package:custo_doce/core/theme/app_theme.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kIsWeb) {
      return const _WebPlanSelector();
    }
    return Scaffold(
      body: SafeArea(
        child: PaywallView(
          onPurchaseCompleted: (customerInfo, storeTransaction) {
            ref.read(subscriptionNotifierProvider.notifier).checkStatus();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bem-vindo ao CustoDoce Pro! 🚀')),
              );
              context.pop();
            }
          },
          onRestoreCompleted: (customerInfo) {
            ref.read(subscriptionNotifierProvider.notifier).checkStatus();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Compras restauradas com sucesso.')),
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
    );
  }
}

class _WebPlanSelector extends ConsumerWidget {
  const _WebPlanSelector();

  List<({String label, bool ok})> _featureRows(PlanLimits p) => [
        (
          label: p.isUnlimitedRecipes
              ? 'Receitas ilimitadas'
              : '${p.recipeLimit} receitas',
          ok: true
        ),
        (
          label: p.isUnlimitedIngredients
              ? 'Ingredientes ilimitados'
              : '${p.ingredientLimit} ingredientes',
          ok: true
        ),
        (
          label: p.equipmentLimit == 0
              ? 'Equipamentos'
              : (p.equipmentLimit == -1
                  ? 'Equipamentos ilimitados'
                  : '${p.equipmentLimit} equipamentos'),
          ok: p.equipmentLimit != 0
        ),
        (label: 'Relatórios e gráficos', ok: p.hasReports),
        (label: 'Cardápio digital', ok: p.hasDigitalMenu),
        (label: 'Backup em nuvem', ok: p.hasCloudBackup),
      ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppTheme.accentWarm : AppTheme.primaryColor;
    final onAccent = isDark ? AppTheme.primaryColor : Colors.white;
    final currentPlan = ref.watch(subscriptionNotifierProvider);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1E1B1A),
                    const Color(0xFF2C1A16),
                    const Color(0xFF1A1210),
                  ]
                : [
                    const Color(0xFFFFF8F6),
                    const Color(0xFFF5E6E0),
                    const Color(0xFFFAF0ED),
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
                      'Escolha seu plano',
                      style: GoogleFonts.sourceSerif4(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Modo demonstração — pagamentos reais no app mobile.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withAlpha(100),
                      ),
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
                                            style: GoogleFonts.sourceSerif4(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                              color: isSelected
                                                  ? accent
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .onSurface,
                                            ),
                                          ),
                                          Text(
                                            plan.priceLabel,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withAlpha(160),
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
                                      padding:
                                          const EdgeInsets.only(bottom: 6),
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
                                            side:
                                                BorderSide(color: accent),
                                            foregroundColor: accent,
                                          ),
                                          child: const Text('Plano atual'),
                                        )
                                      : ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: accent,
                                            foregroundColor: onAccent,
                                            textStyle: GoogleFonts.workSans(
                                              fontWeight: FontWeight.w700,
                                            ),
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
                                                backgroundColor:
                                                    AppTheme.successColor,
                                              ),
                                            );
                                            context.pop();
                                          },
                                          child: Text('Selecionar ${plan.name}'),
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

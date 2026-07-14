import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:custo_doce/core/providers/subscription_provider.dart';
import 'package:custo_doce/core/models/subscription_plan.dart';
import 'package:custo_doce/core/services/subscription_service.dart';
import 'package:custo_doce/core/constants/layout_constants.dart';

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

  void _selectPlan(BuildContext context, WidgetRef ref, PlanLimits plan) {
    ref.read(subscriptionNotifierProvider.notifier).setPlan(plan.plan);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Plano ${plan.name} ativado!'),
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentPlan = ref.watch(subscriptionNotifierProvider);
    final isDesktop = MediaQuery.of(context).size.width >= kDesktopBreakpoint;

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
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 32 : 24, vertical: 32),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth:
                        isDesktop ? kDesktopContentMaxWidth : 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Header
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: Icon(Icons.close_rounded,
                            color: colorScheme.secondaryContainer),
                        onPressed: () => context.pop(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      headline ?? 'Escolha o seu plano',
                      style: Theme.of(context).textTheme.displayLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      helperText ??
                          'Eleve o nível da sua produção artesanal com ferramentas de precisão.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Plan cards
                    if (isDesktop)
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final plan in PlanLimits.all)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8),
                                  child: _PlanCard(
                                    plan: plan,
                                    rows: _featureRows(plan),
                                    isSelected: currentPlan == plan.plan,
                                    isFeatured: plan.plan ==
                                        SubscriptionPlan.pro,
                                    onSelect: () =>
                                        _selectPlan(context, ref, plan),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      )
                    else
                      ...PlanLimits.all.map((plan) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _PlanCard(
                              plan: plan,
                              rows: _featureRows(plan),
                              isSelected: currentPlan == plan.plan,
                              isFeatured: plan.plan == SubscriptionPlan.pro,
                              onSelect: () => _selectPlan(context, ref, plan),
                            ),
                          )),
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

class _PlanCard extends StatelessWidget {
  final PlanLimits plan;
  final List<({String label, bool ok})> rows;
  final bool isSelected;
  final bool isFeatured;
  final VoidCallback onSelect;

  const _PlanCard({
    required this.plan,
    required this.rows,
    required this.isSelected,
    required this.isFeatured,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = colorScheme.secondaryContainer;
    final dark = isFeatured;
    final fg = dark ? colorScheme.onPrimary : colorScheme.onSurface;
    final fgMuted = dark
        ? colorScheme.onPrimary.withValues(alpha: 0.7)
        : colorScheme.onSurfaceVariant;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: dark
            ? colorScheme.primary
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? accent
              : (dark ? accent : colorScheme.outlineVariant),
          width: isSelected || dark ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(plan.name,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: fg)),
                ),
                if (isFeatured)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text('MAIS POPULAR',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSecondaryContainer)),
                  )
                else if (isSelected)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text('ATUAL',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSecondaryContainer)),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(plan.priceLabel,
                style: Theme.of(context)
                    .textTheme
                    .displayLarge
                    ?.copyWith(fontSize: 24, color: dark ? accent : fg)),
            const SizedBox(height: 20),
            ...rows.map((row) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        row.ok ? Icons.check_circle_rounded : Icons.close_rounded,
                        size: 16,
                        color: row.ok
                            ? (dark ? accent : colorScheme.primary)
                            : fgMuted.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(row.label,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: row.ok ? fg : fgMuted)),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
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
                        foregroundColor: colorScheme.onSecondaryContainer,
                      ),
                      onPressed: onSelect,
                      child: Text(
                          isFeatured ? 'Assinar Agora' : 'Selecionar'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

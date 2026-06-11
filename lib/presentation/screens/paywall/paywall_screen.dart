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
      final isAlreadyPro = ref.watch(isProUserProvider);
      return _WebProScreen(isAlreadyPro: isAlreadyPro);
    }
    return Scaffold(
      body: SafeArea(
        child: PaywallView(
          onPurchaseCompleted: (customerInfo, storeTransaction) {
            // Update provider state
            ref.read(subscriptionNotifierProvider.notifier).checkStatus();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bem-vindo ao CustoDoce Pro! 🚀')),
              );
              context.pop(); // Go back
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

class _WebProScreen extends ConsumerWidget {
  final bool isAlreadyPro;
  const _WebProScreen({required this.isAlreadyPro});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppTheme.accentWarm : AppTheme.primaryColor;
    final onAccent = isDark ? AppTheme.primaryColor : Colors.white;

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
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Botão voltar
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: Icon(Icons.close_rounded, color: accent),
                        onPressed: () => context.pop(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Ícone
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: accent.withAlpha(25),
                        shape: BoxShape.circle,
                        border: Border.all(color: accent.withAlpha(60), width: 2),
                      ),
                      child: Icon(Icons.workspace_premium_rounded, color: accent, size: 36),
                    ),
                    const SizedBox(height: 20),

                    // Título
                    Text(
                      'CustoDoce Pro',
                      style: GoogleFonts.sourceSerif4(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Desbloqueie o poder total da sua confeitaria',
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.onSurface.withAlpha(160),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Benefícios
                    _BenefitItem(icon: Icons.all_inclusive_rounded, accent: accent, text: 'Receitas ilimitadas'),
                    _BenefitItem(icon: Icons.bar_chart_rounded, accent: accent, text: 'Relatórios de custos avançados'),
                    _BenefitItem(icon: Icons.inventory_2_rounded, accent: accent, text: 'Ingredientes ilimitados'),
                    _BenefitItem(icon: Icons.sync_rounded, accent: accent, text: 'Sincronização em nuvem'),
                    _BenefitItem(icon: Icons.support_agent_rounded, accent: accent, text: 'Suporte prioritário'),
                    const SizedBox(height: 32),

                    // Card de preço
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: accent.withAlpha(isDark ? 20 : 15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: accent.withAlpha(80), width: 1.5),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'R\$ 9,90',
                            style: GoogleFonts.sourceSerif4(
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                              color: accent,
                            ),
                          ),
                          Text(
                            'por mês • cancele quando quiser',
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.onSurface.withAlpha(140),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Botão principal
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: onAccent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          textStyle: GoogleFonts.workSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onPressed: isAlreadyPro
                            ? null
                            : () {
                                ref
                                    .read(subscriptionNotifierProvider.notifier)
                                    .setPlan(SubscriptionPlan.pro);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('🎉 Bem-vindo ao CustoDoce Pro!'),
                                    backgroundColor: AppTheme.successColor,
                                  ),
                                );
                                context.pop();
                              },
                        child: Text(
                          isAlreadyPro ? 'Você já é Pro!' : 'Ativar Pro (Demo Web)',
                        ),
                      ),
                    ),

                    // Se já for pro, botão de reverter (para testes)
                    if (isAlreadyPro) ...[
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          ref
                              .read(subscriptionNotifierProvider.notifier)
                              .setPlan(SubscriptionPlan.free);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Plano revertido para Free.')),
                          );
                          context.pop();
                        },
                        child: Text(
                          'Reverter para Free (teste)',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withAlpha(120),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),
                    Text(
                      'Modo demonstração — pagamentos reais disponíveis no app mobile.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurface.withAlpha(80),
                      ),
                      textAlign: TextAlign.center,
                    ),
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

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final String text;

  const _BenefitItem({required this.icon, required this.accent, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accent, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Icon(Icons.check_rounded, color: accent, size: 18),
        ],
      ),
    );
  }
}

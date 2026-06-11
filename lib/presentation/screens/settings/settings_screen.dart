import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:custo_doce/core/l10n/app_strings.dart';
import 'package:custo_doce/core/providers/settings_provider.dart';
import 'package:custo_doce/core/theme/app_theme.dart';
import 'package:custo_doce/data/local/database/database_helper.dart';
import 'package:custo_doce/core/providers/subscription_provider.dart';
import 'package:custo_doce/core/models/subscription_plan.dart';
import 'package:custo_doce/core/utils/plan_gate.dart';
import 'package:custo_doce/presentation/providers/recipe_providers.dart';
import 'package:custo_doce/presentation/providers/ingredient_providers.dart';
import 'package:custo_doce/core/providers/auth_provider.dart' as custo_doce_auth;

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final currentPlan = ref.watch(currentPlanProvider);
    final isFree = currentPlan.plan == SubscriptionPlan.free;
    final s = AppStrings(Localizations.localeOf(context));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;
    final accent = isDark ? AppTheme.accentWarm : AppTheme.primaryColor;
    final onAccent = isDark ? AppTheme.primaryColor : Theme.of(context).colorScheme.onPrimary;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.settingsTitle),
        leading: const BackButton(),
      ),
      body: settingsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (settings) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Appearance ──────────────────────────────────────────
            _SectionHeader(title: s.appearance, icon: Icons.palette_outlined),
            const SizedBox(height: 12),
            _ThemeSelector(
              currentMode: settings.themeMode,
              s: s,
              onSelect: (mode) =>
                  ref.read(settingsProvider.notifier).setThemeMode(mode),
            ),
            const SizedBox(height: 24),

            // ── Language ────────────────────────────────────────────
            _SectionHeader(
                title: s.language, icon: Icons.language_rounded),
            const SizedBox(height: 12),
            _LanguageSelector(
              currentLocale: settings.locale,
              s: s,
              onSelect: (locale) =>
                  ref.read(settingsProvider.notifier).setLocale(locale),
            ),
            const SizedBox(height: 24),

            // ── Account ─────────────────────────────────────────────
            const _SectionHeader(title: 'Conta', icon: Icons.person_outline_rounded),
            const SizedBox(height: 12),
            if (isFree)
              _SettingsTile(
                icon: Icons.workspace_premium_rounded,
                iconColor: accent,
                title: s.upgradeToPro,
                subtitle: s.upgradeDescription,
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'LIGHT',
                    style: TextStyle(
                        color: onAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.w800),
                  ),
                ),
                onTap: () => context.push('/paywall'),
                cardBg: cardBg,
              )
            else
              _SettingsTile(
                icon: Icons.verified_rounded,
                iconColor: AppTheme.successColor,
                title: 'Plano ${currentPlan.name}',
                subtitle: 'Toque para gerenciar ou trocar de plano',
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.successColor.withAlpha(80)),
                  ),
                  child: Text(
                    currentPlan.name.toUpperCase(),
                    style: const TextStyle(
                        color: AppTheme.successColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w800),
                  ),
                ),
                onTap: () => context.push('/paywall'),
                cardBg: cardBg,
                titleColor: Theme.of(context).colorScheme.onSurface,
              ),
            const SizedBox(height: 12),
            // ── Features Pro/Premium (protegidas por gates) ─────────
            _SettingsTile(
              icon: Icons.bar_chart_rounded,
              iconColor: accent,
              title: 'Relatórios e Gráficos',
              subtitle: 'Análise de custos e margens',
              trailing: currentPlan.hasReports
                  ? Icon(Icons.chevron_right_rounded, color: accent)
                  : const Icon(Icons.lock_outline_rounded, size: 18, color: AppTheme.secondaryColor),
              onTap: () {
                PlanGate.checkFeature(
                  context: context,
                  hasAccess: currentPlan.hasReports,
                  featureName: 'Relatórios e gráficos',
                  requiredPlan: 'Pro',
                );
              },
              cardBg: cardBg,
            ),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.restaurant_menu_rounded,
              iconColor: accent,
              title: 'Cardápio Digital',
              subtitle: 'Link compartilhável com seus produtos',
              trailing: currentPlan.hasDigitalMenu
                  ? Icon(Icons.chevron_right_rounded, color: accent)
                  : const Icon(Icons.lock_outline_rounded, size: 18, color: AppTheme.secondaryColor),
              onTap: () {
                PlanGate.checkFeature(
                  context: context,
                  hasAccess: currentPlan.hasDigitalMenu,
                  featureName: 'Cardápio digital',
                  requiredPlan: 'Premium',
                );
              },
              cardBg: cardBg,
            ),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.cloud_sync_rounded,
              iconColor: accent,
              title: 'Backup em Nuvem',
              subtitle: 'Sincronize seus dados com segurança',
              trailing: currentPlan.hasCloudBackup
                  ? Icon(Icons.chevron_right_rounded, color: accent)
                  : const Icon(Icons.lock_outline_rounded, size: 18, color: AppTheme.secondaryColor),
              onTap: () {
                PlanGate.checkFeature(
                  context: context,
                  hasAccess: currentPlan.hasCloudBackup,
                  featureName: 'Backup em nuvem',
                  requiredPlan: 'Pro',
                );
              },
              cardBg: cardBg,
            ),
            const SizedBox(height: 24),

            // ── About ───────────────────────────────────────────────
            _SectionHeader(title: s.about, icon: Icons.info_outline_rounded),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.info_outline_rounded,
              iconColor: AppTheme.primaryColor,
              title: 'Sobre o CustoDoce',
              subtitle: 'Versão, como usar e informações',
              trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.primaryColor),
              onTap: () => _showAboutDialog(context, s),
              cardBg: cardBg,
              titleColor: Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(height: 24),

            // ── Data & Privacy ──────────────────────────────────────
            _SectionHeader(
                title: s.dataAndPrivacy, icon: Icons.security_rounded),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.delete_forever_rounded,
              iconColor: AppTheme.errorColor,
              title: s.clearAllData,
              subtitle: 'Apagar todas as receitas e ingredientes',
              trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.errorColor),
              onTap: () => _confirmClearData(context, ref, s),
              cardBg: cardBg,
              titleColor: AppTheme.errorColor,
            ),
            const SizedBox(height: 24),
            _SettingsTile(
              icon: Icons.logout_rounded,
              iconColor: AppTheme.errorColor,
              title: 'Sair da Conta',
              subtitle: 'Desconectar do aplicativo',
              trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.errorColor),
              onTap: () async {
                final auth = ref.read(custo_doce_auth.authServiceProvider);
                await auth.signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              },
              cardBg: cardBg,
              titleColor: AppTheme.errorColor,
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context, AppStrings s) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Image.asset('assets/images/CustoDoce.png', height: 40, errorBuilder: (_,__,___) => const Icon(Icons.cake)),
            const SizedBox(width: 12),
            const Text('CustoDoce'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Versão 1.0.0 (build 1)', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Text('O CustoDoce é a ferramenta definitiva para empreendedores da confeitaria.'),
              SizedBox(height: 16),
              Text('Como usar:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('1. Cadastre seus ingredientes na aba "Ingredientes", colocando o custo da embalagem fechada.'),
              SizedBox(height: 8),
              Text('2. Na tela de "Nova Receita", você seleciona o quanto de cada ingrediente usou. O app calcula a fração do custo perfeitamente!'),
              SizedBox(height: 8),
              Text('3. Use as barras de Custo Invisível e Margem de Lucro para descobrir por quanto vender seu doce.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClearData(
    BuildContext context,
    WidgetRef ref,
    AppStrings s,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.clearAllData),
        content: Text(s.clearAllDataConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.confirm),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await DatabaseHelper.instance.close();
      // Reinitialize DB (this drops all data by deleting the file, but here
      // we simply close + reopen which recreates if needed; for true clear
      // call the db delete method)
      final db = await DatabaseHelper.instance.database;
      await db.delete('recipe_ingredients');
      await db.delete('recipes');
      await db.delete('ingredients');
      // Refresh providers
      ref.invalidate(recipesProvider);
      ref.invalidate(ingredientsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Todos os dados foram apagados.'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.accentWarm : Theme.of(context).colorScheme.onSurface;

    return Row(
      children: [
        Icon(icon, color: isDark ? AppTheme.accentWarm : Theme.of(context).colorScheme.onSurface, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: textColor,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Divider()),
      ],
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  final ThemeMode currentMode;
  final AppStrings s;
  final void Function(ThemeMode) onSelect;

  const _ThemeSelector({
    required this.currentMode,
    required this.s,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _ThemeOption(
            icon: Icons.dark_mode_rounded,
            label: s.darkTheme,
            mode: ThemeMode.dark,
            currentMode: currentMode,
            onSelect: onSelect,
          ),
          _ThemeOption(
            icon: Icons.light_mode_rounded,
            label: s.lightTheme,
            mode: ThemeMode.light,
            currentMode: currentMode,
            onSelect: onSelect,
          ),
          _ThemeOption(
            icon: Icons.phone_android_rounded,
            label: s.systemTheme,
            mode: ThemeMode.system,
            currentMode: currentMode,
            onSelect: onSelect,
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final ThemeMode mode;
  final ThemeMode currentMode;
  final void Function(ThemeMode) onSelect;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.mode,
    required this.currentMode,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? (Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.accentWarm
                    : AppTheme.primaryColor)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected
                    ? (Theme.of(context).brightness == Brightness.dark
                        ? AppTheme.primaryColor
                        : Theme.of(context).colorScheme.onPrimary)
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w400,
                  color: isSelected
                      ? (Theme.of(context).brightness == Brightness.dark
                          ? AppTheme.primaryColor
                          : Theme.of(context).colorScheme.onPrimary)
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  final Locale currentLocale;
  final AppStrings s;
  final void Function(Locale) onSelect;

  const _LanguageSelector({
    required this.currentLocale,
    required this.s,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _LanguageTile(
          emoji: '🇧🇷',
          label: s.portuguese,
          locale: const Locale('pt', 'BR'),
          currentLocale: currentLocale,
          onSelect: onSelect,
          cardBg: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        const SizedBox(height: 8),
        _LanguageTile(
          emoji: '🇺🇸',
          label: s.english,
          locale: const Locale('en', 'US'),
          currentLocale: currentLocale,
          onSelect: onSelect,
          cardBg: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      ],
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String emoji;
  final String label;
  final Locale locale;
  final Locale currentLocale;
  final void Function(Locale) onSelect;
  final Color cardBg;

  const _LanguageTile({
    required this.emoji,
    required this.label,
    required this.locale,
    required this.currentLocale,
    required this.onSelect,
    required this.cardBg,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentLocale.languageCode == locale.languageCode;
    final accent = Theme.of(context).brightness == Brightness.dark
        ? AppTheme.accentWarm
        : AppTheme.primaryColor;
    return GestureDetector(
      onTap: () => onSelect(locale),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? accent.withAlpha(25) : cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? accent : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w400,
                  color: isSelected ? accent : null,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded,
                  color: accent, size: 20),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color cardBg;
  final Color? titleColor;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    required this.cardBg,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: cardBg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                            fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7)),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

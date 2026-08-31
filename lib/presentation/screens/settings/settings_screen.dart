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
import 'package:custo_doce/core/providers/auth_provider.dart'
    as custo_doce_auth;
import 'package:custo_doce/core/providers/guest_mode_provider.dart';
import 'package:custo_doce/core/constants/layout_constants.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = MediaQuery.of(context).size.width >= kDesktopBreakpoint;
    if (isDesktop) return const _DesktopSettingsBody();

    final settingsAsync = ref.watch(settingsProvider);
    final currentPlan = ref.watch(currentPlanProvider);
    final isFree = currentPlan.plan == SubscriptionPlan.free;
    final s = AppStrings(Localizations.localeOf(context));

    return Scaffold(
      appBar: AppBar(
        title: Text(s.settingsTitle),
        leading: const BackButton(),
      ),
      body: Center(
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: settingsAsync.when(
                loading: () => Center(
                  child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary),
                ),
                error: (e, _) => Center(child: Text('Erro: $e')),
                data: (settings) {
                  final isGuest = ref.watch(guestModeProvider);
                  final user = ref.watch(custo_doce_auth.currentUserProvider);
                  final displayName = (user?.displayName?.trim().isNotEmpty ?? false)
                      ? user!.displayName!.trim()
                      : (isGuest ? 'Visitante' : 'Chef');
                  final email = user?.email ?? (isGuest ? 'Sem login' : 'chef@email.com');

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    children: [
                      if (isGuest)
                        Card(
                          color: Theme.of(context).colorScheme.errorContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  'Você está usando sem login. Faça login para sincronizar seus dados.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Theme.of(context).colorScheme.onErrorContainer),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    ref.read(guestModeProvider.notifier).state = false;
                                    context.go('/login');
                                  },
                                  child: const Text('Fazer login'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (isGuest) const SizedBox(height: 24),
                      // User Profile Snapshot
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).colorScheme.surfaceContainer,
                                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                              ),
                              child: Center(
                                child: Icon(Icons.person, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(displayName, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(email, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(isFree ? 'Plano Light' : 'Plano ${currentPlan.name}', style: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Settings Groups
                      _V2SettingsGroup(
                        title: 'Perfil',
                        children: [
                          _V2SettingsTile(
                            icon: Icons.person,
                            title: 'Informações Pessoais',
                            onTap: () => context.push('/settings/personal-info'),
                          ),
                          _V2SettingsTile(
                            icon: Icons.payments,
                            title: 'Assinatura e Pagamento',
                            onTap: () => PlanGate.navigateToPaywall(context, ref),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _V2SettingsGroup(
                        title: 'Preferências do App',
                        children: [
                          _V2SettingsTile(
                            icon: Icons.dark_mode,
                            title: 'Tema',
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(settings.themeMode == ThemeMode.light ? 'Claro' : (settings.themeMode == ThemeMode.dark ? 'Escuro' : 'Sistema')),
                                const Icon(Icons.chevron_right, size: 20),
                              ],
                            ),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Escolher Tema'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        title: const Text('Sistema'),
                                        onTap: () {
                                          ref.read(settingsProvider.notifier).setThemeMode(ThemeMode.system);
                                          Navigator.pop(context);
                                        },
                                      ),
                                      ListTile(
                                        title: const Text('Claro'),
                                        onTap: () {
                                          ref.read(settingsProvider.notifier).setThemeMode(ThemeMode.light);
                                          Navigator.pop(context);
                                        },
                                      ),
                                      ListTile(
                                        title: const Text('Escuro'),
                                        onTap: () {
                                          ref.read(settingsProvider.notifier).setThemeMode(ThemeMode.dark);
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _V2SettingsGroup(
                        title: 'Segurança',
                        children: [
                          _V2SettingsTile(
                            icon: Icons.lock,
                            title: 'Alterar Senha',
                            onTap: () => context.push('/settings/change-password'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _V2SettingsGroup(
                        title: 'Suporte',
                        children: [
                          _V2SettingsTile(
                            icon: Icons.help_center,
                            title: 'Central de Ajuda',
                            onTap: () => showHelpCenterDialog(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final auth = ref.read(custo_doce_auth.authServiceProvider);
                          await auth.signOut();
                          if (context.mounted) {
                            context.go('/login');
                          }
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Sair da Conta'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                          side: BorderSide(color: Theme.of(context).colorScheme.error),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 48),
                    ],
                  );
                },
              ))),
    );
  }
}

class _V2SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;
  
  const _V2SettingsGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
              border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
            ),
            child: Text(title.toUpperCase(), style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          ...children.asMap().entries.map((e) {
            final idx = e.key;
            final widget = e.value;
            return Column(
              children: [
                widget,
                if (idx < children.length - 1)
                  Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _V2SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;

  const _V2SettingsTile({required this.icon, required this.title, this.trailing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: Theme.of(context).textTheme.bodyMedium)),
            if (trailing != null) trailing! else Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.outline),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Desktop — segue o padrão das demais telas (header displayLarge + subtítulo,
// conteúdo em `kDesktopContentMaxWidth`, layout de 2 colunas com cards de
// `surfaceContainerLowest` e borda `outlineVariant`).
// ═══════════════════════════════════════════════════════════════════════════

class _DesktopSettingsBody extends ConsumerWidget {
  const _DesktopSettingsBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppStrings(Localizations.localeOf(context));
    final colorScheme = Theme.of(context).colorScheme;
    final settingsAsync = ref.watch(settingsProvider);
    final currentPlan = ref.watch(currentPlanProvider);
    final isFree = currentPlan.plan == SubscriptionPlan.free;
    final isGuest = ref.watch(guestModeProvider);
    final user = ref.watch(custo_doce_auth.currentUserProvider);

    final displayName = (user?.displayName?.trim().isNotEmpty ?? false)
        ? user!.displayName!.trim()
        : (isGuest ? 'Visitante' : 'Chef');
    final email = user?.email ?? (isGuest ? 'Sem login' : '');
    final initials = _initialsFrom(displayName, email);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: settingsAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        ),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (settings) => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: kDesktopContentMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.settingsTitle,
                      style: Theme.of(context).textTheme.displayLarge),
                  const SizedBox(height: 8),
                  Text(
                    'Gerencie sua conta, as preferências de aparência e os dados do aplicativo.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 24),
                  if (isGuest) ...[
                    _GuestBanner(onLogin: () {
                      ref.read(guestModeProvider.notifier).state = false;
                      context.go('/login');
                    }),
                    const SizedBox(height: 24),
                  ],
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 300,
                        child: Column(
                          children: [
                            _AccountCard(
                              name: displayName,
                              email: email,
                              initials: initials,
                              plan: currentPlan,
                              onManagePlan: () =>
                                  PlanGate.navigateToPaywall(context, ref),
                            ),
                            const SizedBox(height: 16),
                            _AppearanceCard(
                              title: s.appearance,
                              child: _ThemeSelector(
                                currentMode: settings.themeMode,
                                s: s,
                                onSelect: (mode) => ref
                                    .read(settingsProvider.notifier)
                                    .setThemeMode(mode),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final auth = ref.read(
                                      custo_doce_auth.authServiceProvider);
                                  await auth.signOut();
                                  if (context.mounted) context.go('/login');
                                },
                                icon: const Icon(Icons.logout_rounded,
                                    size: 16),
                                label: const Text('Sair da conta'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.errorColor,
                                  side: BorderSide(
                                      color: AppTheme.errorColor
                                          .withAlpha(90)),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          children: [
                            _SettingsGroupCard(
                              title: 'Conta',
                              icon: Icons.person_outline_rounded,
                              rows: [
                                _DesktopSettingsRow(
                                  icon: Icons.badge_outlined,
                                  title: 'Informações Pessoais',
                                  subtitle: 'Nome, sobrenome e email',
                                  onTap: () => context
                                      .push('/settings/personal-info'),
                                ),
                                _DesktopSettingsRow(
                                  icon: Icons.lock_outline_rounded,
                                  title: 'Alterar Senha',
                                  subtitle: 'Atualize sua senha de acesso',
                                  onTap: () => context
                                      .push('/settings/change-password'),
                                ),
                                if (isFree)
                                  _DesktopSettingsRow(
                                    icon: Icons.workspace_premium_rounded,
                                    title: s.upgradeToPro,
                                    subtitle: s.upgradeDescription,
                                    trailing: const _PlanTag(
                                      label: 'LIGHT',
                                      filled: true,
                                    ),
                                    onTap: () => PlanGate.navigateToPaywall(
                                        context, ref),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _SettingsGroupCard(
                              title: 'Recursos',
                              icon: Icons.auto_awesome_rounded,
                              rows: [
                                _DesktopSettingsRow(
                                  icon: Icons.restaurant_menu_rounded,
                                  title: 'Cardápio Digital',
                                  subtitle:
                                      'Link compartilhável com seus produtos',
                                  locked: !currentPlan.hasDigitalMenu,
                                  onTap: () {
                                    if (PlanGate.checkFeature(
                                      context: context,
                                      ref: ref,
                                      hasAccess: currentPlan.hasDigitalMenu,
                                      featureName: 'Cardápio digital',
                                      requiredPlan: 'Pro',
                                    )) {
                                      context.push('/menu');
                                    }
                                  },
                                ),
                                _DesktopSettingsRow(
                                  icon: Icons.cloud_sync_rounded,
                                  title: 'Backup em Nuvem',
                                  subtitle:
                                      'Sincronize seus dados com segurança',
                                  locked: !currentPlan.hasCloudBackup,
                                  onTap: () {
                                    PlanGate.checkFeature(
                                      context: context,
                                      ref: ref,
                                      hasAccess: currentPlan.hasCloudBackup,
                                      featureName: 'Backup em nuvem',
                                      requiredPlan: 'Pro',
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _SettingsGroupCard(
                              title: s.about,
                              icon: Icons.info_outline_rounded,
                              rows: [
                                _DesktopSettingsRow(
                                  icon: Icons.info_outline_rounded,
                                  title: 'Sobre o CustoDoce',
                                  subtitle:
                                      'Versão, como usar e informações',
                                  onTap: () => showAppAboutDialog(context, s),
                                ),
                                _DesktopSettingsRow(
                                  icon: Icons.help_outline_rounded,
                                  title: 'Central de Ajuda',
                                  subtitle: 'Perguntas frequentes e suporte',
                                  onTap: () => showHelpCenterDialog(context),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _SettingsGroupCard(
                              title: s.dataAndPrivacy,
                              icon: Icons.security_rounded,
                              rows: [
                                _DesktopSettingsRow(
                                  icon: Icons.delete_forever_rounded,
                                  title: s.clearAllData,
                                  subtitle:
                                      'Apagar todas as receitas e ingredientes',
                                  danger: true,
                                  onTap: () =>
                                      confirmClearData(context, ref, s),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _initialsFrom(String name, String email) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return (parts.first[0] + parts[1][0]).toUpperCase();
    }
    if (parts.length == 1 && parts.first.isNotEmpty) {
      return parts.first[0].toUpperCase();
    }
    if (email.isNotEmpty) return email[0].toUpperCase();
    return '?';
  }
}

class _GuestBanner extends StatelessWidget {
  final VoidCallback onLogin;

  const _GuestBanner({required this.onLogin});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              color: colorScheme.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Você está usando sem login. Faça login para sincronizar seus dados.',
              style: TextStyle(color: colorScheme.onErrorContainer),
            ),
          ),
          const SizedBox(width: 16),
          FilledButton(
            onPressed: onLogin,
            child: const Text('Fazer login'),
          ),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final String name;
  final String email;
  final String initials;
  final PlanLimits plan;
  final VoidCallback onManagePlan;

  const _AccountCard({
    required this.name,
    required this.email,
    required this.initials,
    required this.plan,
    required this.onManagePlan,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isFree = plan.plan == SubscriptionPlan.free;
    final planColor = isFree ? colorScheme.primary : AppTheme.successColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: colorScheme.primary,
                child: Text(
                  initials,
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    if (email.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: planColor.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: planColor.withAlpha(60)),
            ),
            child: Row(
              children: [
                Icon(
                  isFree
                      ? Icons.workspace_premium_outlined
                      : Icons.verified_rounded,
                  size: 20,
                  color: planColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Plano ${plan.name}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      Text(
                        isFree ? 'Plano gratuito' : 'Assinatura ativa',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onManagePlan,
              icon: Icon(
                  isFree ? Icons.upgrade_rounded : Icons.tune_rounded,
                  size: 16),
              label: Text(isFree ? 'Fazer upgrade' : 'Gerenciar plano'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppearanceCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _AppearanceCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.palette_outlined,
                  size: 18, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _SettingsGroupCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> rows;

  const _SettingsGroupCard({
    required this.title,
    required this.icon,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 4),
          for (var i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i < rows.length - 1)
              Divider(height: 1, color: colorScheme.outlineVariant),
          ],
        ],
      ),
    );
  }
}

class _DesktopSettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool locked;
  final bool danger;

  const _DesktopSettingsRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.locked = false,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = danger
        ? AppTheme.errorColor
        : (isDark ? AppTheme.accentWarm : colorScheme.primary);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accent.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accent, size: 19),
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
                        color: danger
                            ? AppTheme.errorColor
                            : colorScheme.onSurface,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ],
                ),
              ),
              trailing ??
                  Icon(
                    locked
                        ? Icons.lock_outline_rounded
                        : Icons.chevron_right_rounded,
                    size: locked ? 18 : 22,
                    color: locked
                        ? AppTheme.secondaryColor
                        : (danger ? AppTheme.errorColor : accent),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanTag extends StatelessWidget {
  final String label;
  final bool filled;

  const _PlanTag({required this.label, this.filled = false});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppTheme.accentWarm : colorScheme.primary;
    final onAccent =
        isDark ? colorScheme.primary : colorScheme.onPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: filled ? accent : accent.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
        border: filled ? null : Border.all(color: accent.withAlpha(80)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: filled ? onAccent : accent,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Diálogos e ações compartilhados entre mobile e desktop
// ═══════════════════════════════════════════════════════════════════════════

void showAppAboutDialog(BuildContext context, AppStrings s) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Row(
        children: [
          Image.asset('assets/images/CustoDoce.png',
              height: 40,
              errorBuilder: (_, __, ___) => const Icon(Icons.cake)),
          const SizedBox(width: 12),
          const Text('CustoDoce'),
        ],
      ),
      content: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Versão 1.0.0 (build 1)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text(
                'O CustoDoce é a ferramenta definitiva para empreendedores da confeitaria.'),
            SizedBox(height: 16),
            Text('Como usar:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(
                '1. Cadastre seus ingredientes na aba "Ingredientes", colocando o custo da embalagem fechada.'),
            SizedBox(height: 8),
            Text(
                '2. Na tela de "Nova Receita", você seleciona o quanto de cada ingrediente usou. O app calcula a fração do custo perfeitamente!'),
            SizedBox(height: 8),
            Text(
                '3. Use as barras de Custo Invisível e Margem de Lucro para descobrir por quanto vender seu doce.'),
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

void showHelpCenterDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Central de Ajuda'),
      content: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Perguntas frequentes',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text('Como calculo o preço de venda de uma receita?',
                style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 4),
            Text(
                'Cadastre os ingredientes com o custo da embalagem, monte a receita informando as quantidades usadas e ajuste a margem de lucro — o CustoDoce calcula o preço sugerido automaticamente.'),
            SizedBox(height: 12),
            Text('Meus dados ficam salvos no aparelho?',
                style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 4),
            Text(
                'Sim, os dados ficam armazenados localmente. Faça login para poder recuperá-los caso troque de aparelho.'),
            SizedBox(height: 12),
            Text('Como falo com o suporte?',
                style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 4),
            Text('Envie um email para suporte@custodoce.app.'),
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

Future<void> confirmClearData(
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
                    : Theme.of(context).colorScheme.primary)
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
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onPrimary)
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  color: isSelected
                      ? (Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).colorScheme.primary
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


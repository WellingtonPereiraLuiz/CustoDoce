import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:custo_doce/core/providers/auth_provider.dart';
import 'package:custo_doce/core/providers/guest_mode_provider.dart';

/// Sidebar fixa exibida em telas largas (>= 1024px), alinhada ao layout
/// desktop do pacote de referência Stitch v2 (fundo escuro `primary`,
/// navegação Painel/Minhas Receitas/Ingredientes/Configurações).
class DesktopSidebarDestination {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const DesktopSidebarDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

class DesktopSidebar extends ConsumerWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<DesktopSidebarDestination> destinations;

  const DesktopSidebar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  String _userLabel(WidgetRef ref) {
    final isGuest = ref.watch(guestModeProvider);
    if (isGuest) return 'Modo visitante';
    final user = ref.watch(currentUserProvider);
    if (user?.displayName?.isNotEmpty == true) return user!.displayName!;
    if (user?.email?.isNotEmpty == true) return user!.email!;
    return 'Confeiteiro(a)';
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final router = GoRouter.of(context);
    await ref.read(authServiceProvider).signOut();
    ref.read(guestModeProvider.notifier).state = false;
    router.go('/login');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 280,
      color: colorScheme.primary,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Icon(Icons.bakery_dining_rounded,
                    color: colorScheme.secondaryContainer, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'CustoDoce',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(color: colorScheme.onPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              _userLabel(ref),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimary.withValues(alpha: 0.6),
                  ),
            ),
          ),
          const SizedBox(height: 28),
          for (var i = 0; i < destinations.length; i++)
            _SidebarItem(
              destination: destinations[i],
              selected: i == selectedIndex,
              onTap: () => onDestinationSelected(i),
            ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/ingredients'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.secondaryContainer,
                foregroundColor: colorScheme.onSecondaryContainer,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Novo Ingrediente'),
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: colorScheme.onPrimary.withValues(alpha: 0.15)),
          const SizedBox(height: 8),
          _SidebarFooterButton(
            icon: Icons.help_outline_rounded,
            label: 'Ajuda',
            onTap: () => context.push('/settings'),
          ),
          _SidebarFooterButton(
            icon: Icons.logout_rounded,
            label: 'Sair',
            color: colorScheme.errorContainer,
            onTap: () => _handleLogout(context, ref),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final DesktopSidebarDestination destination;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected
            ? colorScheme.onPrimary.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(
                  selected ? destination.selectedIcon : destination.icon,
                  size: 20,
                  color: selected
                      ? colorScheme.onPrimary
                      : colorScheme.onPrimary.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 12),
                Text(
                  destination.label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: selected
                            ? colorScheme.onPrimary
                            : colorScheme.onPrimary.withValues(alpha: 0.7),
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w400,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarFooterButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _SidebarFooterButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveColor = color ?? colorScheme.onPrimary.withValues(alpha: 0.7);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 18, color: effectiveColor),
              const SizedBox(width: 12),
              Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: effectiveColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

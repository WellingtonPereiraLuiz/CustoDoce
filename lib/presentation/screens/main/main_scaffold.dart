import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:custo_doce/core/providers/auth_provider.dart';
import 'package:custo_doce/core/providers/guest_mode_provider.dart';
import 'package:custo_doce/presentation/widgets/desktop_sidebar.dart';
import 'package:custo_doce/presentation/widgets/desktop_topbar.dart';
import 'package:custo_doce/core/constants/layout_constants.dart';

class MainScaffold extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({
    super.key,
    required this.navigationShell,
  });

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  Widget _buildAccountIcon(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isGuest = ref.watch(guestModeProvider);

    if (isGuest) {
      return const Badge(
        label: Text('V'),
        child: Icon(Icons.person_outline),
      );
    } else if (user != null) {
      if (user.photoURL != null) {
        return CircleAvatar(
          radius: 12,
          backgroundImage: NetworkImage(user.photoURL!),
        );
      } else {
        return CircleAvatar(
          radius: 12,
          child: Text(
            user.displayName?.isNotEmpty == true
                ? user.displayName![0].toUpperCase()
                : (user.email?.isNotEmpty == true
                    ? user.email![0].toUpperCase()
                    : '?'),
            style: const TextStyle(fontSize: 10),
          ),
        );
      }
    }
    return const Icon(Icons.person_outline);
  }

  Widget _buildAccountSelectedIcon(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isGuest = ref.watch(guestModeProvider);

    if (isGuest) {
      return Badge(
        label: const Text('V'),
        child: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
      );
    } else if (user != null) {
      if (user.photoURL != null) {
        return CircleAvatar(
          radius: 14,
          backgroundImage: NetworkImage(user.photoURL!),
        );
      } else {
        return CircleAvatar(
          radius: 14,
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          child: Text(
            user.displayName?.isNotEmpty == true
                ? user.displayName![0].toUpperCase()
                : (user.email?.isNotEmpty == true
                    ? user.email![0].toUpperCase()
                    : '?'),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        );
      }
    }
    return Icon(Icons.person, color: Theme.of(context).colorScheme.primary);
  }

  static const _searchHints = [
    'Buscar receitas...',
    'Buscar receitas...',
    'Buscar ingredientes...',
    'Buscar...',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = MediaQuery.of(context).size.width >= kDesktopBreakpoint;

    final destinations = [
      (
        icon: const Icon(Icons.home_outlined),
        selectedIcon:
            Icon(Icons.home, color: Theme.of(context).colorScheme.primary),
        label: 'Início',
      ),
      (
        icon: const Icon(Icons.menu_book_outlined),
        selectedIcon:
            Icon(Icons.menu_book, color: Theme.of(context).colorScheme.primary),
        label: 'Receitas',
      ),
      (
        icon: const Icon(Icons.egg_outlined),
        selectedIcon:
            Icon(Icons.egg, color: Theme.of(context).colorScheme.primary),
        label: 'Ingredientes',
      ),
      (
        icon: _buildAccountIcon(context, ref),
        selectedIcon: _buildAccountSelectedIcon(context, ref),
        label: 'Conta',
      ),
    ];

    if (isDesktop) {
      const sidebarDestinations = [
        DesktopSidebarDestination(
          icon: Icons.dashboard_outlined,
          selectedIcon: Icons.dashboard_rounded,
          label: 'Painel',
        ),
        DesktopSidebarDestination(
          icon: Icons.menu_book_outlined,
          selectedIcon: Icons.menu_book_rounded,
          label: 'Minhas Receitas',
        ),
        DesktopSidebarDestination(
          icon: Icons.inventory_2_outlined,
          selectedIcon: Icons.inventory_2_rounded,
          label: 'Ingredientes',
        ),
        DesktopSidebarDestination(
          icon: Icons.settings_outlined,
          selectedIcon: Icons.settings_rounded,
          label: 'Configurações',
        ),
      ];

      return Scaffold(
        body: Row(
          children: [
            DesktopSidebar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _goBranch,
              destinations: sidebarDestinations,
            ),
            Expanded(
              child: Column(
                children: [
                  DesktopTopBar(
                    searchHint: _searchHints[navigationShell.currentIndex],
                  ),
                  const Divider(height: 1),
                  Expanded(child: navigationShell),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _goBranch,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        indicatorColor:
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        destinations: destinations
            .map((d) => NavigationDestination(
                  icon: d.icon,
                  selectedIcon: d.selectedIcon,
                  label: d.label,
                ))
            .toList(),
      ),
    );
  }
}

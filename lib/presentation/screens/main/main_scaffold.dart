import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:custo_doce/core/providers/auth_provider.dart';
import 'package:custo_doce/core/providers/guest_mode_provider.dart';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.of(context).size.width > 600;

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

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _goBranch,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              indicatorColor:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
              labelType: NavigationRailLabelType.all,
              destinations: destinations
                  .map((d) => NavigationRailDestination(
                        icon: d.icon,
                        selectedIcon: d.selectedIcon,
                        label: Text(d.label),
                      ))
                  .toList(),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: navigationShell),
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

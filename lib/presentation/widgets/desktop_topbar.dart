import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:custo_doce/core/providers/auth_provider.dart';
import 'package:custo_doce/core/providers/guest_mode_provider.dart';

/// Barra superior compartilhada pelas telas do shell desktop
/// (busca decorativa + "Criar Receita" + notificações + ajuda + avatar),
/// conforme o topbar recorrente nas referências desktop do Stitch v2.
class DesktopTopBar extends ConsumerWidget implements PreferredSizeWidget {
  final String searchHint;

  const DesktopTopBar({super.key, this.searchHint = 'Buscar...'});

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: preferredSize.height,
      color: colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: TextField(
                decoration: InputDecoration(
                  hintText: searchHint,
                  prefixIcon: const Icon(Icons.search, size: 20),
                  isDense: true,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: () => context.push('/recipe-builder'),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Criar Receita'),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Notificações',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Nenhuma notificação nova.')),
              );
            },
            icon: const Icon(Icons.notifications_outlined),
          ),
          IconButton(
            tooltip: 'Ajuda',
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.help_outline_rounded),
          ),
          const SizedBox(width: 8),
          _TopBarAvatar(onTap: () => context.push('/settings')),
        ],
      ),
    );
  }
}

class _TopBarAvatar extends ConsumerWidget {
  final VoidCallback onTap;

  const _TopBarAvatar({required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isGuest = ref.watch(guestModeProvider);
    final colorScheme = Theme.of(context).colorScheme;

    Widget avatar;
    if (isGuest) {
      avatar = const CircleAvatar(radius: 18, child: Icon(Icons.person_outline, size: 18));
    } else if (user?.photoURL != null) {
      avatar = CircleAvatar(radius: 18, backgroundImage: NetworkImage(user!.photoURL!));
    } else {
      final initial = user?.displayName?.isNotEmpty == true
          ? user!.displayName![0].toUpperCase()
          : (user?.email?.isNotEmpty == true
              ? user!.email![0].toUpperCase()
              : '?');
      avatar = CircleAvatar(
        radius: 18,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        child: Text(initial, style: const TextStyle(fontWeight: FontWeight.bold)),
      );
    }

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Padding(padding: const EdgeInsets.all(4), child: avatar),
    );
  }
}

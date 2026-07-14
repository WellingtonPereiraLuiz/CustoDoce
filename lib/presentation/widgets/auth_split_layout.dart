import 'package:flutter/material.dart';
import 'package:custo_doce/core/constants/layout_constants.dart';

/// Layout compartilhado por Login/Cadastro: em telas desktop replica o
/// split-screen de `login_custodoce_v2`/`cadastro_custodoce_v2` (painel
/// escuro com a marca à esquerda + formulário à direita); em telas
/// estreitas mantém o formulário centralizado, como hoje.
class AuthSplitLayout extends StatelessWidget {
  final String headline;
  final String subtitle;
  final Widget formChild;
  final double formMaxWidth;

  const AuthSplitLayout({
    super.key,
    required this.headline,
    required this.subtitle,
    required this.formChild,
    this.formMaxWidth = 400,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= kDesktopBreakpoint;

    if (!isDesktop) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: formMaxWidth),
          child: formChild,
        ),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colorScheme.primary, colorScheme.primaryContainer],
              ),
            ),
            padding: const EdgeInsets.all(48),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.bakery_dining_rounded,
                          color: colorScheme.secondaryContainer, size: 28),
                      const SizedBox(width: 10),
                      Text('CustoDoce',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(color: colorScheme.onPrimary)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(headline,
                      style: Theme.of(context)
                          .textTheme
                          .displayLarge
                          ?.copyWith(color: colorScheme.onPrimary)),
                  const SizedBox(height: 12),
                  Text(subtitle,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onPrimary.withValues(alpha: 0.8))),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: formMaxWidth),
              child: formChild,
            ),
          ),
        ),
      ],
    );
  }
}

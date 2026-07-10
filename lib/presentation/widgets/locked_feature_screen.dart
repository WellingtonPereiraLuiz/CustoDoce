import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:custo_doce/core/utils/plan_gate.dart';

class LockedFeatureScreen extends ConsumerWidget {
  final String featureName;
  final String requiredPlan;

  const LockedFeatureScreen({
    super.key,
    required this.featureName,
    required this.requiredPlan,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = colorScheme.secondaryContainer;

    return Scaffold(
      appBar: AppBar(title: Text(featureName)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline_rounded, size: 64, color: accent),
              const SizedBox(height: 20),
              Text(
                'Recurso $requiredPlan',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(
                '$featureName está disponível no plano $requiredPlan.',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: () => PlanGate.navigateToPaywall(context, ref),
                icon: const Icon(Icons.workspace_premium_rounded),
                label: const Text('Ver planos'),
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: colorScheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

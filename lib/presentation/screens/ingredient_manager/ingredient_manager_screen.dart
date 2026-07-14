import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:custo_doce/core/utils/plan_gate.dart';
import 'package:custo_doce/core/providers/subscription_provider.dart';
import 'package:custo_doce/domain/entities/ingredient_entity.dart';
import 'package:custo_doce/presentation/providers/ingredient_providers.dart';
import 'package:custo_doce/presentation/screens/ingredient_manager/add_ingredient_modal.dart';
import 'package:custo_doce/presentation/widgets/ingredient_item_widget.dart';
import 'package:intl/intl.dart';

class IngredientManagerScreen extends ConsumerWidget {
  const IngredientManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ingredientsAsync = ref.watch(ingredientsProvider);
    final currencyFormat =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredientes'),
        leading: BackButton(
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ingredientsAsync.when(
                loading: () => Center(
                    child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary)),
                error: (e, _) => Center(child: Text('Erro: $e')),
                data: (ingredients) {
                  if (ingredients.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inventory_2_outlined,
                              size: 64,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant),
                          const SizedBox(height: 16),
                          Text('Nenhum ingrediente cadastrado',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text('Toque em + para adicionar',
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.outline)),
                        ],
                      ),
                    );
                  }
                  return Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        children: [
                          // Counter chip
                          Builder(builder: (context) {
                            final plan = ref.read(currentPlanProvider);
                            final count = ingredients.length;
                            if (plan.isUnlimitedIngredients) {
                              return const SizedBox.shrink();
                            }
                            final isAtLimit = count >= plan.ingredientLimit;
                            final errorColor =
                                Theme.of(context).colorScheme.error;
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Chip(
                                  label: Text(
                                    '$count / ${plan.ingredientLimit} ingredientes',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isAtLimit ? errorColor : null,
                                    ),
                                  ),
                                  backgroundColor: isAtLimit
                                      ? errorColor.withAlpha(20)
                                      : Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest,
                                  side: BorderSide(
                                    color: isAtLimit
                                        ? errorColor.withAlpha(60)
                                        : Colors.transparent,
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                ),
                              ),
                            );
                          }),
                          Expanded(
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 8, 16, 100),
                              itemCount: ingredients.length,
                              itemBuilder: (context, index) {
                                final ingredient = ingredients[index];
                                return IngredientItem(
                                  ingredient: ingredient,
                                  currencyFormat: currencyFormat,
                                  onEdit: () => _showIngredientForm(
                                      context, ref, ingredient),
                                  onDelete: () async {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title:
                                            const Text('Excluir ingrediente'),
                                        content: Text(
                                            'Excluir "${ingredient.name}"? Receitas que usam este ingrediente podem ser afetadas.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: const Text('Cancelar'),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                              foregroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .onError,
                                            ),
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
                                            child: const Text('Excluir'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirmed == true) {
                                      await ref
                                          .read(ingredientsProvider.notifier)
                                          .deleteIngredient(ingredient.id);
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ))),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_ingredient',
        onPressed: () {
          final plan = ref.read(currentPlanProvider);
          final ingredients = ref.read(ingredientsProvider).value ?? [];
          final canAdd = PlanGate.checkLimit(
            context: context,
            ref: ref,
            currentCount: ingredients.length,
            limit: plan.ingredientLimit,
            featureName: 'ingredientes',
            planName: plan.name,
          );
          if (canAdd) _showIngredientForm(context, ref, null);
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Novo Ingrediente'),
      ),
    );
  }

  void _showIngredientForm(
    BuildContext context,
    WidgetRef ref,
    IngredientEntity? existing,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => AddIngredientModal(existing: existing, ref: ref),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:custo_doce/core/utils/plan_gate.dart';
import 'package:custo_doce/core/providers/subscription_provider.dart';
import 'package:custo_doce/core/constants/layout_constants.dart';
import 'package:custo_doce/domain/entities/ingredient_entity.dart';
import 'package:custo_doce/presentation/providers/ingredient_providers.dart';
import 'package:custo_doce/presentation/screens/ingredient_manager/add_ingredient_modal.dart';
import 'package:custo_doce/presentation/widgets/ingredient_item_widget.dart';
import 'package:intl/intl.dart';

Future<bool> _confirmDeleteIngredient(
    BuildContext context, IngredientEntity ingredient) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Excluir ingrediente'),
      content: Text(
          'Excluir "${ingredient.name}"? Receitas que usam este ingrediente podem ser afetadas.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(ctx).colorScheme.error,
            foregroundColor: Theme.of(ctx).colorScheme.onError,
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Excluir'),
        ),
      ],
    ),
  );
  return confirmed == true;
}

class IngredientManagerScreen extends ConsumerWidget {
  const IngredientManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ingredientsAsync = ref.watch(ingredientsProvider);
    final currencyFormat =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final isDesktop = MediaQuery.of(context).size.width >= kDesktopBreakpoint;

    if (isDesktop) {
      return _DesktopIngredientsBody(
        ingredientsAsync: ingredientsAsync,
        currencyFormat: currencyFormat,
      );
    }

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
                                    final confirmed =
                                        await _confirmDeleteIngredient(
                                            context, ingredient);
                                    if (confirmed) {
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

/// Layout desktop de "Ingredientes" — réplica de
/// `cat_logo_de_ingredientes_custodoce_v2_desktop`: cards de estatística
/// e tabela de catálogo (Nome, Embalagem, Custo do pacote, Custo/un.).
class _DesktopIngredientsBody extends ConsumerWidget {
  final AsyncValue<List<IngredientEntity>> ingredientsAsync;
  final NumberFormat currencyFormat;

  const _DesktopIngredientsBody({
    required this.ingredientsAsync,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: kDesktopContentMaxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Catálogo de Ingredientes',
                              style: Theme.of(context).textTheme.displayLarge),
                          const SizedBox(height: 8),
                          Text(
                            'Gerencie os preços da sua despensa e otimize seus custos de receita.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                    color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        final plan = ref.read(currentPlanProvider);
                        final ingredients =
                            ref.read(ingredientsProvider).value ?? [];
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
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Novo Ingrediente'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ingredientsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => Center(child: Text('Erro: $e')),
                  data: (ingredients) {
                    if (ingredients.isEmpty) {
                      return _DesktopIngredientsEmptyState(
                        onCreate: () =>
                            _showIngredientForm(context, ref, null),
                      );
                    }

                    final avgCost = ingredients.isEmpty
                        ? 0.0
                        : ingredients.fold(
                                0.0, (s, i) => s + i.calculatedUnitCost) /
                            ingredients.length;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _StatTile(
                                title: 'Total de Itens',
                                value: ingredients.length.toString(),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _StatTile(
                                title: 'Custo Médio por Unidade',
                                value: currencyFormat.format(avgCost),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _IngredientsTable(
                          ingredients: ingredients,
                          currencyFormat: currencyFormat,
                          onEdit: (ingredient) =>
                              _showIngredientForm(context, ref, ingredient),
                          onDelete: (ingredient) async {
                            final confirmed = await _confirmDeleteIngredient(
                                context, ingredient);
                            if (confirmed) {
                              await ref
                                  .read(ingredientsProvider.notifier)
                                  .deleteIngredient(ingredient.id);
                            }
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String title;
  final String value;

  const _StatTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .displayLarge
                  ?.copyWith(fontSize: 26)),
        ],
      ),
    );
  }
}

class _IngredientsTable extends StatelessWidget {
  final List<IngredientEntity> ingredients;
  final NumberFormat currencyFormat;
  final ValueChanged<IngredientEntity> onEdit;
  final ValueChanged<IngredientEntity> onDelete;

  const _IngredientsTable({
    required this.ingredients,
    required this.currencyFormat,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Text('Nome do Ingrediente',
                      style: Theme.of(context).textTheme.labelLarge)),
              Expanded(
                  flex: 2,
                  child: Text('Embalagem',
                      style: Theme.of(context).textTheme.labelLarge)),
              Expanded(
                  child: Text('Custo/un.',
                      style: Theme.of(context).textTheme.labelLarge)),
              const SizedBox(width: 88),
            ],
          ),
          const Divider(height: 24),
          for (final ingredient in ingredients)
            InkWell(
              onTap: () => onEdit(ingredient),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(ingredient.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyLarge),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                          '${ingredient.packageSize} ${ingredient.unitOfMeasure.label} · ${currencyFormat.format(ingredient.costPerPackage)}',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ),
                    Expanded(
                      child: Text(
                        currencyFormat.format(ingredient.calculatedUnitCost),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.secondaryContainer,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    SizedBox(
                      width: 88,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            onPressed: () => onEdit(ingredient),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline,
                                size: 18, color: colorScheme.error),
                            onPressed: () => onDelete(ingredient),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DesktopIngredientsEmptyState extends StatelessWidget {
  final VoidCallback onCreate;

  const _DesktopIngredientsEmptyState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 64),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 56, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text('Nenhum ingrediente cadastrado',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Novo Ingrediente'),
          ),
        ],
      ),
    );
  }
}

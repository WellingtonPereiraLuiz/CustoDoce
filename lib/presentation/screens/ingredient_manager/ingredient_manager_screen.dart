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

    return _MobileIngredientsBody(currencyFormat: currencyFormat);
  }
}

/// Layout mobile de "Ingredientes" — réplica de `ingredientes_mobile_custodoce_v2`:
/// header com título e subtítulo, busca com filtro e a lista de insumos.
class _MobileIngredientsBody extends ConsumerStatefulWidget {
  final NumberFormat currencyFormat;

  const _MobileIngredientsBody({required this.currencyFormat});

  @override
  ConsumerState<_MobileIngredientsBody> createState() =>
      _MobileIngredientsBodyState();
}

class _MobileIngredientsBodyState
    extends ConsumerState<_MobileIngredientsBody> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _addIngredient() {
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
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final ingredientsAsync = ref.watch(ingredientsProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        leading: const BackButton(),
        title: Row(
          children: [
            Icon(Icons.bakery_dining_outlined,
                color: colorScheme.primary, size: 26),
            const SizedBox(width: 8),
            Text('CustoDoce',
                style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_ingredient',
        onPressed: _addIngredient,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text('Ingredientes',
                style: textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text('Gerencie seus ingredientes e insumos.',
                style: textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Buscar ingrediente...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ingredientsAsync.when(
              loading: () => Center(
                  child: CircularProgressIndicator(
                      color: colorScheme.primary)),
              error: (e, _) => Center(child: Text('Erro: $e')),
              data: (ingredients) {
                final filtered = ingredients
                    .where((i) =>
                        i.name.toLowerCase().contains(_query.toLowerCase()))
                    .toList();

                if (ingredients.isEmpty) {
                  return _IngredientsEmptyState(onAdd: _addIngredient);
                }
                if (filtered.isEmpty) {
                  return Center(
                    child: Text('Nenhum ingrediente encontrado.',
                        style: TextStyle(color: colorScheme.onSurfaceVariant)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final ingredient = filtered[index];
                    return IngredientItem(
                      ingredient: ingredient,
                      currencyFormat: widget.currencyFormat,
                      onEdit: () =>
                          _showIngredientForm(context, ref, ingredient),
                      onDelete: () async {
                        final confirmed = await _confirmDeleteIngredient(
                            context, ingredient);
                        if (confirmed) {
                          await ref
                              .read(ingredientsProvider.notifier)
                              .deleteIngredient(ingredient.id);
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientsEmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _IngredientsEmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 64, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text('Nenhum ingrediente cadastrado',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Toque em + para adicionar',
              style: TextStyle(color: colorScheme.outline)),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Novo Ingrediente'),
          ),
        ],
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
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
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
                        onCreate: () => _showIngredientForm(context, ref, null),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:custo_doce/presentation/providers/recipe_providers.dart';
import 'package:custo_doce/core/providers/subscription_provider.dart';
import 'package:custo_doce/core/utils/plan_gate.dart';
import 'package:custo_doce/core/utils/price_utils.dart';
import 'package:custo_doce/core/constants/layout_constants.dart';
import 'package:custo_doce/domain/entities/recipe_entity.dart';
import 'package:custo_doce/presentation/widgets/recipe_card_widget.dart';

Future<void> _confirmDeleteRecipe(
    BuildContext context, WidgetRef ref, String recipeId) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Excluir Receita?'),
      content: const Text('Essa ação não pode ser desfeita.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text('Excluir',
              style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
        ),
      ],
    ),
  );
  if (confirm == true) {
    await ref.read(recipesProvider.notifier).deleteRecipe(recipeId);
  }
}

class RecipesScreen extends ConsumerWidget {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(recipesProvider);
    final isDesktop = MediaQuery.of(context).size.width >= kDesktopBreakpoint;

    if (isDesktop) {
      return const _DesktopRecipesBody();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receitas'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: recipesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('Erro ao carregar receitas: $e')),
              data: (recipes) {
                if (recipes.isEmpty) {
                  return Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cake_rounded,
                              size: 64,
                              color: Theme.of(context).colorScheme.outline),
                          const SizedBox(height: 16),
                          Text('Nenhuma receita ainda',
                              style: Theme.of(context).textTheme.headlineSmall),
                        ]),
                  );
                }
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final crossAxisCount =
                        width >= 900 ? 3 : (width >= 600 ? 2 : 1);
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 0.78,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                      ),
                      itemCount: recipes.length,
                      itemBuilder: (context, index) {
                        final recipe = recipes[index];
                        return RecipeCard(
                          recipe: recipe,
                          onTap: () => context.push('/recipe/${recipe.id}'),
                          onDelete: () =>
                              _confirmDeleteRecipe(context, ref, recipe.id),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final plan = ref.read(currentPlanProvider);
          final recipes = ref.read(recipesProvider).value ?? [];
          final canCreate = PlanGate.checkLimit(
            context: context,
            ref: ref,
            currentCount: recipes.length,
            limit: plan.recipeLimit,
            featureName: 'receitas',
            planName: plan.name,
          );
          if (canCreate) context.push('/recipe-builder');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Layout desktop de "Minhas Receitas" — réplica de
/// `minhas_receitas_limpo_custodoce_v2_desktop`: card "Saúde do
/// Portfólio", alternância Grade/Lista e a listagem de receitas.
class _DesktopRecipesBody extends ConsumerStatefulWidget {
  const _DesktopRecipesBody();

  @override
  ConsumerState<_DesktopRecipesBody> createState() =>
      _DesktopRecipesBodyState();
}

class _DesktopRecipesBodyState extends ConsumerState<_DesktopRecipesBody> {
  bool _isGrid = true;

  @override
  Widget build(BuildContext context) {
    final recipesAsync = ref.watch(recipesProvider);
    final currencyFormat =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
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
                          Text('Minhas Receitas',
                              style: Theme.of(context).textTheme.displayLarge),
                          const SizedBox(height: 8),
                          Text(
                            'Gerencie seus doces exclusivos, acompanhe custos de produção e otimize sua estratégia de preços.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                            value: true,
                            label: Text('Grade'),
                            icon: Icon(Icons.grid_view_rounded, size: 16)),
                        ButtonSegment(
                            value: false,
                            label: Text('Lista'),
                            icon: Icon(Icons.view_list_rounded, size: 16)),
                      ],
                      selected: {_isGrid},
                      onSelectionChanged: (s) =>
                          setState(() => _isGrid = s.first),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                recipesAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) =>
                      Center(child: Text('Erro ao carregar receitas: $e')),
                  data: (recipes) {
                    if (recipes.isEmpty) {
                      return _DesktopRecipesEmptyState(
                          onCreate: () => _createRecipe(context, ref));
                    }

                    final margins = recipes
                        .map((r) {
                          final price = r.sellingPrice ??
                              PriceUtils.roundSuggestedPrice(
                                  r.suggestedSellPrice);
                          if (price <= 0) return null;
                          return (price - r.totalCost) / price * 100;
                        })
                        .whereType<double>()
                        .toList();
                    final avgMargin = margins.isEmpty
                        ? 0.0
                        : margins.reduce((a, b) => a + b) / margins.length;

                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            width: 260,
                            child: _PortfolioHealthCard(
                              avgMargin: avgMargin,
                              onCreate: () => _createRecipe(context, ref),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _isGrid
                                ? _RecipesGrid(recipes: recipes)
                                : _RecipesTable(
                                    recipes: recipes,
                                    currencyFormat: currencyFormat,
                                  ),
                          ),
                        ],
                      ),
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

  void _createRecipe(BuildContext context, WidgetRef ref) {
    final plan = ref.read(currentPlanProvider);
    final recipes = ref.read(recipesProvider).value ?? [];
    final canCreate = PlanGate.checkLimit(
      context: context,
      ref: ref,
      currentCount: recipes.length,
      limit: plan.recipeLimit,
      featureName: 'receitas',
      planName: plan.name,
    );
    if (canCreate) context.push('/recipe-builder');
  }
}

class _PortfolioHealthCard extends StatelessWidget {
  final double avgMargin;
  final VoidCallback onCreate;

  const _PortfolioHealthCard(
      {required this.avgMargin, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.show_chart_rounded, color: colorScheme.onPrimary),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('Saúde do Portfólio',
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: colorScheme.onPrimary)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Margem Média',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: colorScheme.onPrimary.withValues(alpha: 0.7))),
          const SizedBox(height: 4),
          Text('${avgMargin.toStringAsFixed(1)}%',
              style: Theme.of(context)
                  .textTheme
                  .displayLarge
                  ?.copyWith(color: colorScheme.onPrimary)),
          const SizedBox(height: 16),
          Text(
            'Mantenha os custos dos ingredientes atualizados para precisão total.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimary.withValues(alpha: 0.7)),
          ),
          const Spacer(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onCreate,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.secondaryContainer,
                foregroundColor: colorScheme.onSecondaryContainer,
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Criar Receita'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipesGrid extends StatelessWidget {
  final List<RecipeEntity> recipes;

  const _RecipesGrid({required this.recipes});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.95,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return Consumer(
          builder: (context, ref, _) => RecipeCard(
            recipe: recipe,
            onTap: () => context.push('/recipe/${recipe.id}'),
            onDelete: () => _confirmDeleteRecipe(context, ref, recipe.id),
          ),
        );
      },
    );
  }
}

class _RecipesTable extends StatelessWidget {
  final List<RecipeEntity> recipes;
  final NumberFormat currencyFormat;

  const _RecipesTable(
      {required this.recipes, required this.currencyFormat});

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
                  child: Text('Receita',
                      style: Theme.of(context).textTheme.labelLarge)),
              Expanded(
                  child: Text('Custo',
                      style: Theme.of(context).textTheme.labelLarge)),
              Expanded(
                  child: Text('Preço',
                      style: Theme.of(context).textTheme.labelLarge)),
              Expanded(
                  child: Text('Lucro',
                      style: Theme.of(context).textTheme.labelLarge)),
            ],
          ),
          const Divider(height: 24),
          for (final recipe in recipes)
            Consumer(
              builder: (context, ref, _) {
                final price = recipe.sellingPrice ??
                    PriceUtils.roundSuggestedPrice(recipe.suggestedSellPrice);
                final margin = price > 0
                    ? ((price - recipe.totalCost) / price * 100).round()
                    : 0;
                return InkWell(
                  onTap: () => context.push('/recipe/${recipe.id}'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 3,
                            child: Text(recipe.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyLarge)),
                        Expanded(
                            child: Text(
                                currencyFormat.format(recipe.totalCost),
                                style: Theme.of(context).textTheme.bodyMedium)),
                        Expanded(
                            child: Text(currencyFormat.format(price),
                                style: Theme.of(context).textTheme.bodyMedium)),
                        Expanded(
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: colorScheme.secondaryContainer
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text('$margin%',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                          color: colorScheme.secondaryContainer)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _DesktopRecipesEmptyState extends StatelessWidget {
  final VoidCallback onCreate;

  const _DesktopRecipesEmptyState({required this.onCreate});

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
          Icon(Icons.cake_rounded,
              size: 56, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text('Nenhuma receita ainda',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Criar Receita'),
          ),
        ],
      ),
    );
  }
}

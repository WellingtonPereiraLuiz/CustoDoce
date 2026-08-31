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
import 'package:custo_doce/core/utils/image_utils.dart';
import 'package:custo_doce/core/theme/app_theme.dart';

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

    return _MobileRecipesBody(recipesAsync: recipesAsync);
  }
}

class _MobileRecipesBody extends ConsumerStatefulWidget {
  final AsyncValue<List<RecipeEntity>> recipesAsync;
  const _MobileRecipesBody({required this.recipesAsync});

  @override
  ConsumerState<_MobileRecipesBody> createState() => _MobileRecipesBodyState();
}

class _MobileRecipesBodyState extends ConsumerState<_MobileRecipesBody> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
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

  void _openAssistant(BuildContext context, WidgetRef ref) {
    final plan = ref.read(currentPlanProvider);
    if (plan.hasChatAi) {
      context.push('/ai-chat');
    } else {
      PlanGate.checkFeature(
        context: context,
        ref: ref,
        hasAccess: false,
        featureName: 'Assistente de IA',
        requiredPlan: 'Premium',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        title: const Text('Minhas Receitas'),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_recipes_chef_ia',
        onPressed: () => _openAssistant(context, ref),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: const CircleBorder(),
        child: const Icon(Icons.auto_awesome),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Buscar receitas...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: widget.recipesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('Erro ao carregar receitas: $e')),
              data: (recipes) {
                final filtered = recipes
                    .where((r) => r.name
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()))
                    .toList();

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                  itemCount: filtered.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index == filtered.length) {
                      return _CreateRecipeCard(
                        onTap: () => _createRecipe(context, ref),
                      );
                    }
                    final recipe = filtered[index];
                    return _RecipeListItem(
                      recipe: recipe,
                      onTap: () => context.push('/recipe/${recipe.id}'),
                      onDelete: () =>
                          _confirmDeleteRecipe(context, ref, recipe.id),
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

/// Card de receita da listagem mobile — réplica de `minhas_receitas_custodoce_v2`:
/// thumbnail + chip de categoria, nome, rendimento e as linhas de custo de
/// produção e preço sugerido.
class _RecipeListItem extends StatelessWidget {
  final RecipeEntity recipe;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _RecipeListItem({
    required this.recipe,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final currencyFormat =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final suggested = PriceUtils.roundSuggestedPrice(recipe.suggestedSellPrice);

    return Material(
      color: colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: RecipeImage.build(
                      imagePath: recipe.imagePath,
                      width: 56,
                      height: 56,
                      placeholder: Container(
                        width: 56,
                        height: 56,
                        color: colorScheme.surfaceContainerHighest,
                        alignment: Alignment.center,
                        child: Icon(Icons.cake_rounded,
                            color: colorScheme.outline, size: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: colorScheme.secondaryContainer
                                  .withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              recipe.category.label,
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          recipe.name,
                          style: textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Rendimento: ${recipe.yieldQuantity} '
                          '${recipe.yieldQuantity == 1 ? 'unidade' : 'unidades'}',
                          style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(height: 1, color: colorScheme.outlineVariant),
              const SizedBox(height: 12),
              _PriceRow(
                label: 'Custo de Produção',
                value: currencyFormat.format(recipe.totalCost),
              ),
              const SizedBox(height: 6),
              _PriceRow(
                label: 'Preço Sugerido',
                value: currencyFormat.format(recipe.sellingPrice ?? suggested),
                highlight: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _PriceRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: textTheme.bodyMedium
                ?.copyWith(color: colorScheme.onSurfaceVariant)),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: highlight ? AppTheme.secondaryColor : colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _CreateRecipeCard extends StatelessWidget {
  final VoidCallback onTap;

  const _CreateRecipeCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 10),
            Text(
              'Criar Nova Receita',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
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

                    return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(height: 24),
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

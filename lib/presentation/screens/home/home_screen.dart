import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:custo_doce/core/utils/image_utils.dart';
import 'package:custo_doce/core/theme/app_theme.dart';
import 'package:custo_doce/presentation/providers/recipe_providers.dart';
import 'package:custo_doce/core/providers/subscription_provider.dart';
import 'package:custo_doce/core/providers/auth_provider.dart';
import 'package:custo_doce/core/utils/plan_gate.dart';
import 'package:custo_doce/domain/entities/recipe_entity.dart';
import 'package:custo_doce/domain/entities/ingredient_entity.dart';
import 'package:intl/intl.dart';
import 'package:custo_doce/core/utils/price_utils.dart';

import 'package:custo_doce/presentation/providers/ingredient_providers.dart';
import 'package:custo_doce/core/constants/layout_constants.dart';
import 'package:custo_doce/core/models/subscription_plan.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPlan = ref.watch(currentPlanProvider);
    final isPro = ref.watch(isProUserProvider);
    final recipesAsync = ref.watch(recipesProvider);
    final ingredientsAsync = ref.watch(ingredientsProvider);
    final currencyFormat =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final isDesktop = MediaQuery.of(context).size.width >= kDesktopBreakpoint;

    if (isDesktop) {
      return _DesktopHomeBody(
        currentPlan: currentPlan,
        recipesAsync: recipesAsync,
        ingredientsAsync: ingredientsAsync,
        currencyFormat: currencyFormat,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('CustoDoce'),
      ),
      body: Center(
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Stack(
                children: [
                  // Decorating Background Glows
                  Positioned(
                    top: -100,
                    right: -100,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.05),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 50,
                    left: -100,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.03),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Foreground Content
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: RefreshIndicator(
                        color: Theme.of(context).colorScheme.primary,
                        onRefresh: () async {
                          ref.read(recipesProvider.notifier).refresh();
                        },
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader(context, isPro, ref),
                              const SizedBox(height: 24),
                              _buildKpiRow(
                                  context, recipesAsync, ingredientsAsync),
                              if (!isPro) ...[
                                const SizedBox(height: 16),
                                _buildPaywallBanner(context, ref),
                              ],
                              const SizedBox(height: 24),
                              _buildQuickActions(context, ref, isPro,
                                  recipesAsync.valueOrNull?.length ?? 0),
                              const SizedBox(height: 16),
                              // Counter chip — só mostra se o plano tem limite
                              Builder(builder: (context) {
                                final plan = ref.read(currentPlanProvider);
                                final recipeCount =
                                    recipesAsync.valueOrNull?.length ?? 0;
                                if (plan.isUnlimitedRecipes) {
                                  return const SizedBox.shrink();
                                }
                                final isAtLimit =
                                    recipeCount >= plan.recipeLimit;
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Chip(
                                    label: Text(
                                      '$recipeCount / ${plan.recipeLimit} receitas',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isAtLimit
                                            ? Theme.of(context)
                                                .colorScheme
                                                .error
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                      ),
                                    ),
                                    backgroundColor: isAtLimit
                                        ? Theme.of(context)
                                            .colorScheme
                                            .error
                                            .withAlpha(20)
                                        : Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHighest,
                                    side: BorderSide(
                                      color: isAtLimit
                                          ? Theme.of(context)
                                              .colorScheme
                                              .error
                                              .withAlpha(60)
                                          : Colors.transparent,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                  ),
                                );
                              }),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Receitas Recentes',
                                    style:
                                        Theme.of(context).textTheme.headlineSmall,
                                  ),
                                  TextButton(
                                    onPressed: () => context.push('/recipes'),
                                    child: const Text('Ver Todas →'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _RecentRecipesSection(
                                recipesAsync: recipesAsync,
                                currencyFormat: currencyFormat,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (currentPlan.hasChatAi) {
            context.push('/ai-chat');
          } else {
            PlanGate.checkFeature(
                context: context,
                ref: ref,
                hasAccess: false,
                featureName: 'Assistente de IA',
                requiredPlan: 'Premium');
          }
        },
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Chef IA'),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isPro, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final firstName = user?.displayName?.split(' ').first ?? 'Chef';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Olá, $firstName! 👨‍🍳',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pronto para precificar e lucrar?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withValues(alpha: 0.7),
                  ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isPro
                ? Theme.of(context)
                    .colorScheme
                    .secondaryContainer
                    .withValues(alpha: 0.15)
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isPro
                  ? Theme.of(context)
                      .colorScheme
                      .secondaryContainer
                      .withValues(alpha: 0.4)
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isPro ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 16,
                color: isPro
                    ? Theme.of(context).colorScheme.secondaryContainer
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                isPro ? 'PRO' : 'Free Plan',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: isPro
                          ? Theme.of(context).colorScheme.secondaryContainer
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKpiRow(
      BuildContext context,
      AsyncValue<List<RecipeEntity>> recipesAsync,
      AsyncValue<List<IngredientEntity>> ingredientsAsync) {
    final recipes = recipesAsync.valueOrNull ?? [];
    final ingredients = ingredientsAsync.valueOrNull ?? [];

    final recipeCount = recipes.length;
    final ingredientCount = ingredients.length;
    final avgCost = recipes.isEmpty
        ? 0.0
        : recipes.fold(0.0, (s, r) => s + r.totalCost) / recipes.length;
    final currencyFormat =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: _DashboardCard(
              title: 'Receitas',
              value: recipeCount.toString(),
              icon: Icons.cake_rounded,
              iconColor: Theme.of(context).colorScheme.primary,
              isLoading: recipesAsync.isLoading,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 140,
            child: _DashboardCard(
              title: 'Ingredientes',
              value: ingredientCount.toString(),
              icon: Icons.kitchen_rounded,
              iconColor: AppTheme.secondaryColor,
              isLoading: ingredientsAsync.isLoading,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 160,
            child: _DashboardCard(
              title: 'Custo Médio',
              value: currencyFormat.format(avgCost),
              icon: Icons.trending_down_rounded,
              iconColor: AppTheme.successColor,
              isLoading: recipesAsync.isLoading,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaywallBanner(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => PlanGate.navigateToPaywall(context, ref),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.surfaceContainerHighest
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.workspace_premium_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Desbloquear CustoDoce Pro',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Crie receitas ilimitadas e maximize seu lucro.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(
      BuildContext context, WidgetRef ref, bool isPro, int recipeCount) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
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
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              elevation: 8,
              shadowColor:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline_rounded, size: 28),
                SizedBox(width: 12),
                Text('Criar Nova Receita',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => context.push('/ingredients'),
            icon: const Icon(Icons.kitchen_rounded),
            label: const Text('Gerenciar Ingredientes'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              side: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  final plan = ref.read(currentPlanProvider);
                  if (PlanGate.checkFeature(
                    context: context,
                    ref: ref,
                    hasAccess: plan.hasDigitalMenu,
                    featureName: 'Cardápio Digital',
                    requiredPlan: 'Pro',
                  )) {
                    context.push('/menu');
                  }
                },
                icon: const Icon(Icons.restaurant_menu_rounded),
                label: const Text('Cardápio'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  side: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RecentRecipesSection extends StatefulWidget {
  final AsyncValue<List<RecipeEntity>> recipesAsync;
  final NumberFormat currencyFormat;

  const _RecentRecipesSection(
      {required this.recipesAsync, required this.currencyFormat});

  @override
  State<_RecentRecipesSection> createState() => _RecentRecipesSectionState();
}

class _RecentRecipesSectionState extends State<_RecentRecipesSection> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return widget.recipesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('Erro ao carregar receitas: $e',
            style: TextStyle(color: Theme.of(context).colorScheme.error)),
      ),
      data: (recipes) {
        if (recipes.isEmpty) {
          return const _EmptyStateWidget();
        }

        final filtered = recipes
            .where(
              (r) => r.name.toLowerCase().contains(_searchQuery.toLowerCase()),
            )
            .toList();

        return Column(
          children: [
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Buscar receita...',
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
            const SizedBox(height: 16),
            if (filtered.isEmpty)
              const Center(
                  child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Nenhuma receita encontrada.')))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final recipe = filtered[index];
                  return _RecipeListTile(
                    recipe: recipe,
                    currencyFormat: widget.currencyFormat,
                    onTap: () => context.push('/recipe/${recipe.id}'),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _DashboardCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.isLoading = false,
  });

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              )
            ],
          ),
          const SizedBox(height: 16),
          if (isLoading)
            Shimmer.fromColors(
              baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              highlightColor:
                  Theme.of(context).colorScheme.surfaceContainerHigh,
              child: Container(
                height: 24,
                width: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            )
          else
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyStateWidget extends StatelessWidget {
  const _EmptyStateWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.soup_kitchen_rounded,
              size: 48,
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Nenhuma receita ainda',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Comece cadastrando seus ingredientes básicos e depois crie sua primeira ficha de custo.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.color
                  ?.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeListTile extends StatelessWidget {
  final RecipeEntity recipe;
  final NumberFormat currencyFormat;
  final VoidCallback onTap;

  const _RecipeListTile({
    required this.recipe,
    required this.currencyFormat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: RecipeImage.build(
                imagePath: recipe.imagePath,
                width: 48,
                height: 48,
                placeholder: _buildPlaceholder(context),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${recipe.category.label} • Custo: ${currencyFormat.format(recipe.totalCost)}',
                    style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  recipe.sellingPrice != null ? 'Venda' : 'Sugerido',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.successColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  currencyFormat.format(recipe.sellingPrice ??
                      PriceUtils.roundSuggestedPrice(
                          recipe.suggestedSellPrice)),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppTheme.successColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.cake_rounded,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

/// Painel (dashboard) desktop — réplica do layout com sidebar/topbar de
/// `dashboard_traduzido_custodoce_v2`: cards de estatística, tabela de
/// receitas recentes e um card de CTA para criar receita.
class _DesktopHomeBody extends ConsumerWidget {
  final PlanLimits currentPlan;
  final AsyncValue<List<RecipeEntity>> recipesAsync;
  final AsyncValue<List<IngredientEntity>> ingredientsAsync;
  final NumberFormat currencyFormat;

  const _DesktopHomeBody({
    required this.currentPlan,
    required this.recipesAsync,
    required this.ingredientsAsync,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final firstName = user?.displayName?.split(' ').first ?? 'Chef';
    final recipes = recipesAsync.valueOrNull ?? [];
    final ingredients = ingredientsAsync.valueOrNull ?? [];
    final now = DateTime.now();
    final newThisMonth = recipes
        .where((r) =>
            r.createdAt.year == now.year && r.createdAt.month == now.month)
        .length;

    final margins = recipes
        .map((r) {
          final price = r.sellingPrice ??
              PriceUtils.roundSuggestedPrice(r.suggestedSellPrice);
          if (price <= 0) return null;
          return (price - r.totalCost) / price * 100;
        })
        .whereType<double>()
        .toList();
    final avgMargin = margins.isEmpty
        ? 0.0
        : margins.reduce((a, b) => a + b) / margins.length;

    final recentRecipes = recipes.take(5).toList();

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
                Text('Bem-vindo de volta, $firstName',
                    style: Theme.of(context).textTheme.displayLarge),
                const SizedBox(height: 8),
                Text(
                  'Gerencie seu portfólio de doces e acompanhe os custos de produção com eficiência.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.restaurant_rounded,
                        title: 'Receitas Ativas',
                        value: recipes.length.toString(),
                        footnote:
                            newThisMonth > 0 ? '+$newThisMonth este mês' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.inventory_2_rounded,
                        title: 'Ingredientes cadastrados',
                        value: ingredients.length.toString(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.trending_up_rounded,
                        title: 'Margem de Lucro Média',
                        value: '${avgMargin.toStringAsFixed(0)}%',
                        dark: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _RecentRecipesCard(
                          recipes: recentRecipes,
                          currencyFormat: currencyFormat,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _CreateRecipeCta(
                          onTap: () {
                            final plan = ref.read(currentPlanProvider);
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
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (currentPlan.hasChatAi) {
            context.push('/ai-chat');
          } else {
            PlanGate.checkFeature(
                context: context,
                ref: ref,
                hasAccess: false,
                featureName: 'Assistente de IA',
                requiredPlan: 'Premium');
          }
        },
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Chef IA'),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? footnote;
  final bool dark;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    this.footnote,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fg = dark ? colorScheme.onPrimary : colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: dark ? colorScheme.primary : colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (dark ? colorScheme.onPrimary : colorScheme.primary)
                  .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon,
                size: 20, color: dark ? colorScheme.onPrimary : colorScheme.primary),
          ),
          const SizedBox(height: 16),
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: fg.withValues(alpha: 0.7))),
          const SizedBox(height: 4),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .displayLarge
                  ?.copyWith(fontSize: 28, color: fg)),
          if (footnote != null) ...[
            const SizedBox(height: 4),
            Text(footnote!,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: fg.withValues(alpha: 0.6))),
          ],
        ],
      ),
    );
  }
}

class _RecentRecipesCard extends StatelessWidget {
  final List<RecipeEntity> recipes;
  final NumberFormat currencyFormat;

  const _RecentRecipesCard(
      {required this.recipes, required this.currencyFormat});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Receitas Recentes',
                  style: Theme.of(context).textTheme.headlineSmall),
              TextButton(
                onPressed: () => context.push('/recipes'),
                child: const Text('Ver Todas'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (recipes.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text('Nenhuma receita cadastrada ainda.',
                  style: Theme.of(context).textTheme.bodyMedium),
            )
          else
            ...recipes.map((recipe) {
              final price = recipe.sellingPrice ??
                  PriceUtils.roundSuggestedPrice(recipe.suggestedSellPrice);
              final margin = price > 0
                  ? ((price - recipe.totalCost) / price * 100).round()
                  : 0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: RecipeImage.build(
                        imagePath: recipe.imagePath,
                        width: 40,
                        height: 40,
                        placeholder: Container(
                          width: 40,
                          height: 40,
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          child: Icon(Icons.cake_rounded,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(recipe.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyLarge),
                    ),
                    SizedBox(
                      width: 90,
                      child: Text(currencyFormat.format(recipe.totalCost),
                          style: Theme.of(context).textTheme.bodyMedium),
                    ),
                    SizedBox(
                      width: 90,
                      child: Text(currencyFormat.format(price),
                          style: Theme.of(context).textTheme.bodyMedium),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .secondaryContainer
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text('$margin%',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer)),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _CreateRecipeCta extends StatelessWidget {
  final VoidCallback onTap;

  const _CreateRecipeCta({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.onPrimary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.add, color: colorScheme.onPrimary),
          ),
          const SizedBox(height: 16),
          Text('Criar Receita',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: colorScheme.onPrimary)),
          const SizedBox(height: 4),
          Text('Comece uma nova criação artesanal',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onPrimary.withValues(alpha: 0.7))),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.secondaryContainer,
                foregroundColor: colorScheme.onSecondaryContainer,
              ),
              icon: const Icon(Icons.restaurant_rounded, size: 18),
              label: const Text('Nova Receita'),
            ),
          ),
        ],
      ),
    );
  }
}

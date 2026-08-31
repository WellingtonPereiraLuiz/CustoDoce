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
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: RefreshIndicator(
          color: Theme.of(context).colorScheme.primary,
          onRefresh: () async {
            ref.read(recipesProvider.notifier).refresh();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderMobile(context, ref),
                const SizedBox(height: 16),
                _buildKpiRow(context, recipesAsync, ingredientsAsync),
                const SizedBox(height: 24),
                _buildQuickActions(context, ref, isPro, recipesAsync.valueOrNull?.length ?? 0),
                if (!isPro) ...[
                  const SizedBox(height: 24),
                  _buildPaywallBanner(context, ref),
                ],
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Receitas Recentes',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/recipes'),
                        child: const Text(
                          'Ver todas',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _RecentRecipesSection(
                    recipesAsync: recipesAsync,
                    currencyFormat: currencyFormat,
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_home_chef_ia',
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
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        shape: const CircleBorder(),
        child: const Icon(Icons.auto_awesome),
      ),
    );
  }

  Widget _buildHeaderMobile(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final firstName = user?.displayName?.split(' ').first ?? 'Chef';
    final photoUrl = user?.photoURL;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Olá, $firstName!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Pronto para adoçar o dia?',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.primaryContainer,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: photoUrl != null
                  ? Image.network(photoUrl, fit: BoxFit.cover)
                  : Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
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
    
    final margins = recipes.map((r) {
      final price = r.sellingPrice ?? PriceUtils.roundSuggestedPrice(r.suggestedSellPrice);
      if (price <= 0) return null;
      return (price - r.totalCost) / price * 100;
    }).whereType<double>().toList();
    
    final avgMargin = margins.isEmpty ? 0.0 : margins.reduce((a, b) => a + b) / margins.length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _DashboardCard(
            title: 'Receitas',
            value: recipeCount.toString(),
            icon: Icons.cake,
            iconColor: AppTheme.secondaryColor,
            isLoading: recipesAsync.isLoading,
          ),
          const SizedBox(width: 12),
          _DashboardCard(
            title: 'Ingredientes',
            value: ingredientCount.toString(),
            icon: Icons.kitchen,
            iconColor: AppTheme.secondaryColor,
            isLoading: ingredientsAsync.isLoading,
          ),
          const SizedBox(width: 12),
          _DashboardCard(
            title: 'Margem Média',
            value: '${avgMargin.toStringAsFixed(0)}%',
            icon: Icons.trending_up,
            iconColor: Theme.of(context).colorScheme.secondaryContainer,
            isLoading: recipesAsync.isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildPaywallBanner(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () => PlanGate.navigateToPaywall(context, ref),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.star,
                    color: AppTheme.secondaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DESBLOQUEIE TODO O POTENCIAL',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Conheça o Plano Pro',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppTheme.secondaryColor),
                ),
                child: const Text(
                  'Ver Planos',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.secondaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(
      BuildContext context, WidgetRef ref, bool isPro, int recipeCount) {
    Widget buildBtn(IconData icon, String label, bool isPrimary, VoidCallback onTap) {
      final colorScheme = Theme.of(context).colorScheme;
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 140,
          height: 100,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isPrimary ? colorScheme.primary : colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isPrimary ? colorScheme.primary : colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isPrimary ? colorScheme.onPrimary : AppTheme.secondaryColor,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                label.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isPrimary ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ações Rápidas',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                buildBtn(Icons.add_circle, 'Criar Nova Receita', true, () {
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
                }),
                const SizedBox(width: 12),
                buildBtn(Icons.kitchen, 'Gerenciar Ingredientes', false, () => context.push('/ingredients')),
                const SizedBox(width: 12),
                buildBtn(Icons.restaurant_menu, 'Cardápio', false, () {
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
                }),
              ],
            ),
          ),
        ],
      ),
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

        final recentRecipes = recipes.take(10).toList();

        return Column(
          children: [
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentRecipes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final recipe = recentRecipes[index];
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
  final bool isLoading;

  const _DashboardCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 144,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          if (isLoading)
            Shimmer.fromColors(
              baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              highlightColor: Theme.of(context).colorScheme.surfaceContainerHigh,
              child: Container(
                height: 24,
                width: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            )
          else
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
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
    final price = recipe.sellingPrice ?? PriceUtils.roundSuggestedPrice(recipe.suggestedSellPrice);
    final profit = price - recipe.totalCost;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: RecipeImage.build(
                imagePath: recipe.imagePath,
                width: 64,
                height: 64,
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencyFormat.format(price),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Lucro',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.secondaryContainer,
                    ),
                  ),
                  Text(
                    currencyFormat.format(profit > 0 ? profit : 0),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.restaurant_rounded,
                          title: 'Receitas Ativas',
                          value: recipes.length.toString(),
                          footnote: newThisMonth > 0
                              ? '+$newThisMonth este mês'
                              : null,
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
        heroTag: 'fab_home_desktop_chef_ia',
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

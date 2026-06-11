import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:custo_doce/core/theme/app_theme.dart';
import 'package:custo_doce/presentation/providers/recipe_providers.dart';
import 'package:custo_doce/core/providers/subscription_provider.dart';
import 'package:custo_doce/core/utils/plan_gate.dart';
import 'package:custo_doce/domain/entities/recipe_entity.dart';
import 'package:custo_doce/domain/entities/ingredient_entity.dart';
import 'package:intl/intl.dart';

import 'package:custo_doce/presentation/providers/ingredient_providers.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPro = ref.watch(isProUserProvider);
    final recipesAsync = ref.watch(recipesProvider);
    final ingredientsAsync = ref.watch(ingredientsProvider);
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('CustoDoce'),
      ),
      body: Stack(
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
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
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
                    Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.03),
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
              _buildHeader(context, isPro),
              const SizedBox(height: 24),
              _buildKpiRow(context, recipesAsync, ingredientsAsync),
              if (!isPro) ...[
                const SizedBox(height: 16),
                _buildPaywallBanner(context),
              ],
              const SizedBox(height: 24),
              _buildQuickActions(context, ref, isPro, recipesAsync.valueOrNull?.length ?? 0),
              const SizedBox(height: 16),
              // Counter chip — só mostra se o plano tem limite
              Builder(builder: (context) {
                final plan = ref.read(currentPlanProvider);
                final recipeCount = recipesAsync.valueOrNull?.length ?? 0;
                if (plan.isUnlimitedRecipes) return const SizedBox.shrink();
                final isAtLimit = recipeCount >= plan.recipeLimit;
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Chip(
                    label: Text(
                      '$recipeCount / ${plan.recipeLimit} receitas',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isAtLimit ? AppTheme.errorColor : null,
                      ),
                    ),
                    backgroundColor: isAtLimit
                        ? AppTheme.errorColor.withAlpha(20)
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    side: BorderSide(
                      color: isAtLimit
                          ? AppTheme.errorColor.withAlpha(60)
                          : Colors.transparent,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                );
              }),
              const SizedBox(height: 16),
              Text(
                'Receitas Recentes',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 16),
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
      ),
    );
  }


  Widget _buildHeader(BuildContext context, bool isPro) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Olá, Chef! 👨‍🍳',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pronto para precificar e lucrar?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                  ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isPro
                ? const Color(0xFFFFD700).withValues(alpha: 0.15)
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isPro
                  ? const Color(0xFFFFD700).withValues(alpha: 0.3)
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isPro ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 16,
                color: isPro ? const Color(0xFFFFD700) : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                isPro ? 'PRO' : 'Free Plan',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isPro ? const Color(0xFFFFD700) : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKpiRow(BuildContext context, AsyncValue<List<RecipeEntity>> recipesAsync, AsyncValue<List<IngredientEntity>> ingredientsAsync) {
    final recipes = recipesAsync.valueOrNull ?? [];
    final ingredients = ingredientsAsync.valueOrNull ?? [];
    
    final recipeCount = recipes.length;
    final ingredientCount = ingredients.length;
    final avgCost = recipes.isEmpty ? 0.0 : recipes.fold(0.0, (s, r) => s + r.totalCost) / recipes.length;
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

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

  Widget _buildPaywallBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/paywall'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Theme.of(context).colorScheme.primaryContainer, Theme.of(context).colorScheme.surfaceContainerHighest],
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
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
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
                      color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
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

  Widget _buildQuickActions(BuildContext context, WidgetRef ref, bool isPro, int recipeCount) {
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
              shadowColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline_rounded, size: 28),
                SizedBox(width: 12),
                Text('Criar Nova Receita', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
              side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }
}

class _RecentRecipesSection extends StatefulWidget {
  final AsyncValue<List<RecipeEntity>> recipesAsync;
  final NumberFormat currencyFormat;

  const _RecentRecipesSection({required this.recipesAsync, required this.currencyFormat});

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
            style: const TextStyle(color: AppTheme.errorColor)),
      ),
      data: (recipes) {
        if (recipes.isEmpty) {
          return const _EmptyStateWidget();
        }

        final filtered = recipes.where(
          (r) => r.name.toLowerCase().contains(_searchQuery.toLowerCase()),
        ).toList();

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
              const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('Nenhuma receita encontrada.')))
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
                  color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
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
              highlightColor: Theme.of(context).colorScheme.surfaceContainerHigh,
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
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
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
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
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
              color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.cake_rounded,
                color: Theme.of(context).colorScheme.primary,
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
                    'Custo: ${currencyFormat.format(recipe.totalCost)}',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Venda',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.successColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  currencyFormat.format(recipe.suggestedSellPrice),
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
}



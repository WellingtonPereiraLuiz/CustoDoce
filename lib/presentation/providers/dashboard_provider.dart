import 'package:custo_doce/core/enums/recipe_category.dart';
import 'package:custo_doce/domain/entities/recipe_entity.dart';
import 'package:custo_doce/presentation/providers/recipe_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardMetrics {
  final double avgCost;
  final double avgMargin;
  final double totalPotentialRevenue;
  final RecipeEntity? mostProfitable;
  final RecipeEntity? mostExpensive;
  final Map<RecipeCategory, int> categoryCount;
  final List<RecipeEntity> topByProfit;

  const DashboardMetrics({
    required this.avgCost,
    required this.avgMargin,
    required this.totalPotentialRevenue,
    required this.mostProfitable,
    required this.mostExpensive,
    required this.categoryCount,
    required this.topByProfit,
  });
}

final dashboardMetricsProvider = Provider<DashboardMetrics>((ref) {
  final recipes = ref.watch(recipesProvider).value ?? [];

  if (recipes.isEmpty) {
    return const DashboardMetrics(
      avgCost: 0,
      avgMargin: 0,
      totalPotentialRevenue: 0,
      mostProfitable: null,
      mostExpensive: null,
      categoryCount: {},
      topByProfit: [],
    );
  }

  final avgCost = recipes.map((r) => r.totalCost).reduce((a, b) => a + b) / recipes.length;
  final avgMargin = recipes.map((r) => r.profitMarginPercentage).reduce((a, b) => a + b) / recipes.length;
  final totalPotentialRevenue = recipes.map((r) => r.suggestedSellPrice).reduce((a, b) => a + b);

  final sortedByProfit = [...recipes]..sort((a, b) =>
      (b.suggestedSellPrice - b.totalCost).compareTo(a.suggestedSellPrice - a.totalCost));

  final categoryCount = <RecipeCategory, int>{};
  for (final r in recipes) {
    categoryCount[r.category] = (categoryCount[r.category] ?? 0) + 1;
  }

  return DashboardMetrics(
    avgCost: avgCost,
    avgMargin: avgMargin,
    totalPotentialRevenue: totalPotentialRevenue,
    mostProfitable: sortedByProfit.first,
    mostExpensive: recipes.reduce((a, b) => a.totalCost > b.totalCost ? a : b),
    categoryCount: categoryCount,
    topByProfit: sortedByProfit.take(5).toList(),
  );
});

import 'package:custo_doce/core/enums/recipe_category.dart';
import 'package:custo_doce/core/providers/subscription_provider.dart';
import 'package:custo_doce/core/theme/app_theme.dart';
import 'package:custo_doce/domain/entities/recipe_entity.dart';
import 'package:custo_doce/presentation/providers/dashboard_provider.dart';
import 'package:custo_doce/presentation/widgets/locked_feature_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(currentPlanProvider);
    if (!plan.hasReports) {
      return const LockedFeatureScreen(
        featureName: 'Relatórios e Gráficos',
        requiredPlan: 'Pro',
      );
    }

    final metrics = ref.watch(dashboardMetricsProvider);
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildKpis(context, metrics, currencyFormat),
            const SizedBox(height: 24),
            _buildChartContainer(
              context,
              title: 'Top Receitas por Lucro',
              child: _TopRecipesChart(recipes: metrics.topByProfit, currencyFormat: currencyFormat),
            ),
            const SizedBox(height: 24),
            _buildChartContainer(
              context,
              title: 'Categorias',
              child: _CategoryPieChart(categoryCount: metrics.categoryCount),
            ),
            const SizedBox(height: 24),
            _buildProfitabilityList(context, metrics.topByProfit, currencyFormat),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildKpis(BuildContext context, DashboardMetrics metrics, NumberFormat currencyFormat) {
    return Row(
      children: [
        Expanded(
          child: _KpiCard(
            title: 'Custo Médio',
            value: currencyFormat.format(metrics.avgCost),
            icon: Icons.trending_down_rounded,
            iconColor: AppTheme.errorColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _KpiCard(
            title: 'Margem Méd.',
            value: '${metrics.avgMargin.toStringAsFixed(1)}%',
            icon: Icons.show_chart_rounded,
            iconColor: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildChartContainer(BuildContext context, {required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(height: 200, child: child),
        ],
      ),
    );
  }

  Widget _buildProfitabilityList(BuildContext context, List<RecipeEntity> topRecipes, NumberFormat currencyFormat) {
    if (topRecipes.isEmpty) return const SizedBox.shrink();

    final highestProfit = (topRecipes.first.suggestedSellPrice - topRecipes.first.totalCost).clamp(0.01, double.infinity);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ranking de Lucratividade', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...topRecipes.asMap().entries.map((entry) {
            final index = entry.key;
            final r = entry.value;
            final profit = r.suggestedSellPrice - r.totalCost;
            final ratio = profit / highestProfit;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('#${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(r.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
                      Text(currencyFormat.format(profit), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.successColor)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: ratio.clamp(0.0, 1.0),
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      color: AppTheme.successColor,
                      minHeight: 8,
                    ),
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

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _KpiCard({required this.title, required this.value, required this.icon, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _TopRecipesChart extends StatelessWidget {
  final List<RecipeEntity> recipes;
  final NumberFormat currencyFormat;

  const _TopRecipesChart({required this.recipes, required this.currencyFormat});

  @override
  Widget build(BuildContext context) {
    if (recipes.isEmpty) return const Center(child: Text('Dados insuficientes'));

    final primary = Theme.of(context).colorScheme.primary;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (recipes.first.suggestedSellPrice - recipes.first.totalCost) * 1.2,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => Theme.of(context).colorScheme.surface,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${recipes[groupIndex].name}\nLucro: ${currencyFormat.format(rod.toY)}',
                TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= recipes.length) return const SizedBox.shrink();
                var name = recipes[index].name;
                if (name.length > 8) name = '${name.substring(0, 8)}...';
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(name, style: const TextStyle(fontSize: 10)),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: recipes.asMap().entries.map((entry) {
          final profit = entry.value.suggestedSellPrice - entry.value.totalCost;
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: profit > 0 ? profit : 0,
                color: primary,
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _CategoryPieChart extends StatelessWidget {
  final Map<RecipeCategory, int> categoryCount;

  static const _categoryColors = {
    RecipeCategory.bolo: Color(0xFFE5BEB6),
    RecipeCategory.torta: Color(0xFFD4A5A0),
    RecipeCategory.brigadeiro: Color(0xFF9B6B65),
    RecipeCategory.cookies: Color(0xFFB8956F),
    RecipeCategory.paes: Color(0xFFD4B896),
    RecipeCategory.salgados: Color(0xFF8FA68C),
    RecipeCategory.bebidas: Color(0xFF7B9BAF),
    RecipeCategory.outro: Color(0xFFADADAD),
  };

  const _CategoryPieChart({required this.categoryCount});

  @override
  Widget build(BuildContext context) {
    if (categoryCount.isEmpty) return const Center(child: Text('Dados insuficientes'));

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 30,
              sections: categoryCount.entries.map((e) {
                return PieChartSectionData(
                  color: _categoryColors[e.key] ?? _categoryColors[RecipeCategory.outro]!,
                  value: e.value.toDouble(),
                  title: '${e.value}',
                  radius: 40,
                  titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: categoryCount.keys.map((cat) {
            return Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _categoryColors[cat] ?? _categoryColors[RecipeCategory.outro]!,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(cat.label, style: const TextStyle(fontSize: 12)),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

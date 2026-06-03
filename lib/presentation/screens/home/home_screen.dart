import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:custo_doce/core/theme/app_theme.dart';
import 'package:custo_doce/presentation/providers/recipe_providers.dart';
import 'package:custo_doce/domain/entities/recipe_entity.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(recipesProvider);
    final currencyFormat =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('CustoDoce 🍰'),
        actions: [
          IconButton(
            tooltip: 'Gerenciar Ingredientes',
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => context.push('/ingredients'),
          ),
          IconButton(
            tooltip: 'Configurações',
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => context.push('/settings'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: recipesAsync.when(
        loading: () => _buildShimmer(),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  color: AppTheme.errorColor, size: 48),
              const SizedBox(height: 12),
              Text('Erro ao carregar receitas',
                  style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.refresh(recipesProvider),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
        data: (recipes) {
          if (recipes.isEmpty) return _buildEmptyState(context);
          return RefreshIndicator(
            color: AppTheme.primaryColor,
            onRefresh: () => ref.read(recipesProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return _RecipeCard(
                  recipe: recipe,
                  currencyFormat: currencyFormat,
                  onEdit: () => context.push('/recipe-builder/${recipe.id}'),
                  onDelete: () => _confirmDelete(context, ref, recipe),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_home',
        onPressed: () => context.push('/recipe-builder'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nova Receita'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppTheme.surfaceVariantDark,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                size: 48,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhuma receita ainda',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toque em + para criar sua primeira receita e calcular o preço de venda.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF9E9E9E),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 120,
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariantDark,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    RecipeEntity recipe,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir receita'),
        content: Text(
            'Deseja excluir "${recipe.name}"? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(recipesProvider.notifier).deleteRecipe(recipe.id);
    }
  }
}

class _RecipeCard extends StatelessWidget {
  final RecipeEntity recipe;
  final NumberFormat currencyFormat;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RecipeCard({
    required this.recipe,
    required this.currencyFormat,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppTheme.surfaceVariantDark,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.cake_rounded,
                        color: AppTheme.primaryColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        recipe.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded, size: 20),
                      onSelected: (v) {
                        if (v == 'edit') onEdit();
                        if (v == 'delete') onDelete();
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                            value: 'edit', child: Text('Editar')),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Excluir',
                              style:
                                  TextStyle(color: AppTheme.errorColor)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _InfoChip(
                        label: 'Custo Total',
                        value: currencyFormat.format(recipe.totalCost),
                        color: const Color(0xFF9E9E9E),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _InfoChip(
                        label: 'Preço Sugerido',
                        value: currencyFormat
                            .format(recipe.suggestedSellPrice),
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _InfoChip(
                        label: 'Margem',
                        value:
                            '${recipe.profitMarginPercentage.toStringAsFixed(0)}%',
                        color: AppTheme.successColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10, color: color.withOpacity(0.8)),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

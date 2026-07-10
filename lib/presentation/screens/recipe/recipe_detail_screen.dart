import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:custo_doce/core/utils/image_utils.dart';
import 'package:custo_doce/presentation/providers/recipe_providers.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class RecipeDetailScreen extends ConsumerWidget {
  final String recipeId;
  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(recipesProvider);
    final currencyFormat =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return recipesAsync.when(
      loading: () => Scaffold(
          body: Center(
              child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: const Center(child: CircularProgressIndicator())))),
      error: (e, _) => Scaffold(body: Center(child: Text('Erro: $e'))),
      data: (recipes) {
        final recipe = recipes.where((r) => r.id == recipeId).firstOrNull;
        if (recipe == null) {
          return const Scaffold(
              body: Center(child: Text('Receita não encontrada')));
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(recipe.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () {
                  final text = '''
🍰 ${recipe.name} (${recipe.category.label})
Rendimento: ${recipe.yieldQuantity} porções

Custo total: R\$ ${recipe.totalCost.toStringAsFixed(2)}
Custo por unidade: R\$ ${(recipe.totalCost / recipe.yieldQuantity).toStringAsFixed(2)}
Preço sugerido (${recipe.profitMarginPercentage.toStringAsFixed(0)}% margem): R\$ ${recipe.suggestedSellPrice.toStringAsFixed(2)}

Calculado com CustoDoce 🍫
                  ''';
                  SharePlus.instance.share(ShareParams(text: text));
                },
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.push('/recipe-builder/${recipe.id}'),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline,
                    color: Theme.of(context).colorScheme.error),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHigh,
                      titleTextStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      contentTextStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 16,
                      ),
                      title: const Text('Excluir Receita?'),
                      content: const Text('Essa ação não pode ser desfeita.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text('Cancelar',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text('Excluir',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await ref
                        .read(recipesProvider.notifier)
                        .deleteRecipe(recipe.id);
                    if (context.mounted) context.pop();
                  }
                },
              ),
            ],
          ),
          body: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (recipe.imagePath != null &&
                        recipe.imagePath!.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: RecipeImage.build(
                            imagePath: recipe.imagePath,
                            width: double.infinity,
                            height: double.infinity,
                            placeholder: Container(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Category Chip
                    Chip(
                      label: Text(recipe.category.label),
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1),
                      labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),

                    // Costs Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color:
                                Theme.of(context).colorScheme.outlineVariant),
                      ),
                      child: Column(
                        children: [
                          _CostRow('Custo Total',
                              currencyFormat.format(recipe.totalCost)),
                          const Divider(),
                          _CostRow(
                              'Rendimento', '${recipe.yieldQuantity} porções'),
                          const Divider(),
                          _CostRow(
                              'Custo por Porção',
                              currencyFormat.format(
                                  recipe.totalCost / recipe.yieldQuantity)),
                          const Divider(),
                          _CostRow('Preço Sugerido',
                              currencyFormat.format(recipe.suggestedSellPrice),
                              isHighlighted: true),
                          if (recipe.sellingPrice != null) ...[
                            const Divider(),
                            _CostRow('Preço de Venda',
                                currencyFormat.format(recipe.sellingPrice!),
                                isHighlighted: true),
                            const Divider(),
                            _CostRow(
                                'Lucro (estimado)',
                                currencyFormat.format(
                                    recipe.sellingPrice! - recipe.totalCost),
                                isHighlighted: false),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Ingredients
                    Text(
                      'Ingredientes',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ...recipe.ingredients.map((i) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  Theme.of(context).colorScheme.outlineVariant,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    i.ingredientName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15),
                                  ),
                                  Text(
                                    '${i.quantityUsed} ${i.ingredientUnit}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                currencyFormat
                                    .format(i.calculatedIngredientCost),
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer,
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CostRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlighted;

  const _CostRow(this.label, this.value, {this.isHighlighted = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withValues(alpha: 0.7))),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlighted ? 20 : 16,
              fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.bold,
              color: isHighlighted
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

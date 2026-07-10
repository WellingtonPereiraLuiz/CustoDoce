import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:custo_doce/core/utils/image_utils.dart';
import 'package:custo_doce/domain/entities/recipe_entity.dart';

/// Card de receita do design system Stitch v2: imagem, nome, categoria,
/// custo por unidade e preço de venda.
class RecipeCard extends StatelessWidget {
  final RecipeEntity recipe;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final currencyFormat =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final costPerUnit = recipe.yieldQuantity > 0
        ? recipe.totalCost / recipe.yieldQuantity
        : recipe.totalCost;
    final sellingPrice = recipe.sellingPrice ?? recipe.suggestedSellPrice;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: RecipeImage.build(
                imagePath: recipe.imagePath,
                width: double.infinity,
                height: double.infinity,
                placeholder: Container(
                  color: colorScheme.surfaceContainerHighest,
                  alignment: Alignment.center,
                  child: Icon(Icons.cake_rounded,
                      color: colorScheme.outline, size: 40),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          recipe.name,
                          style: textTheme.headlineSmall
                              ?.copyWith(fontSize: 16),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (onDelete != null)
                        InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: onDelete,
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Icon(Icons.delete_outline,
                                size: 18, color: colorScheme.error),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Text(
                      recipe.category.label,
                      style: textTheme.labelSmall,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Custo/un.',
                              style: textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant)),
                          Text(currencyFormat.format(costPerUnit),
                              style: textTheme.bodyMedium),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Venda',
                              style: textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant)),
                          Text(
                            currencyFormat.format(sellingPrice),
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.secondaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

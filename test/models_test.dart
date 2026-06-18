import 'package:flutter_test/flutter_test.dart';
import 'package:custo_doce/core/utils/price_utils.dart';
import 'package:custo_doce/domain/entities/recipe_entity.dart';
import 'package:custo_doce/core/enums/recipe_category.dart';

void main() {
  group('PriceUtils Tests', () {
    test('roundSuggestedPrice deve arredondar corretamente', () {
      expect(PriceUtils.roundSuggestedPrice(10.12), 10.12);
      expect(PriceUtils.roundSuggestedPrice(15.99), 15.99);
      expect(PriceUtils.roundSuggestedPrice(0.0), 0.0);
    });

    test('roundSuggestedPrice deve lidar com decimais', () {
      expect(PriceUtils.roundSuggestedPrice(10.125), 10.13);
      expect(PriceUtils.roundSuggestedPrice(10.124), 10.12);
    });
  });

  group('RecipeEntity Tests', () {
    test('RecipeEntity copyWith deve atualizar os campos corretos', () {
      final recipe = RecipeEntity(
        id: '1',
        name: 'Bolo de Chocolate',
        ingredients: [],
        profitMargin: 20.0,
        yieldQuantity: 1,
        totalCost: 20.0,
        suggestedSellPrice: 30.0,
        category: RecipeCategory.bolo,
        createdAt: DateTime(2023, 1, 1),
      );

      final updated = recipe.copyWith(
        name: 'Bolo de Cenoura',
        profitMargin: 30.0,
      );

      expect(updated.id, '1');
      expect(updated.name, 'Bolo de Cenoura');
      expect(updated.profitMargin, 30.0);
      expect(updated.operationalCost, 5.0); // Não foi alterado
      expect(updated.category, RecipeCategory.bolo);
    });

    test('RecipeEntity deve inicializar corretamente', () {
      final recipe = RecipeEntity(
        id: '2',
        name: 'Torta de Limão',
        ingredients: [],
        profitMargin: 50.0,
        yieldQuantity: 2,
        totalCost: 15.0,
        suggestedSellPrice: 37.5,
        category: RecipeCategory.torta,
        createdAt: DateTime(2023, 1, 1),
      );

      expect(recipe.name, 'Torta de Limão');
      expect(recipe.yieldQuantity, 2);
      expect(recipe.totalCost, 15.0);
    });
  });
}

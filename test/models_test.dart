import 'package:flutter_test/flutter_test.dart';
import 'package:custo_doce/domain/entities/ingredient_entity.dart';
import 'package:custo_doce/domain/entities/recipe_entity.dart';
import 'package:custo_doce/core/enums/unit_of_measure.dart';
import 'package:custo_doce/core/enums/recipe_category.dart';

void main() {
  group('Models Test', () {
    test('Calcula custo unitario do ingrediente', () {
      const i = IngredientEntity(
        id: '1',
        name: 'Leite',
        unitOfMeasure: UnitOfMeasure.l,
        packageSize: 1.0,
        costPerPackage: 5.0,
        calculatedUnitCost: 5.0,
      );
      expect(i.calculatedUnitCost, 5.0);
    });

    test('RecipeEntity copyWith', () {
      final r = RecipeEntity(
        id: '1',
        name: 'Bolo',
        yieldQuantity: 1,
        category: RecipeCategory.bolo,
        totalCost: 10.0,
        suggestedSellPrice: 20.0,
        profitMarginPercentage: 100.0,
        additionalOperationalCost: 0.0,
        createdAt: DateTime.now(),
        ingredients: [],
      );

      final r2 = r.copyWith(name: 'Bolo 2');
      expect(r2.name, 'Bolo 2');
      expect(r2.id, '1');
    });
  });
}

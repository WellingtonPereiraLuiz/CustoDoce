import 'package:custo_doce/core/enums/assistant_action_type.dart';
import 'package:custo_doce/core/enums/recipe_category.dart';
import 'package:custo_doce/core/enums/unit_of_measure.dart';
import 'package:custo_doce/core/services/assistant_models.dart';
import 'package:custo_doce/domain/entities/ingredient_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Assistant models', () {
    test('IngredientDraft calcula custo unitario', () {
      const draft = IngredientDraft(
        name: 'Farinha',
        unit: UnitOfMeasure.g,
        packageSize: 1000,
        costPerPackage: 8,
        summary: 'Pacote de 1kg',
      );

      expect(draft.calculatedUnitCost, closeTo(0.008, 0.0001));
    });

    test('buildAssistantMetadata guarda intent e preview', () {
      final metadata = buildAssistantMetadata(
        intent: AssistantActionType.createIngredient,
        preview: {'name': 'Acucar'},
      );
      final decoded = decodeAssistantMetadata(metadata);

      expect(decoded?['intent'], 'create_ingredient');
      expect((decoded?['preview'] as Map<String, dynamic>)['name'], 'Acucar');
    });

    test('buildRecipeIngredientEntries usa ids do catalogo', () {
      const draft = RecipeDraft(
        name: 'Bolo simples',
        yieldQuantity: 10,
        category: RecipeCategory.bolo,
        summary: 'Receita basica',
        items: [
          RecipeDraftItem(ingredientId: '1', quantityUsed: 500),
          RecipeDraftItem(ingredientId: '2', quantityUsed: 200),
        ],
        missingIngredients: [],
      );

      const catalog = [
        IngredientEntity(
          id: '1',
          name: 'Farinha',
          unitOfMeasure: UnitOfMeasure.g,
          packageSize: 1000,
          costPerPackage: 8,
          calculatedUnitCost: 0.008,
        ),
        IngredientEntity(
          id: '2',
          name: 'Acucar',
          unitOfMeasure: UnitOfMeasure.g,
          packageSize: 1000,
          costPerPackage: 6,
          calculatedUnitCost: 0.006,
        ),
      ];

      final entries = buildRecipeIngredientEntries(draft, catalog);

      expect(entries.length, 2);
      expect(entries.first.ingredientName, 'Farinha');
      expect(entries.first.calculatedIngredientCost, closeTo(4.0, 0.001));
      expect(entries.last.calculatedIngredientCost, closeTo(1.2, 0.001));
    });

    test('encontra match forte para ingrediente com variacao de caixa', () {
      const catalog = [
        IngredientEntity(
          id: '1',
          name: 'Farinha de Trigo',
          unitOfMeasure: UnitOfMeasure.kg,
          packageSize: 1,
          costPerPackage: 8.5,
          calculatedUnitCost: 8.5,
        ),
      ];

      final match = findBestIngredientMatch('farinha de trigo', catalog);

      expect(match, isNotNull);
      expect(match!.ingredient.id, '1');
      expect(match.score, greaterThanOrEqualTo(0.85));
    });

    test('normaliza acentos e plural na comparacao', () {
      final score = ingredientSimilarityScore(
        'Açúcares refinados',
        'acucar refinado',
      );

      expect(score, greaterThan(0.8));
      expect(normalizeIngredientName('Açúcares refinados'), 'acucar refinado');
    });
  });
}

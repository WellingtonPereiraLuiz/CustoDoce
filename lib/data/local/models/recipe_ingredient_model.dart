import 'package:custo_doce/domain/entities/recipe_ingredient_entity.dart';

class RecipeIngredientModel {
  final String recipeId;
  final String ingredientId;
  final String ingredientName;
  final String ingredientUnit;
  final double quantityUsed;
  final double calculatedIngredientCost;

  const RecipeIngredientModel({
    required this.recipeId,
    required this.ingredientId,
    required this.ingredientName,
    required this.ingredientUnit,
    required this.quantityUsed,
    required this.calculatedIngredientCost,
  });

  factory RecipeIngredientModel.fromMap(Map<String, dynamic> map) {
    return RecipeIngredientModel(
      recipeId: map['recipe_id'] as String,
      ingredientId: map['ingredient_id'] as String,
      ingredientName: map['ingredient_name'] as String? ?? '',
      ingredientUnit: map['ingredient_unit'] as String? ?? '',
      quantityUsed: (map['quantity_used'] as num).toDouble(),
      calculatedIngredientCost:
          (map['calculated_ingredient_cost'] as num).toDouble(),
    );
  }

  factory RecipeIngredientModel.fromEntity(RecipeIngredientEntity entity) {
    return RecipeIngredientModel(
      recipeId: entity.recipeId,
      ingredientId: entity.ingredientId,
      ingredientName: entity.ingredientName,
      ingredientUnit: entity.ingredientUnit,
      quantityUsed: entity.quantityUsed,
      calculatedIngredientCost: entity.calculatedIngredientCost,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'recipe_id': recipeId,
      'ingredient_id': ingredientId,
      'quantity_used': quantityUsed,
      'calculated_ingredient_cost': calculatedIngredientCost,
    };
  }

  RecipeIngredientEntity toEntity() {
    return RecipeIngredientEntity(
      recipeId: recipeId,
      ingredientId: ingredientId,
      ingredientName: ingredientName,
      ingredientUnit: ingredientUnit,
      quantityUsed: quantityUsed,
      calculatedIngredientCost: calculatedIngredientCost,
    );
  }
}

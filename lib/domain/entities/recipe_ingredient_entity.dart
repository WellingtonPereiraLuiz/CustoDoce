class RecipeIngredientEntity {
  final String recipeId;
  final String ingredientId;
  final String ingredientName;
  final String ingredientUnit;
  final double quantityUsed;
  final double calculatedIngredientCost;

  const RecipeIngredientEntity({
    required this.recipeId,
    required this.ingredientId,
    required this.ingredientName,
    required this.ingredientUnit,
    required this.quantityUsed,
    required this.calculatedIngredientCost,
  });

  RecipeIngredientEntity copyWith({
    String? recipeId,
    String? ingredientId,
    String? ingredientName,
    String? ingredientUnit,
    double? quantityUsed,
    double? calculatedIngredientCost,
  }) {
    return RecipeIngredientEntity(
      recipeId: recipeId ?? this.recipeId,
      ingredientId: ingredientId ?? this.ingredientId,
      ingredientName: ingredientName ?? this.ingredientName,
      ingredientUnit: ingredientUnit ?? this.ingredientUnit,
      quantityUsed: quantityUsed ?? this.quantityUsed,
      calculatedIngredientCost:
          calculatedIngredientCost ?? this.calculatedIngredientCost,
    );
  }
}

import 'recipe_ingredient_entity.dart';

class RecipeEntity {
  final String id;
  final String name;
  final double profitMarginPercentage;
  final double additionalOperationalCost;
  final double totalCost;
  final double suggestedSellPrice;
  final DateTime createdAt;
  final List<RecipeIngredientEntity> ingredients;
  final String? userId;

  const RecipeEntity({
    required this.id,
    required this.name,
    required this.profitMarginPercentage,
    required this.additionalOperationalCost,
    required this.totalCost,
    required this.suggestedSellPrice,
    required this.createdAt,
    required this.ingredients,
    this.userId,
  });

  RecipeEntity copyWith({
    String? id,
    String? name,
    double? profitMarginPercentage,
    double? additionalOperationalCost,
    double? totalCost,
    double? suggestedSellPrice,
    DateTime? createdAt,
    List<RecipeIngredientEntity>? ingredients,
    String? userId,
  }) {
    return RecipeEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      profitMarginPercentage:
          profitMarginPercentage ?? this.profitMarginPercentage,
      additionalOperationalCost:
          additionalOperationalCost ?? this.additionalOperationalCost,
      totalCost: totalCost ?? this.totalCost,
      suggestedSellPrice: suggestedSellPrice ?? this.suggestedSellPrice,
      createdAt: createdAt ?? this.createdAt,
      ingredients: ingredients ?? this.ingredients,
      userId: userId ?? this.userId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

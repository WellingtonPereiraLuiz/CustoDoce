import 'package:custo_doce/domain/entities/recipe_entity.dart';
import 'package:custo_doce/domain/entities/recipe_ingredient_entity.dart';

class RecipeModel {
  final String id;
  final String name;
  final double profitMarginPercentage;
  final double additionalOperationalCost;
  final double totalCost;
  final double suggestedSellPrice;
  final int createdAtMs;
  final List<RecipeIngredientEntity> ingredients;

  const RecipeModel({
    required this.id,
    required this.name,
    required this.profitMarginPercentage,
    required this.additionalOperationalCost,
    required this.totalCost,
    required this.suggestedSellPrice,
    required this.createdAtMs,
    required this.ingredients,
  });

  factory RecipeModel.fromMap(
    Map<String, dynamic> map,
    List<RecipeIngredientEntity> ingredients,
  ) {
    return RecipeModel(
      id: map['id'] as String,
      name: map['name'] as String,
      profitMarginPercentage:
          (map['profit_margin_percentage'] as num).toDouble(),
      additionalOperationalCost:
          (map['additional_operational_cost'] as num).toDouble(),
      totalCost: (map['total_cost'] as num).toDouble(),
      suggestedSellPrice: (map['suggested_sell_price'] as num).toDouble(),
      createdAtMs: map['created_at'] as int,
      ingredients: ingredients,
    );
  }

  factory RecipeModel.fromEntity(RecipeEntity entity) {
    return RecipeModel(
      id: entity.id,
      name: entity.name,
      profitMarginPercentage: entity.profitMarginPercentage,
      additionalOperationalCost: entity.additionalOperationalCost,
      totalCost: entity.totalCost,
      suggestedSellPrice: entity.suggestedSellPrice,
      createdAtMs: entity.createdAt.millisecondsSinceEpoch,
      ingredients: entity.ingredients,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'profit_margin_percentage': profitMarginPercentage,
      'additional_operational_cost': additionalOperationalCost,
      'total_cost': totalCost,
      'suggested_sell_price': suggestedSellPrice,
      'created_at': createdAtMs,
    };
  }

  RecipeEntity toEntity() {
    return RecipeEntity(
      id: id,
      name: name,
      profitMarginPercentage: profitMarginPercentage,
      additionalOperationalCost: additionalOperationalCost,
      totalCost: totalCost,
      suggestedSellPrice: suggestedSellPrice,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMs),
      ingredients: ingredients,
    );
  }
}

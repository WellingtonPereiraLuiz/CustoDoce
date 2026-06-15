import 'package:custo_doce/core/enums/recipe_category.dart';
import 'recipe_ingredient_entity.dart';

class RecipeEntity {
  final String id;
  final String name;
  final double profitMarginPercentage;
  final double additionalOperationalCost;
  final double totalCost;
  final double suggestedSellPrice;
  final double? sellingPrice;
  final String? imagePath;
  final bool showInMenu;
  final DateTime createdAt;
  final List<RecipeIngredientEntity> ingredients;
  final String? userId;
  final int yieldQuantity;
  final RecipeCategory category;

  const RecipeEntity({
    required this.id,
    required this.name,
    required this.profitMarginPercentage,
    required this.additionalOperationalCost,
    required this.totalCost,
    required this.suggestedSellPrice,
    this.sellingPrice,
    this.imagePath,
    this.showInMenu = false,
    required this.createdAt,
    required this.ingredients,
    this.userId,
    this.yieldQuantity = 1,
    this.category = RecipeCategory.outro,
  });

  RecipeEntity copyWith({
    String? id,
    String? name,
    double? profitMarginPercentage,
    double? additionalOperationalCost,
    double? totalCost,
    double? suggestedSellPrice,
    double? Function()? sellingPrice,
    String? Function()? imagePath,
    bool? showInMenu,
    DateTime? createdAt,
    List<RecipeIngredientEntity>? ingredients,
    String? userId,
    int? yieldQuantity,
    RecipeCategory? category,
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
      sellingPrice: sellingPrice != null ? sellingPrice() : this.sellingPrice,
      imagePath: imagePath != null ? imagePath() : this.imagePath,
      showInMenu: showInMenu ?? this.showInMenu,
      createdAt: createdAt ?? this.createdAt,
      ingredients: ingredients ?? this.ingredients,
      userId: userId ?? this.userId,
      yieldQuantity: yieldQuantity ?? this.yieldQuantity,
      category: category ?? this.category,
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

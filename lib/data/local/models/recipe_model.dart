import 'package:custo_doce/core/enums/recipe_category.dart';
import 'package:custo_doce/domain/entities/recipe_entity.dart';
import 'package:custo_doce/domain/entities/recipe_ingredient_entity.dart';

class RecipeModel {
  final String id;
  final String name;
  final double profitMarginPercentage;
  final double additionalOperationalCost;
  final double totalCost;
  final double suggestedSellPrice;
  final double? sellingPrice;
  final String? imagePath;
  final bool showInMenu;
  final int createdAtMs;
  final List<RecipeIngredientEntity> ingredients;
  final String? userId;
  final int yieldQuantity;
  final RecipeCategory category;

  const RecipeModel({
    required this.id,
    required this.name,
    required this.profitMarginPercentage,
    required this.additionalOperationalCost,
    required this.totalCost,
    required this.suggestedSellPrice,
    this.sellingPrice,
    this.imagePath,
    this.showInMenu = false,
    required this.createdAtMs,
    required this.ingredients,
    this.userId,
    this.yieldQuantity = 1,
    this.category = RecipeCategory.outro,
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
      sellingPrice: map['selling_price'] != null
          ? (map['selling_price'] as num).toDouble()
          : null,
      imagePath: map['image_path'] as String?,
      showInMenu: (map['show_in_menu'] as int? ?? 0) == 1,
      createdAtMs: map['created_at'] as int,
      userId: map['user_id'] as String?,
      yieldQuantity: map['yield_quantity'] as int? ?? 1,
      category:
          RecipeCategory.fromString(map['category'] as String? ?? 'outro'),
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
      sellingPrice: entity.sellingPrice,
      imagePath: entity.imagePath,
      showInMenu: entity.showInMenu,
      createdAtMs: entity.createdAt.millisecondsSinceEpoch,
      userId: entity.userId,
      yieldQuantity: entity.yieldQuantity,
      category: entity.category,
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
      'selling_price': sellingPrice,
      'image_path': imagePath,
      'show_in_menu': showInMenu ? 1 : 0,
      'created_at': createdAtMs,
      'user_id': userId,
      'yield_quantity': yieldQuantity,
      'category': category.name,
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
      sellingPrice: sellingPrice,
      imagePath: imagePath,
      showInMenu: showInMenu,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMs),
      userId: userId,
      yieldQuantity: yieldQuantity,
      category: category,
      ingredients: ingredients,
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:custo_doce/core/utils/uuid_generator.dart';
import 'package:custo_doce/domain/entities/ingredient_entity.dart';
import 'package:custo_doce/domain/entities/recipe_entity.dart';
import 'package:custo_doce/core/enums/recipe_category.dart';
import 'package:custo_doce/domain/entities/recipe_ingredient_entity.dart';

class RecipeBuilderState {
  final String? editingRecipeId;
  final String name;
  final List<RecipeIngredientEntity> ingredients;
  final int yieldQuantity;
  final RecipeCategory category;
  
  // Costs
  final double fixedOperationalCost;
  final double invisibleCostPercentage;
  final bool useInvisibleCost;

  // Pricing
  final bool useMarkup;
  final double markupMultiplier;
  final double profitMarginPercentage;

  // Investment
  final bool useInvestment;
  final double investmentPercentage;

  final bool isSaving;
  final String? errorMessage;

  const RecipeBuilderState({
    this.editingRecipeId,
    this.name = '',
    this.ingredients = const [],
    this.yieldQuantity = 1,
    this.category = RecipeCategory.outro,
    this.fixedOperationalCost = 0.0,
    this.invisibleCostPercentage = 20.0,
    this.useInvisibleCost = true,
    this.useMarkup = false,
    this.markupMultiplier = 3.0,
    this.profitMarginPercentage = 50.0,
    this.useInvestment = false,
    this.investmentPercentage = 10.0,
    this.isSaving = false,
    this.errorMessage,
  });

  double get totalIngredientsCost =>
      ingredients.fold(0.0, (sum, i) => sum + i.calculatedIngredientCost);

  double get invisibleCost =>
      useInvisibleCost ? (totalIngredientsCost * (invisibleCostPercentage / 100)) : 0.0;

  double get totalCost => totalIngredientsCost + fixedOperationalCost + invisibleCost;

  double get finalPrice {
    if (totalCost == 0) return 0.0;
    if (useMarkup) {
      return totalCost * markupMultiplier;
    } else {
      return totalCost * (1 + profitMarginPercentage / 100);
    }
  }

  double get grossProfit => finalPrice - totalCost;

  double get investmentValue =>
      useInvestment ? (grossProfit * (investmentPercentage / 100)) : 0.0;

  double get netProfit => grossProfit - investmentValue;

  double get effectiveMargin =>
      totalCost > 0 ? (grossProfit / totalCost) * 100 : 0.0;

  RecipeBuilderState copyWith({
    String? editingRecipeId,
    String? name,
    List<RecipeIngredientEntity>? ingredients,
    int? yieldQuantity,
    RecipeCategory? category,
    double? fixedOperationalCost,
    double? invisibleCostPercentage,
    bool? useInvisibleCost,
    bool? useMarkup,
    double? markupMultiplier,
    double? profitMarginPercentage,
    bool? useInvestment,
    double? investmentPercentage,
    bool? isSaving,
    String? errorMessage,
  }) {
    return RecipeBuilderState(
      editingRecipeId: editingRecipeId ?? this.editingRecipeId,
      name: name ?? this.name,
      ingredients: ingredients ?? this.ingredients,
      yieldQuantity: yieldQuantity ?? this.yieldQuantity,
      category: category ?? this.category,
      fixedOperationalCost: fixedOperationalCost ?? this.fixedOperationalCost,
      invisibleCostPercentage: invisibleCostPercentage ?? this.invisibleCostPercentage,
      useInvisibleCost: useInvisibleCost ?? this.useInvisibleCost,
      useMarkup: useMarkup ?? this.useMarkup,
      markupMultiplier: markupMultiplier ?? this.markupMultiplier,
      profitMarginPercentage: profitMarginPercentage ?? this.profitMarginPercentage,
      useInvestment: useInvestment ?? this.useInvestment,
      investmentPercentage: investmentPercentage ?? this.investmentPercentage,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
    );
  }
}

class RecipeBuilderNotifier extends Notifier<RecipeBuilderState> {
  @override
  RecipeBuilderState build() => const RecipeBuilderState();

  void setName(String name) => state = state.copyWith(name: name);
  void setYieldQuantity(int yieldQuantity) => state = state.copyWith(yieldQuantity: yieldQuantity);
  void setCategory(RecipeCategory category) => state = state.copyWith(category: category);
  void setFixedCost(double cost) => state = state.copyWith(fixedOperationalCost: cost);
  void setInvisibleCostPercentage(double pct) => state = state.copyWith(invisibleCostPercentage: pct);
  void toggleInvisibleCost(bool val) => state = state.copyWith(useInvisibleCost: val);
  
  void toggleMarkup(bool val) => state = state.copyWith(useMarkup: val);
  void setMarkupMultiplier(double mult) => state = state.copyWith(markupMultiplier: mult);
  void setProfitMargin(double margin) => state = state.copyWith(profitMarginPercentage: margin);

  void toggleInvestment(bool val) => state = state.copyWith(useInvestment: val);
  void setInvestmentPercentage(double pct) => state = state.copyWith(investmentPercentage: pct);

  void addIngredient(IngredientEntity ingredient, double quantityUsed) {
    final cost = quantityUsed * ingredient.calculatedUnitCost;
    final existing = state.ingredients.indexWhere((i) => i.ingredientId == ingredient.id);
    final updated = List<RecipeIngredientEntity>.from(state.ingredients);
    final entry = RecipeIngredientEntity(
      recipeId: state.editingRecipeId ?? '',
      ingredientId: ingredient.id,
      ingredientName: ingredient.name,
      ingredientUnit: ingredient.unitOfMeasure.label,
      quantityUsed: quantityUsed,
      calculatedIngredientCost: cost,
    );
    if (existing >= 0) {
      updated[existing] = entry;
    } else {
      updated.add(entry);
    }
    state = state.copyWith(ingredients: updated);
  }

  void removeIngredient(String ingredientId) {
    state = state.copyWith(
        ingredients: state.ingredients.where((i) => i.ingredientId != ingredientId).toList());
  }

  void loadRecipeForEdit(RecipeEntity recipe) {
    state = RecipeBuilderState(
      editingRecipeId: recipe.id,
      name: recipe.name,
      yieldQuantity: recipe.yieldQuantity,
      category: recipe.category,
      fixedOperationalCost: recipe.additionalOperationalCost,
      ingredients: recipe.ingredients,
      useInvisibleCost: recipe.additionalOperationalCost > 0,
      useMarkup: recipe.profitMarginPercentage >= 100.0,
      markupMultiplier: recipe.profitMarginPercentage >= 100.0 ? (recipe.profitMarginPercentage / 100.0) + 1.0 : 3.0,
      profitMarginPercentage: recipe.profitMarginPercentage < 100.0 ? recipe.profitMarginPercentage : 50.0,
      useInvestment: false, // Cannot be derived, defaults to false
    );
  }

  void reset() => state = const RecipeBuilderState();

  RecipeEntity buildRecipeEntity() {
    final id = state.editingRecipeId ?? generateUuid();
    return RecipeEntity(
      id: id,
      name: state.name,
      yieldQuantity: state.yieldQuantity,
      category: state.category,
      profitMarginPercentage: state.effectiveMargin,
      additionalOperationalCost: state.fixedOperationalCost + state.invisibleCost,
      totalCost: state.totalCost,
      suggestedSellPrice: state.finalPrice,
      createdAt: DateTime.now(),
      ingredients: state.ingredients.map((i) => i.copyWith(recipeId: id)).toList(),
    );
  }
}

final recipeBuilderProvider = NotifierProvider<RecipeBuilderNotifier, RecipeBuilderState>(
  RecipeBuilderNotifier.new,
);

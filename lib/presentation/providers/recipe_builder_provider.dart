import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:custo_doce/core/utils/uuid_generator.dart';
import 'package:custo_doce/domain/entities/ingredient_entity.dart';
import 'package:custo_doce/domain/entities/recipe_entity.dart';
import 'package:custo_doce/domain/entities/recipe_ingredient_entity.dart';

class RecipeBuilderState {
  final String? editingRecipeId;
  final String name;
  final double profitMarginPercentage;
  final double additionalOperationalCost;
  final List<RecipeIngredientEntity> ingredients;
  final bool isSaving;
  final String? errorMessage;

  const RecipeBuilderState({
    this.editingRecipeId,
    this.name = '',
    this.profitMarginPercentage = 0.0,
    this.additionalOperationalCost = 0.0,
    this.ingredients = const [],
    this.isSaving = false,
    this.errorMessage,
  });

  double get totalIngredientsCost =>
      ingredients.fold(0.0, (sum, i) => sum + i.calculatedIngredientCost);

  double get totalCost => totalIngredientsCost + additionalOperationalCost;

  double get suggestedSellPrice =>
      totalCost * (1 + profitMarginPercentage / 100);

  RecipeBuilderState copyWith({
    String? editingRecipeId,
    String? name,
    double? profitMarginPercentage,
    double? additionalOperationalCost,
    List<RecipeIngredientEntity>? ingredients,
    bool? isSaving,
    String? errorMessage,
  }) {
    return RecipeBuilderState(
      editingRecipeId: editingRecipeId ?? this.editingRecipeId,
      name: name ?? this.name,
      profitMarginPercentage:
          profitMarginPercentage ?? this.profitMarginPercentage,
      additionalOperationalCost:
          additionalOperationalCost ?? this.additionalOperationalCost,
      ingredients: ingredients ?? this.ingredients,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
    );
  }
}

class RecipeBuilderNotifier extends Notifier<RecipeBuilderState> {
  @override
  RecipeBuilderState build() => const RecipeBuilderState();

  void setName(String name) {
    state = state.copyWith(name: name);
  }

  void setProfitMargin(double margin) {
    state = state.copyWith(profitMarginPercentage: margin);
  }

  void setOperationalCost(double cost) {
    state = state.copyWith(additionalOperationalCost: cost);
  }

  void addIngredient(IngredientEntity ingredient, double quantityUsed) {
    final cost = quantityUsed * ingredient.calculatedUnitCost;
    final existing = state.ingredients
        .indexWhere((i) => i.ingredientId == ingredient.id);
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
    final updated = state.ingredients
        .where((i) => i.ingredientId != ingredientId)
        .toList();
    state = state.copyWith(ingredients: updated);
  }

  void loadRecipeForEdit(RecipeEntity recipe) {
    state = RecipeBuilderState(
      editingRecipeId: recipe.id,
      name: recipe.name,
      profitMarginPercentage: recipe.profitMarginPercentage,
      additionalOperationalCost: recipe.additionalOperationalCost,
      ingredients: recipe.ingredients,
    );
  }

  void reset() {
    state = const RecipeBuilderState();
  }

  RecipeEntity buildRecipeEntity() {
    final id = state.editingRecipeId ?? generateUuid();
    return RecipeEntity(
      id: id,
      name: state.name,
      profitMarginPercentage: state.profitMarginPercentage,
      additionalOperationalCost: state.additionalOperationalCost,
      totalCost: state.totalCost,
      suggestedSellPrice: state.suggestedSellPrice,
      createdAt: DateTime.now(),
      ingredients: state.ingredients
          .map((i) => i.copyWith(recipeId: id))
          .toList(),
    );
  }
}

final recipeBuilderProvider =
    NotifierProvider<RecipeBuilderNotifier, RecipeBuilderState>(
  RecipeBuilderNotifier.new,
);

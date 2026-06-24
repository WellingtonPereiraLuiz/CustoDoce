import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:custo_doce/domain/entities/recipe_entity.dart';
import 'package:custo_doce/domain/repositories/recipe_repository.dart';
import 'package:custo_doce/presentation/providers/repository_providers.dart';
import 'package:custo_doce/core/providers/subscription_provider.dart';

class RecipesNotifier extends AsyncNotifier<List<RecipeEntity>> {
  late RecipeRepository _repository;

  @override
  Future<List<RecipeEntity>> build() async {
    _repository = ref.watch(recipeRepositoryProvider);
    return _repository.getAllRecipes();
  }

  Future<bool> saveRecipe(RecipeEntity recipe) async {
    try {
      final count = await _repository.getRecipeCount();
      final isPro = ref.read(isProUserProvider);
      if (!isPro && count >= 3) {
        return false; // Triggers paywall
      }
      state = const AsyncValue.loading();
      await _repository.saveRecipe(recipe);
      state = AsyncValue.data(await _repository.getAllRecipes());
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> updateRecipe(RecipeEntity recipe) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateRecipe(recipe);
      state = AsyncValue.data(await _repository.getAllRecipes());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteRecipe(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteRecipe(id);
      state = AsyncValue.data(await _repository.getAllRecipes());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _repository.getAllRecipes());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final recipesProvider =
    AsyncNotifierProvider<RecipesNotifier, List<RecipeEntity>>(
  RecipesNotifier.new,
);

final recipeCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(recipeRepositoryProvider);
  return repository.getRecipeCount();
});

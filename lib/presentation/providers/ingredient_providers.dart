import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:custo_doce/domain/entities/ingredient_entity.dart';
import 'package:custo_doce/domain/repositories/ingredient_repository.dart';
import 'package:custo_doce/presentation/providers/repository_providers.dart';

class IngredientsNotifier extends AsyncNotifier<List<IngredientEntity>> {
  late IngredientRepository _repository;

  @override
  Future<List<IngredientEntity>> build() async {
    _repository = ref.watch(ingredientRepositoryProvider);
    return _repository.getAllIngredients();
  }

  Future<void> saveIngredient(IngredientEntity ingredient) async {
    state = const AsyncValue.loading();
    try {
      await _repository.saveIngredient(ingredient);
      state = AsyncValue.data(await _repository.getAllIngredients());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateIngredient(IngredientEntity ingredient) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateIngredient(ingredient);
      state = AsyncValue.data(await _repository.getAllIngredients());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteIngredient(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteIngredient(id);
      state = AsyncValue.data(await _repository.getAllIngredients());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _repository.getAllIngredients());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final ingredientsProvider =
    AsyncNotifierProvider<IngredientsNotifier, List<IngredientEntity>>(
  IngredientsNotifier.new,
);

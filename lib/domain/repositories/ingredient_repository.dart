import 'package:custo_doce/domain/entities/ingredient_entity.dart';

abstract class IngredientRepository {
  Future<List<IngredientEntity>> getAllIngredients();
  Future<IngredientEntity?> getIngredientById(String id);
  Future<void> saveIngredient(IngredientEntity ingredient);
  Future<void> updateIngredient(IngredientEntity ingredient);
  Future<void> deleteIngredient(String id);
}

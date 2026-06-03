import 'package:custo_doce/domain/entities/recipe_entity.dart';

abstract class RecipeRepository {
  Future<List<RecipeEntity>> getAllRecipes();
  Future<RecipeEntity?> getRecipeById(String id);
  Future<void> saveRecipe(RecipeEntity recipe);
  Future<void> updateRecipe(RecipeEntity recipe);
  Future<void> deleteRecipe(String id);
  Future<int> getRecipeCount();
}

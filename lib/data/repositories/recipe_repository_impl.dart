import 'package:custo_doce/data/local/datasources/local_recipe_datasource.dart';
import 'package:custo_doce/data/local/models/recipe_model.dart';
import 'package:custo_doce/domain/entities/recipe_entity.dart';
import 'package:custo_doce/domain/repositories/recipe_repository.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final LocalRecipeDataSource _localDataSource;

  RecipeRepositoryImpl(this._localDataSource);

  @override
  Future<List<RecipeEntity>> getAllRecipes() async {
    final models = await _localDataSource.getAllRecipes();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<RecipeEntity?> getRecipeById(String id) async {
    final model = await _localDataSource.getRecipeById(id);
    return model?.toEntity();
  }

  @override
  Future<void> saveRecipe(RecipeEntity recipe) async {
    final model = RecipeModel.fromEntity(recipe);
    await _localDataSource.saveRecipe(model);
  }

  @override
  Future<void> updateRecipe(RecipeEntity recipe) async {
    final model = RecipeModel.fromEntity(recipe);
    await _localDataSource.updateRecipe(model);
  }

  @override
  Future<void> deleteRecipe(String id) async {
    await _localDataSource.deleteRecipe(id);
  }

  @override
  Future<int> getRecipeCount() async {
    return await _localDataSource.getRecipeCount();
  }
}

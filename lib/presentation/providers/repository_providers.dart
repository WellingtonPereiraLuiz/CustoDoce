import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:custo_doce/data/local/database/database_helper.dart';
import 'package:custo_doce/data/local/datasources/local_ingredient_datasource.dart';
import 'package:custo_doce/data/local/datasources/local_recipe_datasource.dart';
import 'package:custo_doce/data/repositories/ingredient_repository_impl.dart';
import 'package:custo_doce/data/repositories/recipe_repository_impl.dart';
import 'package:custo_doce/domain/repositories/ingredient_repository.dart';
import 'package:custo_doce/domain/repositories/recipe_repository.dart';

final databaseHelperProvider = Provider<DatabaseHelper>(
  (ref) => DatabaseHelper.instance,
);

final localIngredientDataSourceProvider =
    Provider<LocalIngredientDataSource>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return LocalIngredientDataSourceImpl(dbHelper);
});

final localRecipeDataSourceProvider =
    Provider<LocalRecipeDataSource>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return LocalRecipeDataSourceImpl(dbHelper);
});

final ingredientRepositoryProvider = Provider<IngredientRepository>((ref) {
  final dataSource = ref.watch(localIngredientDataSourceProvider);
  return IngredientRepositoryImpl(dataSource);
});

final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  final dataSource = ref.watch(localRecipeDataSourceProvider);
  return RecipeRepositoryImpl(dataSource);
});

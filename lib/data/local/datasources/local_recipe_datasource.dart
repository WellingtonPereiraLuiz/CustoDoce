import 'package:custo_doce/data/local/database/database_helper.dart';
import 'package:custo_doce/data/local/models/recipe_ingredient_model.dart';
import 'package:custo_doce/data/local/models/recipe_model.dart';
import 'package:sqflite/sqflite.dart';

abstract class LocalRecipeDataSource {
  Future<List<RecipeModel>> getAllRecipes();
  Future<RecipeModel?> getRecipeById(String id);
  Future<void> saveRecipe(RecipeModel model);
  Future<void> updateRecipe(RecipeModel model);
  Future<void> deleteRecipe(String id);
  Future<int> getRecipeCount();
}

class LocalRecipeDataSourceImpl implements LocalRecipeDataSource {
  final DatabaseHelper _dbHelper;

  LocalRecipeDataSourceImpl(this._dbHelper);

  Future<List<RecipeIngredientModel>> _getIngredientsForRecipe(
    Database db,
    String recipeId,
  ) async {
    final maps = await db.rawQuery('''
      SELECT ri.*, i.name as ingredient_name, i.unit_of_measure as ingredient_unit
      FROM recipe_ingredients ri
      INNER JOIN ingredients i ON ri.ingredient_id = i.id
      WHERE ri.recipe_id = ?
    ''', [recipeId]);
    return maps.map((m) => RecipeIngredientModel.fromMap(m)).toList();
  }

  @override
  Future<List<RecipeModel>> getAllRecipes() async {
    final db = await _dbHelper.database;
    final recipeMaps = await db.query('recipes', orderBy: 'created_at DESC');
    final recipes = <RecipeModel>[];
    for (final map in recipeMaps) {
      final id = map['id'] as String;
      final ingredientModels = await _getIngredientsForRecipe(db, id);
      final ingredients = ingredientModels.map((m) => m.toEntity()).toList();
      recipes.add(RecipeModel.fromMap(map, ingredients));
    }
    return recipes;
  }

  @override
  Future<RecipeModel?> getRecipeById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'recipes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    final ingredientModels = await _getIngredientsForRecipe(db, id);
    final ingredients = ingredientModels.map((m) => m.toEntity()).toList();
    return RecipeModel.fromMap(maps.first, ingredients);
  }

  @override
  Future<void> saveRecipe(RecipeModel model) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.insert(
        'recipes',
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      for (final ingredient in model.ingredients) {
        final riModel = RecipeIngredientModel.fromEntity(ingredient);
        await txn.insert(
          'recipe_ingredients',
          riModel.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
  Future<void> updateRecipe(RecipeModel model) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.update(
        'recipes',
        model.toMap(),
        where: 'id = ?',
        whereArgs: [model.id],
      );
      await txn.delete(
        'recipe_ingredients',
        where: 'recipe_id = ?',
        whereArgs: [model.id],
      );
      for (final ingredient in model.ingredients) {
        final riModel = RecipeIngredientModel.fromEntity(ingredient);
        await txn.insert(
          'recipe_ingredients',
          riModel.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
  Future<void> deleteRecipe(String id) async {
    final db = await _dbHelper.database;
    await db.delete('recipes', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<int> getRecipeCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM recipes');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}

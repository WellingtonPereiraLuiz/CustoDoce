import 'package:custo_doce/data/local/database/database_helper.dart';
import 'package:custo_doce/data/local/models/ingredient_model.dart';
import 'package:sqflite/sqflite.dart';

abstract class LocalIngredientDataSource {
  Future<List<IngredientModel>> getAllIngredients();
  Future<IngredientModel?> getIngredientById(String id);
  Future<void> saveIngredient(IngredientModel model);
  Future<void> updateIngredient(IngredientModel model);
  Future<void> deleteIngredient(String id);
}

class LocalIngredientDataSourceImpl implements LocalIngredientDataSource {
  final DatabaseHelper _dbHelper;

  LocalIngredientDataSourceImpl(this._dbHelper);

  @override
  Future<List<IngredientModel>> getAllIngredients() async {
    final db = await _dbHelper.database;
    final maps = await db.query('ingredients', orderBy: 'name ASC');
    return maps.map((m) => IngredientModel.fromMap(m)).toList();
  }

  @override
  Future<IngredientModel?> getIngredientById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'ingredients',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return IngredientModel.fromMap(maps.first);
  }

  @override
  Future<void> saveIngredient(IngredientModel model) async {
    final db = await _dbHelper.database;
    await db.insert(
      'ingredients',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateIngredient(IngredientModel model) async {
    final db = await _dbHelper.database;
    await db.update(
      'ingredients',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [model.id],
    );
  }

  @override
  Future<void> deleteIngredient(String id) async {
    final db = await _dbHelper.database;
    await db.delete('ingredients', where: 'id = ?', whereArgs: [id]);
  }
}

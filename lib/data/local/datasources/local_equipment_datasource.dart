import 'package:custo_doce/data/local/database/database_helper.dart';
import 'package:custo_doce/data/local/models/equipment_model.dart';
import 'package:sqflite/sqflite.dart';

class LocalEquipmentDatasource {
  final DatabaseHelper _databaseHelper;

  LocalEquipmentDatasource(this._databaseHelper);

  Future<List<EquipmentModel>> getAllEquipment() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'equipment',
      orderBy: 'name ASC',
    );
    return maps.map((map) => EquipmentModel.fromMap(map)).toList();
  }

  Future<void> insertEquipment(EquipmentModel equipment) async {
    final db = await _databaseHelper.database;
    await db.insert(
      'equipment',
      equipment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateEquipment(EquipmentModel equipment) async {
    final db = await _databaseHelper.database;
    await db.update(
      'equipment',
      equipment.toMap(),
      where: 'id = ?',
      whereArgs: [equipment.id],
    );
  }

  Future<void> deleteEquipment(String id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      'equipment',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getEquipmentCount() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM equipment');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'custo_doce.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ingredients (
        id TEXT PRIMARY KEY NOT NULL,
        name TEXT NOT NULL,
        unit_of_measure TEXT NOT NULL,
        package_size REAL NOT NULL,
        cost_per_package REAL NOT NULL,
        calculated_unit_cost REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE recipes (
        id TEXT PRIMARY KEY NOT NULL,
        name TEXT NOT NULL,
        profit_margin_percentage REAL NOT NULL DEFAULT 0.0,
        additional_operational_cost REAL NOT NULL DEFAULT 0.0,
        total_cost REAL NOT NULL DEFAULT 0.0,
        suggested_sell_price REAL NOT NULL DEFAULT 0.0,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE recipe_ingredients (
        recipe_id TEXT NOT NULL,
        ingredient_id TEXT NOT NULL,
        quantity_used REAL NOT NULL,
        calculated_ingredient_cost REAL NOT NULL,
        PRIMARY KEY (recipe_id, ingredient_id),
        FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE,
        FOREIGN KEY (ingredient_id) REFERENCES ingredients(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}

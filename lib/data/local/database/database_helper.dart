import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
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
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }
    String path;
    if (kIsWeb) {
      path = 'custo_doce.db';
    } else {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, 'custo_doce.db');
    }
    return await openDatabase(
      path,
      version: 5,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
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
        calculated_unit_cost REAL NOT NULL,
        user_id TEXT
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
        created_at INTEGER NOT NULL,
        user_id TEXT,
        yield_quantity INTEGER NOT NULL DEFAULT 1,
        category TEXT NOT NULL DEFAULT 'outro',
        selling_price REAL,
        image_path TEXT,
        show_in_menu INTEGER DEFAULT 0
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

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE ingredients ADD COLUMN user_id TEXT');
      await db.execute('ALTER TABLE recipes ADD COLUMN user_id TEXT');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE recipes ADD COLUMN yield_quantity INTEGER NOT NULL DEFAULT 1');
      await db.execute("ALTER TABLE recipes ADD COLUMN category TEXT NOT NULL DEFAULT 'outro'");
    }
    if (oldVersion < 5) {
      await db.execute('ALTER TABLE recipes ADD COLUMN selling_price REAL');
      await db.execute('ALTER TABLE recipes ADD COLUMN image_path TEXT');
      await db.execute('ALTER TABLE recipes ADD COLUMN show_in_menu INTEGER DEFAULT 0');
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}

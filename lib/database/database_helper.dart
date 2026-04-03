import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/warranty.dart';

class DatabaseHelper {
  static const String _dbName = 'soyyo.db';
  static const int _dbVersion = 1;
  static const String _tableName = 'warranties';

  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    _instance ??= DatabaseHelper._internal();
    return _instance!;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      return openDatabase(
        _dbName,
        version: _dbVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id TEXT PRIMARY KEY,
        productName TEXT NOT NULL,
        brand TEXT NOT NULL,
        serialNumber TEXT,
        purchaseDate TEXT NOT NULL,
        expirationDate TEXT NOT NULL,
        notes TEXT,
        imagePaths TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      await db.execute('DROP TABLE IF EXISTS $_tableName');
      await _onCreate(db, newVersion);
    }
  }

  Future<String> insertWarranty(Warranty warranty) async {
    final db = await database;
    await db.insert(
      _tableName,
      warranty.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return warranty.id;
  }

  Future<List<Warranty>> getAllWarranties() async {
    final db = await database;
    final maps = await db.query(_tableName, orderBy: 'expirationDate ASC');
    return maps.map((map) => Warranty.fromMap(map)).toList();
  }

  Future<Warranty?> getWarrantyById(String id) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Warranty.fromMap(maps.first);
  }

  Future<int> updateWarranty(Warranty warranty) async {
    final db = await database;
    return db.update(
      _tableName,
      warranty.toMap(),
      where: 'id = ?',
      whereArgs: [warranty.id],
    );
  }

  Future<int> deleteWarranty(String id) async {
    final db = await database;
    return db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Warranty>> getExpiringSoonWarranties() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final thirtyDaysLater =
        DateTime.now().add(const Duration(days: 30)).toIso8601String();
    final maps = await db.query(
      _tableName,
      where: 'expirationDate >= ? AND expirationDate <= ?',
      whereArgs: [now, thirtyDaysLater],
      orderBy: 'expirationDate ASC',
    );
    return maps.map((map) => Warranty.fromMap(map)).toList();
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}

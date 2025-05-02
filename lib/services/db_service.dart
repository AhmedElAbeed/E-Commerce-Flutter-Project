import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/product_model.dart';

class DBService {
  static Database? _db;
  static const String _dbName = 'ecommerce.db';
  static const int _dbVersion = 3;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = join(dir.path, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await _createProductsTable(db);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _addColumnIfNotExists(db, 'products', 'stock', 'INTEGER DEFAULT 0');
    }
    if (oldVersion < 3) {
      await _addColumnIfNotExists(db, 'products', 'isFavorite', 'INTEGER DEFAULT 0');
    }
  }

  Future<void> _createProductsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        price REAL,
        image TEXT,
        stock INTEGER DEFAULT 0,
        isFavorite INTEGER DEFAULT 0
      )
    ''');
  }

  Future<void> _addColumnIfNotExists(Database db, String table, String column, String definition) async {
    final columns = await db.rawQuery('PRAGMA table_info($table)');
    final columnExists = columns.any((c) => c['name'] == column);

    if (!columnExists) {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $definition');
    }
  }

  Future<int> insertProduct(ProductModel product) async {
    final dbClient = await db;
    return await dbClient.insert('products', product.toMap());
  }

  Future<List<ProductModel>> getProducts() async {
    final dbClient = await db;
    final res = await dbClient.query('products');
    return res.map((e) => ProductModel.fromMap(e)).toList();
  }

  Future<int> updateProduct(ProductModel product) async {
    final dbClient = await db;
    return await dbClient.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final dbClient = await db;
    return await dbClient.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<ProductModel?> getProductById(int id) async {
    final dbClient = await db;
    final res = await dbClient.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    return res.isNotEmpty ? ProductModel.fromMap(res.first) : null;
  }

  Future<void> clearProducts() async {
    final dbClient = await db;
    await dbClient.delete('products');
  }
}
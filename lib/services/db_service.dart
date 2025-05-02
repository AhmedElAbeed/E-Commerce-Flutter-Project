import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/product_model.dart';

class DBService {
  static Database? _db;
  static const String _dbName = 'ecommerce.db';
  static const int _dbVersion = 2;

  final Database database;

  DBService(this.database) {
    _db = database;
  }

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
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        price REAL,
        image TEXT,
        stock INTEGER
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE products ADD COLUMN stock INTEGER DEFAULT 0');
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

  Future<void> clearDatabase() async {
    final dbClient = await db;
    await dbClient.delete('products');
  }
}
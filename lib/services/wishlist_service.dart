import 'package:sqflite/sqflite.dart';
import '../models/wishlist_model.dart';

class WishlistService {
  static const String _tableName = 'wishlist';

  final Database db;

  WishlistService(this.db);

  Future<void> createWishlistTable() async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId INTEGER UNIQUE,
        title TEXT,
        price REAL,
        image TEXT
      )
    ''');
  }

  Future<int> addToWishlist(WishlistModel wishlistItem) async {
    return await db.insert(
      _tableName,
      wishlistItem.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<WishlistModel>> getWishlistItems() async {
    final List<Map<String, dynamic>> maps = await db.query(_tableName);
    return List.generate(maps.length, (i) => WishlistModel.fromMap(maps[i]));
  }

  Future<int> removeFromWishlist(int productId) async {
    return await db.delete(
      _tableName,
      where: 'productId = ?',
      whereArgs: [productId],
    );
  }

  Future<bool> isInWishlist(int productId) async {
    final items = await db.query(
      _tableName,
      where: 'productId = ?',
      whereArgs: [productId],
    );
    return items.isNotEmpty;
  }
}
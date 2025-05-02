import 'package:sqflite/sqflite.dart';
import '../models/cart_model.dart';

class CartService {
  static const String _tableName = 'cart';

  final Database db;

  CartService(this.db);

  Future<void> createCartTable() async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId INTEGER UNIQUE,
        title TEXT,
        price REAL,
        quantity INTEGER
      )
    ''');
  }

  Future<int> addToCart(CartModel cartItem) async {
    final existingItem = await db.query(
      _tableName,
      where: 'productId = ?',
      whereArgs: [cartItem.productId],
    );

    if (existingItem.isNotEmpty) {
      final currentQuantity = existingItem.first['quantity'] as int;
      return await db.update(
        _tableName,
        {'quantity': currentQuantity + cartItem.quantity},
        where: 'productId = ?',
        whereArgs: [cartItem.productId],
      );
    } else {
      return await db.insert(_tableName, cartItem.toMap());
    }
  }

  Future<List<CartModel>> getCartItems() async {
    final List<Map<String, dynamic>> maps = await db.query(_tableName);
    return List.generate(maps.length, (i) => CartModel.fromMap(maps[i]));
  }

  Future<int> updateQuantity(int productId, int newQuantity) async {
    return await db.update(
      _tableName,
      {'quantity': newQuantity},
      where: 'productId = ?',
      whereArgs: [productId],
    );
  }

  Future<int> removeFromCart(int productId) async {
    return await db.delete(
      _tableName,
      where: 'productId = ?',
      whereArgs: [productId],
    );
  }

  Future<double> getTotalAmount() async {
    final items = await getCartItems();
    double total = 0.0;
    for (var item in items) {
      total += item.price * item.quantity;
    }
    return total;
  }

  Future<int> clearCart() async {
    return await db.delete(_tableName);
  }
}
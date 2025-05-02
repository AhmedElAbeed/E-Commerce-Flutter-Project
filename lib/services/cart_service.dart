import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import '../models/cart_model.dart';

class CartService {
  static const String _tableName = 'cart';

  final Database db;

  CartService(this.db);

  Future<void> createCartTable() async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_tableName (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          productId INTEGER UNIQUE,
          title TEXT,
          price REAL,
          image TEXT,
          quantity INTEGER
        )
      ''');
    } catch (e) {
      debugPrint('Error creating cart table: $e');
      rethrow;
    }
  }

  Future<int> addToCart(CartModel cartItem) async {
    try {
      // Check if the item already exists in cart
      final existingItems = await db.query(
        _tableName,
        where: 'productId = ?',
        whereArgs: [cartItem.productId],
        limit: 1,
      );

      if (existingItems.isNotEmpty) {
        // Update quantity if item exists
        final currentQuantity = existingItems.first['quantity'] as int;
        return await db.update(
          _tableName,
          {
            'quantity': currentQuantity + cartItem.quantity,
            'price': cartItem.price, // Update price in case it changed
          },
          where: 'productId = ?',
          whereArgs: [cartItem.productId],
        );
      } else {
        // Insert new item
        return await db.insert(
          _tableName,
          cartItem.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } catch (e) {
      debugPrint('Error in addToCart: $e');
      rethrow;
    }
  }

  Future<List<CartModel>> getCartItems() async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(_tableName);
      return List.generate(maps.length, (i) => CartModel.fromMap(maps[i]));
    } catch (e) {
      debugPrint('Error getting cart items: $e');
      return [];
    }
  }

  Future<int> updateQuantity(int productId, int newQuantity) async {
    try {
      return await db.update(
        _tableName,
        {'quantity': newQuantity},
        where: 'productId = ?',
        whereArgs: [productId],
      );
    } catch (e) {
      debugPrint('Error updating quantity: $e');
      rethrow;
    }
  }

  Future<int> removeFromCart(int productId) async {
    try {
      return await db.delete(
        _tableName,
        where: 'productId = ?',
        whereArgs: [productId],
      );
    } catch (e) {
      debugPrint('Error removing from cart: $e');
      rethrow;
    }
  }

  Future<double> getTotalAmount() async {
    try {
      final items = await getCartItems();
      double total = 0.0;
      for (var item in items) {
        total += item.price * item.quantity;
      }
      return total;
    } catch (e) {
      debugPrint('Error calculating total: $e');
      return 0.0;
    }
  }

  Future<int> clearCart() async {
    try {
      return await db.delete(_tableName);
    } catch (e) {
      debugPrint('Error clearing cart: $e');
      rethrow;
    }
  }
}
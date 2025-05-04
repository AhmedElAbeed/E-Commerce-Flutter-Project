import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import '../models/coupon_model.dart';

class CouponService {
  static const String _tableName = 'coupons';

  final Database db;

  CouponService(this.db);

  Future<void> createCouponsTable() async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_tableName (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          code TEXT UNIQUE,
          discountPercentage REAL,
          expiryDate TEXT,
          isActive INTEGER DEFAULT 1
        )
      ''');
    } catch (e) {
      debugPrint('Error creating coupons table: $e');
      rethrow;
    }
  }

  Future<int> addCoupon(CouponModel coupon) async {
    try {
      return await db.insert(
        _tableName,
        coupon.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('Error adding coupon: $e');
      rethrow;
    }
  }

  Future<List<CouponModel>> getAllCoupons() async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(_tableName);
      return List.generate(maps.length, (i) => CouponModel.fromMap(maps[i]));
    } catch (e) {
      debugPrint('Error getting coupons: $e');
      return [];
    }
  }

  Future<CouponModel?> getCouponByCode(String code) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'code = ?',
        whereArgs: [code],
        limit: 1,
      );
      if (maps.isNotEmpty) {
        return CouponModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting coupon by code: $e');
      return null;
    }
  }

  Future<int> updateCoupon(CouponModel coupon) async {
    try {
      return await db.update(
        _tableName,
        coupon.toMap(),
        where: 'id = ?',
        whereArgs: [coupon.id],
      );
    } catch (e) {
      debugPrint('Error updating coupon: $e');
      rethrow;
    }
  }

  Future<int> deactivateCoupon(int id) async {
    try {
      return await db.update(
        _tableName,
        {'isActive': 0},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint('Error deactivating coupon: $e');
      rethrow;
    }
  }

  Future<int> deleteCoupon(int id) async {
    try {
      return await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint('Error deleting coupon: $e');
      rethrow;
    }
  }
}
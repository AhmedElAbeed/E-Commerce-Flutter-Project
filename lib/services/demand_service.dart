import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../models/demand_model.dart';
import '../models/product_model.dart';
import 'db_service.dart';

class DemandService {
  static const String _tableName = 'demands';
  final Database db;
  final DBService dbService;

  DemandService(this.db, this.dbService);

  Future<void> createDemandsTable() async {
    await db.execute(''' 
      CREATE TABLE IF NOT EXISTS $_tableName (
        id TEXT PRIMARY KEY,
        userEmail TEXT,
        products TEXT,
        totalAmount REAL,
        date TEXT,
        couponCode TEXT,
        status TEXT
      )
    ''');
  }

  Future<String> addDemand(DemandModel demand) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      await db.insert(
        _tableName,
        {
          'id': id,
          'userEmail': demand.userEmail,
          'products': jsonEncode(demand.products.map((e) => e.toMap()).toList()),
          'totalAmount': demand.totalAmount,
          'date': demand.date.toIso8601String(),
          'couponCode': demand.couponCode,
          'status': demand.status,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('✅ Demand created with ID: $id');
    } catch (e) {
      print('❌ Error creating demand: $e');
      rethrow;
    }

    return id;
  }

  Future<List<DemandModel>> getUserDemands(String userEmail) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'userEmail = ?',
        whereArgs: [userEmail],
        orderBy: 'date DESC',
      );
      print('📦 Fetched ${maps.length} demands for $userEmail');
      return maps.map((map) => DemandModel.fromMap(map)).toList();
    } catch (e) {
      print('❌ Error fetching user demands: $e');
      rethrow;
    }
  }

  Future<List<DemandModel>> getAllDemands() async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        orderBy: 'date DESC',
      );
      print('📦 Fetched ${maps.length} total demands');
      return maps.map((map) => DemandModel.fromMap(map)).toList();
    } catch (e) {
      print('❌ Error fetching all demands: $e');
      rethrow;
    }
  }

  Future<void> updateDemandStatus(String id, String status) async {
    try {
      await db.update(
        _tableName,
        {'status': status},
        where: 'id = ?',
        whereArgs: [id],
      );
      print('🔄 Demand status updated for ID $id -> $status');

      if (status == 'approved') {
        // Fetch the demand to get product info
        final List<Map<String, dynamic>> result = await db.query(
          _tableName,
          where: 'id = ?',
          whereArgs: [id],
        );

        if (result.isNotEmpty) {
          final demand = DemandModel.fromMap(result.first);
          for (final product in demand.products) {
            final existingProduct = await dbService.getProductById(product.productId);
            if (existingProduct != null) {
              final updatedStock = (existingProduct.stock ?? 0) - product.quantity;
              final updatedProduct = existingProduct.copyWith(
                stock: updatedStock >= 0 ? updatedStock : 0,
              );
              await dbService.updateProduct(updatedProduct);
              print('📉 Reduced stock for product ${product.productId} by ${product.quantity}');
            } else {
              print('⚠️ Product ID ${product.productId} not found');
            }
          }
        }
      }
    } catch (e) {
      print('❌ Error updating demand status: $e');
      rethrow;
    }
  }

  Future<void> fixInvalidProductsData() async {
    try {
      final allDemands = await db.query(_tableName);
      for (final demand in allDemands) {
        if (demand['products'] is String && !demand['products'].toString().startsWith('[')) {
          final fixedProducts = jsonEncode([
            {
              'productId': 1,
              'title': 'Unknown Product',
              'price': 0.0,
              'image': '',
              'quantity': 1
            }
          ]);

          await db.update(
            _tableName,
            {'products': fixedProducts},
            where: 'id = ?',
            whereArgs: [demand['id']],
          );
          print('🛠 Fixed invalid products data for demand ${demand['id']}');
        }
      }
    } catch (e) {
      print('❌ Error fixing invalid products data: $e');
    }
  }
}

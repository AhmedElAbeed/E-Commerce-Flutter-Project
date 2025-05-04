// lib/services/demand_service.dart
import 'package:sqflite/sqflite.dart';
import '../models/demand_model.dart';

class DemandService {
  static const String _tableName = 'demands';

  final Database db;

  DemandService(this.db);

  Future<void> createDemandsTable() async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName (
        id TEXT PRIMARY KEY,
        userEmail TEXT,
        products TEXT, // Stored as JSON string
        totalAmount REAL,
        date TEXT,
        couponCode TEXT,
        status TEXT
      )
    ''');
  }

  Future<String> addDemand(DemandModel demand) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await db.insert(
      _tableName,
      {
        'id': id,
        'userEmail': demand.userEmail,
        'products': demand.products.map((e) => e.toMap()).toList().toString(),
        'totalAmount': demand.totalAmount,
        'date': demand.date.toIso8601String(),
        'couponCode': demand.couponCode,
        'status': demand.status,
      },
    );
    return id;
  }

  Future<List<DemandModel>> getUserDemands(String userEmail) async {
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'userEmail = ?',
      whereArgs: [userEmail],
      orderBy: 'date DESC',
    );
    return maps.map((map) => DemandModel.fromMap(map)).toList();
  }

  Future<List<DemandModel>> getAllDemands() async {
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      orderBy: 'date DESC',
    );
    return maps.map((map) => DemandModel.fromMap(map)).toList();
  }

  Future<void> updateDemandStatus(String id, String status) async {
    await db.update(
      _tableName,
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
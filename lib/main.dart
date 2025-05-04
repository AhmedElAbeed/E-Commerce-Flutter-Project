import 'dart:io';

import 'package:ecommerce/providers/demand_provider.dart';
import 'package:ecommerce/services/demand_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/coupon_provider.dart';
import 'services/db_service.dart';
import 'services/cart_service.dart';
import 'services/wishlist_service.dart';
import 'services/coupon_service.dart';
import 'views/auth/login_page.dart';
import 'views/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'ecommerce.db');

    Database database = await openDatabase(
      path,
      version: 7,
      onCreate: (db, version) async {
        await _createDatabaseTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _handleDatabaseUpgrade(db, oldVersion, newVersion);
      },
    );

    // Initialize services
    final dbService = DBService();
    final cartService = CartService(database);
    final wishlistService = WishlistService(database);
    final couponService = CouponService(database);
    final demandService = DemandService(database);

    // Initialize database tables
    await _verifyAndCreateTables(database);

    // Clear demands table if needed (only for debugging)
    // await demandService.clearAllDemands();

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserAuthProvider()),
          ChangeNotifierProvider(create: (_) => ProductProvider(dbService)),
          ChangeNotifierProvider(create: (_) => CartProvider(cartService)),
          ChangeNotifierProvider(create: (_) => WishlistProvider(wishlistService)),
          ChangeNotifierProvider(create: (_) => CouponProvider(couponService)),
          ChangeNotifierProvider(create: (_) => DemandProvider(demandService)),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e) {
    debugPrint('App initialization error: $e');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Failed to initialize app: $e'),
          ),
        ),
      ),
    );
  }
}
Future<void> _clearDemandsTable(Database db) async {
  try {
    await db.delete('demands');
    debugPrint('Demands table cleared.');
  } catch (e) {
    debugPrint('Error clearing demands table: $e');
  }
}

Future<void> _verifyAndCreateTables(Database db) async {
  await _verifyCartTable(db);
  await _verifyProductsTable(db);
  await _verifyWishlistTable(db);
  await _verifyCouponsTable(db);
  await _verifyDemandsTable(db);
}

Future<void> _verifyDemandsTable(Database db) async {
  try {
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='demands'",
    );
    if (tables.isEmpty) {
      await db.execute('''
        CREATE TABLE demands (
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
  } catch (e) {
    debugPrint('Error verifying demands table: $e');
    rethrow;
  }
}

Future<void> _verifyCartTable(Database db) async {
  final tables = await db.rawQuery(
    "SELECT name FROM sqlite_master WHERE type='table' AND name='cart'",
  );
  if (tables.isEmpty) {
    await db.execute('''
      CREATE TABLE cart (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId INTEGER UNIQUE,
        title TEXT,
        price REAL,
        image TEXT,
        quantity INTEGER
      )
    ''');
  } else {
    final columns = await db.rawQuery('PRAGMA table_info(cart)');
    final columnNames = columns.map((c) => c['name'].toString()).toList();
    if (!columnNames.contains('image')) {
      await db.execute('ALTER TABLE cart ADD COLUMN image TEXT');
    }
  }
}

Future<void> _verifyProductsTable(Database db) async {
  final tables = await db.rawQuery(
    "SELECT name FROM sqlite_master WHERE type='table' AND name='products'",
  );
  if (tables.isEmpty) {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        price REAL,
        image TEXT,
        stock INTEGER DEFAULT 0,
        isFavorite INTEGER DEFAULT 0
      )
    ''');
  } else {
    final columns = await db.rawQuery('PRAGMA table_info(products)');
    final columnNames = columns.map((c) => c['name'].toString()).toList();
    if (!columnNames.contains('stock')) {
      await db.execute('ALTER TABLE products ADD COLUMN stock INTEGER DEFAULT 0');
    }
    if (!columnNames.contains('isFavorite')) {
      await db.execute('ALTER TABLE products ADD COLUMN isFavorite INTEGER DEFAULT 0');
    }
  }
}

Future<void> _verifyWishlistTable(Database db) async {
  final tables = await db.rawQuery(
    "SELECT name FROM sqlite_master WHERE type='table' AND name='wishlist'",
  );
  if (tables.isEmpty) {
    await db.execute('''
      CREATE TABLE wishlist (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId INTEGER UNIQUE,
        title TEXT,
        price REAL,
        image TEXT
      )
    ''');
  }
}

Future<void> _verifyCouponsTable(Database db) async {
  final tables = await db.rawQuery(
    "SELECT name FROM sqlite_master WHERE type='table' AND name='coupons'",
  );
  if (tables.isEmpty) {
    await db.execute('''
      CREATE TABLE coupons (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT UNIQUE,
        discountPercentage REAL,
        expiryDate TEXT,
        isActive INTEGER DEFAULT 1
      )
    ''');
  } else {
    final columns = await db.rawQuery('PRAGMA table_info(coupons)');
    final columnNames = columns.map((c) => c['name'].toString()).toList();
    if (!columnNames.contains('expiryDate')) {
      await db.execute('ALTER TABLE coupons ADD COLUMN expiryDate TEXT');
    }
    if (!columnNames.contains('isActive')) {
      await db.execute('ALTER TABLE coupons ADD COLUMN isActive INTEGER DEFAULT 1');
    }
  }
}

Future<void> _createDatabaseTables(Database db) async {
  await _verifyCartTable(db);
  await _verifyProductsTable(db);
  await _verifyWishlistTable(db);
  await _verifyCouponsTable(db);
  await _verifyDemandsTable(db);
}

Future<void> _handleDatabaseUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    await _addColumnIfNotExists(db, 'products', 'stock', 'INTEGER DEFAULT 0');
  }
  if (oldVersion < 3) {
    await _addColumnIfNotExists(db, 'products', 'isFavorite', 'INTEGER DEFAULT 0');
    await _createTableIfNotExists(db, 'wishlist', '''
      CREATE TABLE wishlist (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId INTEGER UNIQUE,
        title TEXT,
        price REAL,
        image TEXT
      )
    ''');
  }
  if (oldVersion < 4 || oldVersion < 5) {
    await _verifyCartTable(db);
  }
  if (oldVersion < 6) {
    await _verifyCouponsTable(db);
  }
  if (oldVersion < 7) {
    await _verifyDemandsTable(db);
  }
}

Future<void> _addColumnIfNotExists(Database db, String table, String column, String definition) async {
  final columns = await db.rawQuery('PRAGMA table_info($table)');
  final columnExists = columns.any((c) => c['name'] == column);
  if (!columnExists) {
    await db.execute('ALTER TABLE $table ADD COLUMN $column $definition');
  }
}

Future<void> _createTableIfNotExists(Database db, String table, String createSql) async {
  final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='$table'");
  if (tables.isEmpty) {
    await db.execute(createSql);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<UserAuthProvider>(context, listen: false);
    authProvider.syncUserWithFirebase();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final user = snapshot.data;
            if (user != null) {
              return HomeScreen();
            }
            return LoginPage();
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}

import 'dart:io';

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
    // Initialize Firebase first
    await Firebase.initializeApp();

    // Initialize database
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'ecommerce.db');

    // Open database with proper migration handling
    Database database = await openDatabase(
      path,
      version: 6, // Incremented version for coupon support
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

    // Ensure all tables exist with proper schema
    await _verifyAndCreateTables(database);

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserAuthProvider()),
          ChangeNotifierProvider(create: (_) => ProductProvider(dbService)),
          ChangeNotifierProvider(create: (_) => CartProvider(cartService)),
          ChangeNotifierProvider(create: (_) => WishlistProvider(wishlistService)),
          ChangeNotifierProvider(create: (_) => CouponProvider(couponService)),
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

Future<void> _verifyAndCreateTables(Database db) async {
  try {
    // Verify and create all tables if they don't exist
    await _verifyCartTable(db);
    await _verifyProductsTable(db);
    await _verifyWishlistTable(db);
    await _verifyCouponsTable(db);
  } catch (e) {
    debugPrint('Error verifying tables: $e');
    rethrow;
  }
}

Future<void> _verifyCartTable(Database db) async {
  try {
    final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='cart'");

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
  } catch (e) {
    debugPrint('Error verifying cart table: $e');
    rethrow;
  }
}

Future<void> _verifyProductsTable(Database db) async {
  try {
    final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='products'");

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
  } catch (e) {
    debugPrint('Error verifying products table: $e');
    rethrow;
  }
}

Future<void> _verifyWishlistTable(Database db) async {
  try {
    final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='wishlist'");

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
  } catch (e) {
    debugPrint('Error verifying wishlist table: $e');
    rethrow;
  }
}

Future<void> _verifyCouponsTable(Database db) async {
  try {
    final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='coupons'");

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
  } catch (e) {
    debugPrint('Error verifying coupons table: $e');
    rethrow;
  }
}

Future<void> _createDatabaseTables(Database db) async {
  await _verifyCartTable(db);
  await _verifyProductsTable(db);
  await _verifyWishlistTable(db);
  await _verifyCouponsTable(db);
}

Future<void> _handleDatabaseUpgrade(Database db, int oldVersion, int newVersion) async {
  try {
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
    if (oldVersion < 4) {
      await _verifyCartTable(db);
    }
    if (oldVersion < 5) {
      await _verifyCartTable(db);
    }
    if (oldVersion < 6) {
      await _verifyCouponsTable(db);
    }
  } catch (e) {
    debugPrint('Error during database upgrade: $e');
    rethrow;
  }
}

Future<void> _addColumnIfNotExists(Database db, String table, String column, String definition) async {
  try {
    final columns = await db.rawQuery('PRAGMA table_info($table)');
    final columnExists = columns.any((c) => c['name'] == column);

    if (!columnExists) {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $definition');
    }
  } catch (e) {
    debugPrint('Error adding column $column to $table: $e');
    rethrow;
  }
}

Future<void> _createTableIfNotExists(Database db, String table, String createSql) async {
  try {
    final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='$table'");
    if (tables.isEmpty) {
      await db.execute(createSql);
    }
  } catch (e) {
    debugPrint('Error creating table $table: $e');
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the auth provider
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
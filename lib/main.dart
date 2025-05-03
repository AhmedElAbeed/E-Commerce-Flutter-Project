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
import 'services/db_service.dart';
import 'services/cart_service.dart';
import 'services/wishlist_service.dart';
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
      version: 5,
      onCreate: (db, version) async {
        await _createAllTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _handleDatabaseUpgrade(db, oldVersion, newVersion);
      },
    );

    // Initialize services
    final dbService = DBService();
    final cartService = CartService(database);
    final wishlistService = WishlistService(database);

    // Ensure tables exist with proper schema
    await _verifyCartTableSchema(database);
    await wishlistService.createWishlistTable();

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserAuthProvider()),
          ChangeNotifierProvider(create: (_) => ProductProvider(dbService)),
          ChangeNotifierProvider(create: (_) => CartProvider(cartService)),
          ChangeNotifierProvider(create: (_) => WishlistProvider(wishlistService)),
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


Future<void> _verifyCartTableSchema(Database db) async {
  try {
    // Check if cart table exists
    final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='cart'");

    if (tables.isEmpty) {
      // Create new cart table with all columns
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
      // Verify all columns exist
      final columns = await db.rawQuery('PRAGMA table_info(cart)');
      final columnNames = columns.map((c) => c['name'].toString()).toList();

      if (!columnNames.contains('image')) {
        await db.execute('ALTER TABLE cart ADD COLUMN image TEXT');
      }
    }
  } catch (e) {
    debugPrint('Error verifying cart table schema: $e');
    rethrow;
  }
}

Future<void> _createAllTables(Database db) async {
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

  await db.execute('''
    CREATE TABLE IF NOT EXISTS cart (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      productId INTEGER UNIQUE,
      title TEXT,
      price REAL,
      image TEXT,
      quantity INTEGER
    )
  ''');

  await db.execute('''
    CREATE TABLE IF NOT EXISTS wishlist (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      productId INTEGER UNIQUE,
      title TEXT,
      price REAL,
      image TEXT
    )
  ''');
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
  if (oldVersion < 4) {
    await _verifyCartTableSchema(db);
  }
  if (oldVersion < 5) {
    // Any additional migrations for version 5
    await _verifyCartTableSchema(db);
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
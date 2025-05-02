import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/db_service.dart';

class ProductProvider with ChangeNotifier {
  final DBService _dbService = DBService();
  List<ProductModel> _products = [];
  bool _isLoading = false;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _products = await _dbService.getProducts();
    } catch (e) {
      debugPrint('Error loading products: $e');
      _products = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct(ProductModel product) async {
    try {
      await _dbService.insertProduct(product);
      await loadProducts();
    } catch (e) {
      debugPrint('Error adding product: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    try {
      await _dbService.updateProduct(product);
      await loadProducts();
    } catch (e) {
      debugPrint('Error updating product: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await _dbService.deleteProduct(id);
      await loadProducts();
    } catch (e) {
      debugPrint('Error deleting product: $e');
      rethrow;
    }
  }

  Future<void> clearDatabase() async {
    await _dbService.clearDatabase();
    await loadProducts();
  }
}
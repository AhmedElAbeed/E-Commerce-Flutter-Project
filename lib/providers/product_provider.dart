import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/db_service.dart';

class ProductProvider with ChangeNotifier {
  final DBService dbService;
  List<ProductModel> _products = [];
  bool _isLoading = false;

  ProductProvider(this.dbService);

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;

  Future<void> loadProducts() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      _products = await dbService.getProducts();
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
      await dbService.insertProduct(product);
      await loadProducts();
    } catch (e) {
      debugPrint('Error adding product: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    try {
      await dbService.updateProduct(product);
      await loadProducts();
    } catch (e) {
      debugPrint('Error updating product: $e');
      rethrow;
    }
  }

  Future<void> toggleFavorite(int productId) async {
    try {
      final product = _products.firstWhere((p) => p.id == productId);
      product.isFavorite = !product.isFavorite;
      await dbService.updateProduct(product);
      await loadProducts();
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await dbService.deleteProduct(id);
      await loadProducts();
    } catch (e) {
      debugPrint('Error deleting product: $e');
      rethrow;
    }
  }

  Future<void> clearProducts() async {
    await dbService.clearProducts();
    await loadProducts();
  }
}
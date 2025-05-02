import 'package:flutter/material.dart';
import '../models/cart_model.dart';
import '../services/cart_service.dart';

class CartProvider with ChangeNotifier {
  final CartService cartService;
  List<CartModel> _cartItems = [];
  bool _isLoading = false;

  CartProvider(this.cartService);

  List<CartModel> get cartItems => _cartItems;
  bool get isLoading => _isLoading;

  int get totalItems => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get totalAmount => _cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  Future<void> loadCartItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      _cartItems = await cartService.getCartItems();
    } catch (e) {
      debugPrint('Error loading cart items: $e');
      _cartItems = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(CartModel cartItem) async {
    try {
      await cartService.addToCart(cartItem);
      await loadCartItems();
    } catch (e) {
      debugPrint('Error adding to cart: $e');
      rethrow;
    }
  }

  Future<void> updateQuantity(int productId, int newQuantity) async {
    try {
      if (newQuantity > 0) {
        await cartService.updateQuantity(productId, newQuantity);
      } else {
        await removeFromCart(productId);
      }
      await loadCartItems();
    } catch (e) {
      debugPrint('Error updating quantity: $e');
      rethrow;
    }
  }

  Future<void> removeFromCart(int productId) async {
    try {
      await cartService.removeFromCart(productId);
      await loadCartItems();
    } catch (e) {
      debugPrint('Error removing from cart: $e');
      rethrow;
    }
  }

  Future<void> clearCart() async {
    try {
      await cartService.clearCart();
      await loadCartItems();
    } catch (e) {
      debugPrint('Error clearing cart: $e');
      rethrow;
    }
  }
}
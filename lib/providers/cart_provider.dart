import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_model.dart';
import '../services/cart_service.dart';
import '../providers/coupon_provider.dart';

class CartProvider with ChangeNotifier {
  final CartService cartService;
  List<CartModel> _cartItems = [];
  bool _isLoading = false;
  String? _error;

  CartProvider(this.cartService);

  List<CartModel> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalItems => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get totalAmount => _cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  double getDiscountedTotal(BuildContext context) {
    final couponProvider = Provider.of<CouponProvider>(context, listen: false);
    return couponProvider.applyDiscount(totalAmount);
  }

  bool hasDiscount(BuildContext context) {
    return Provider.of<CouponProvider>(context, listen: false).appliedCoupon != null;
  }

  Future<void> loadCartItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cartItems = await cartService.getCartItems();
    } catch (e) {
      _error = 'Failed to load cart items: $e';
      debugPrint(_error);
      _cartItems = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(CartModel cartItem) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await cartService.addToCart(cartItem);
      await loadCartItems();
    } catch (e) {
      _error = 'Failed to add to cart: $e';
      debugPrint(_error);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateQuantity(int productId, int newQuantity) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (newQuantity > 0) {
        await cartService.updateQuantity(productId, newQuantity);
      } else {
        await removeFromCart(productId);
      }
      await loadCartItems();
    } catch (e) {
      _error = 'Failed to update quantity: $e';
      debugPrint(_error);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeFromCart(int productId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await cartService.removeFromCart(productId);
      await loadCartItems();
    } catch (e) {
      _error = 'Failed to remove from cart: $e';
      debugPrint(_error);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      await cartService.clearCart();
      await loadCartItems();
    } catch (e) {
      _error = 'Failed to clear cart: $e';
      debugPrint(_error);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
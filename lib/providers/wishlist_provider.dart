import 'package:flutter/material.dart';
import '../models/wishlist_model.dart';
import '../services/wishlist_service.dart';

class WishlistProvider with ChangeNotifier {
  final WishlistService wishlistService;
  List<WishlistModel> _wishlistItems = [];
  bool _isLoading = false;

  WishlistProvider(this.wishlistService);

  List<WishlistModel> get wishlistItems => _wishlistItems;
  bool get isLoading => _isLoading;

  Future<void> loadWishlist() async {
    _isLoading = true;
    notifyListeners();

    try {
      _wishlistItems = await wishlistService.getWishlistItems();
    } catch (e) {
      debugPrint('Error loading wishlist: $e');
      _wishlistItems = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleWishlist(WishlistModel item) async {
    try {
      if (_wishlistItems.any((i) => i.productId == item.productId)) {
        await wishlistService.removeFromWishlist(item.productId);
      } else {
        await wishlistService.addToWishlist(item);
      }
      await loadWishlist();
    } catch (e) {
      debugPrint('Error toggling wishlist: $e');
      rethrow;
    }
  }

  Future<bool> isInWishlist(int productId) async {
    return await wishlistService.isInWishlist(productId);
  }

  Future<void> removeFromWishlist(int productId) async {
    try {
      await wishlistService.removeFromWishlist(productId);
      await loadWishlist();
    } catch (e) {
      debugPrint('Error removing from wishlist: $e');
      rethrow;
    }
  }
}
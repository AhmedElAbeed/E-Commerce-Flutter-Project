import 'package:flutter/material.dart';
import '../models/coupon_model.dart';
import '../services/coupon_service.dart';

class CouponProvider with ChangeNotifier {
  final CouponService couponService;
  List<CouponModel> _coupons = [];
  CouponModel? _appliedCoupon;
  bool _isLoading = false;
  String? _error;

  CouponProvider(this.couponService);

  List<CouponModel> get coupons => _coupons;
  CouponModel? get appliedCoupon => _appliedCoupon;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCoupons() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _coupons = await couponService.getAllCoupons();
    } catch (e) {
      _error = 'Failed to load coupons: $e';
      debugPrint(_error);
      _coupons = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> applyCoupon(String code) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final coupon = await couponService.getCouponByCode(code);
      if (coupon == null) {
        throw Exception('Coupon not found');
      }
      if (!coupon.isValid) {
        throw Exception('Coupon is expired or inactive');
      }
      _appliedCoupon = coupon;
    } catch (e) {
      _error = e.toString();
      debugPrint(_error);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void removeCoupon() {
    _appliedCoupon = null;
    notifyListeners();
  }

  double applyDiscount(double totalAmount) {
    if (_appliedCoupon == null || !_appliedCoupon!.isValid) {
      return totalAmount;
    }
    return _appliedCoupon!.applyDiscount(totalAmount);
  }

  Future<void> addCoupon(CouponModel coupon) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await couponService.addCoupon(coupon);
      await loadCoupons();
    } catch (e) {
      _error = 'Failed to add coupon: $e';
      debugPrint(_error);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCoupon(CouponModel coupon) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await couponService.updateCoupon(coupon);
      await loadCoupons();
      if (_appliedCoupon?.id == coupon.id) {
        _appliedCoupon = coupon;
      }
    } catch (e) {
      _error = 'Failed to update coupon: $e';
      debugPrint(_error);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deactivateCoupon(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await couponService.deactivateCoupon(id);
      await loadCoupons();
      if (_appliedCoupon?.id == id) {
        _appliedCoupon = null;
      }
    } catch (e) {
      _error = 'Failed to deactivate coupon: $e';
      debugPrint(_error);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCoupon(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await couponService.deleteCoupon(id);
      await loadCoupons();
      if (_appliedCoupon?.id == id) {
        _appliedCoupon = null;
      }
    } catch (e) {
      _error = 'Failed to delete coupon: $e';
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
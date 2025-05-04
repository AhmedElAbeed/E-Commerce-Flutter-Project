import 'package:intl/intl.dart'; // Add this import at the top

class CouponModel {
  final int? id;
  final String code;
  final double discountPercentage;
  final DateTime expiryDate;
  final bool isActive;

  CouponModel({
    this.id,
    required this.code,
    required this.discountPercentage,
    required this.expiryDate,
    this.isActive = true,
  });

  factory CouponModel.fromMap(Map<String, dynamic> map) {
    return CouponModel(
      id: map['id'],
      code: map['code'],
      discountPercentage: map['discountPercentage'],
      expiryDate: DateTime.parse(map['expiryDate']),
      isActive: map['isActive'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'discountPercentage': discountPercentage,
      'expiryDate': expiryDate.toIso8601String(),
      'isActive': isActive ? 1 : 0,
    };
  }

  bool get isValid => isActive && expiryDate.isAfter(DateTime.now());

  double applyDiscount(double totalAmount) {
    if (!isValid) return totalAmount;
    return totalAmount * (1 - discountPercentage / 100);
  }

  String get formattedExpiryDate => DateFormat('MMM dd, yyyy').format(expiryDate);

  CouponModel copyWith({
    int? id,
    String? code,
    double? discountPercentage,
    DateTime? expiryDate,
    bool? isActive,
  }) {
    return CouponModel(
      id: id ?? this.id,
      code: code ?? this.code,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      expiryDate: expiryDate ?? this.expiryDate,
      isActive: isActive ?? this.isActive,
    );
  }
}
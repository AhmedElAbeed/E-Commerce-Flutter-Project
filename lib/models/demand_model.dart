// lib/models/demand_model.dart
class DemandModel {
  final String? id;
  final String userEmail;
  final List<CartItem> products;
  final double totalAmount;
  final DateTime date;
  final String? couponCode;
  final String status; // 'pending', 'approved', 'rejected'

  DemandModel({
    this.id,
    required this.userEmail,
    required this.products,
    required this.totalAmount,
    required this.date,
    this.couponCode,
    this.status = 'pending',
  });

  factory DemandModel.fromMap(Map<String, dynamic> map) {
    return DemandModel(
      id: map['id'],
      userEmail: map['userEmail'],
      products: (map['products'] as List).map((e) => CartItem.fromMap(e)).toList(),
      totalAmount: map['totalAmount'],
      date: DateTime.parse(map['date']),
      couponCode: map['couponCode'],
      status: map['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userEmail': userEmail,
      'products': products.map((e) => e.toMap()).toList(),
      'totalAmount': totalAmount,
      'date': date.toIso8601String(),
      'couponCode': couponCode,
      'status': status,
    };
  }
}

class CartItem {
  final int productId;
  final String title;
  final double price;
  final String image;
  final int quantity;

  CartItem({
    required this.productId,
    required this.title,
    required this.price,
    required this.image,
    required this.quantity,
  });

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      productId: map['productId'],
      title: map['title'],
      price: map['price'],
      image: map['image'],
      quantity: map['quantity'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'title': title,
      'price': price,
      'image': image,
      'quantity': quantity,
    };
  }
}
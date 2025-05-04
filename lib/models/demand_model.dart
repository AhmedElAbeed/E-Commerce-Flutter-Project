import 'dart:convert';

class DemandModel {
  final String? id;
  final String userEmail;
  final List<CartItem> products;
  final double totalAmount;
  final DateTime date;
  final String? couponCode;
  final String status;

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
    final rawProducts = map['products'];
    List<CartItem> parsedProducts = [];

    try {
      if (rawProducts is String) {
        // First try to parse as JSON
        try {
          final decoded = jsonDecode(rawProducts);
          if (decoded is List) {
            parsedProducts = decoded.map((e) => CartItem.fromMap(_ensureStringMap(e))).toList();
          } else if (decoded is Map) {
            // Handle case where it's a single product stored as a map
            parsedProducts = [CartItem.fromMap(_ensureStringMap(decoded))];
          }
        } catch (e) {
          // If JSON decoding fails, try to handle the malformed string
          print('⚠️ JSON decode failed, trying to handle malformed products string');
          parsedProducts = _parseMalformedProductsString(rawProducts.toString());
        }
      } else if (rawProducts is List) {
        parsedProducts = rawProducts.map((e) => CartItem.fromMap(_ensureStringMap(e))).toList();
      }
    } catch (e) {
      print('❌ Error parsing products: $e');
      // Return empty list or default product if parsing fails
      parsedProducts = [
        CartItem(
          productId: 0,
          title: 'Unknown Product',
          price: 0.0,
          image: '',
          quantity: 1,
        )
      ];
    }

    return DemandModel(
      id: map['id']?.toString(),
      userEmail: map['userEmail']?.toString() ?? '',
      products: parsedProducts,
      totalAmount: map['totalAmount'] is double
          ? map['totalAmount']
          : double.tryParse(map['totalAmount']?.toString() ?? '0') ?? 0.0,
      date: DateTime.parse(map['date'].toString()),
      couponCode: map['couponCode']?.toString(),
      status: map['status']?.toString() ?? 'pending',
    );
  }

  static Map<String, dynamic> _ensureStringMap(dynamic map) {
    if (map is Map<String, dynamic>) {
      return map;
    }
    if (map is Map) {
      return Map<String, dynamic>.from(map);
    }
    return {};
  }

  static List<CartItem> _parseMalformedProductsString(String malformedString) {
    // This is a fallback parser for malformed strings
    try {
      // Try to extract values from the malformed string
      final productIdMatch = RegExp(r'productId: (\d+)').firstMatch(malformedString);
      final titleMatch = RegExp(r'title: ([^,]+)').firstMatch(malformedString);
      final priceMatch = RegExp(r'price: ([\d.]+)').firstMatch(malformedString);
      final imageMatch = RegExp(r'image: ([^,}]+)').firstMatch(malformedString);
      final quantityMatch = RegExp(r'quantity: (\d+)').firstMatch(malformedString);

      return [
        CartItem(
          productId: int.parse(productIdMatch?.group(1) ?? '0'),
          title: titleMatch?.group(1)?.trim() ?? 'Unknown',
          price: double.parse(priceMatch?.group(1) ?? '0.0'),
          image: imageMatch?.group(1)?.trim() ?? '',
          quantity: int.parse(quantityMatch?.group(1) ?? '1'),
        )
      ];
    } catch (e) {
      print('❌ Error parsing malformed products string: $e');
      return [
        CartItem(
          productId: 0,
          title: 'Unknown Product',
          price: 0.0,
          image: '',
          quantity: 1,
        )
      ];
    }
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'userEmail': userEmail,
      'products': jsonEncode(products.map((e) => e.toMap()).toList()),
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
      productId: map['productId'] is int
          ? map['productId']
          : int.tryParse(map['productId']?.toString() ?? '0') ?? 0,
      title: map['title']?.toString() ?? 'Unknown',
      price: map['price'] is double
          ? map['price']
          : double.tryParse(map['price']?.toString() ?? '0') ?? 0.0,
      image: map['image']?.toString() ?? '',
      quantity: map['quantity'] is int
          ? map['quantity']
          : int.tryParse(map['quantity']?.toString() ?? '1') ?? 1,
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
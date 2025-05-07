class ProductModel {
  final int? id;
  final String title;
  final String description;
  final double price;
  final String image;
  final int stock;
  bool isFavorite;

  ProductModel({
    this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.image,
    required this.stock,
    this.isFavorite = false,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      image: map['image'] ?? '',
      stock: map['stock'] ?? 0,
      isFavorite: map['isFavorite'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'image': image,
      'stock': stock,
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  ProductModel copyWith({
    int? id,
    String? title,
    String? description,
    double? price,
    String? image,
    int? stock,
    bool? isFavorite,
  }) {
    return ProductModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      image: image ?? this.image,
      stock: stock ?? this.stock,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

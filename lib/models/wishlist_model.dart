class WishlistModel {
  final int? id;
  final int productId;
  final String title;
  final double price;
  final String image;

  WishlistModel({
    this.id,
    required this.productId,
    required this.title,
    required this.price,
    required this.image,
  });

  factory WishlistModel.fromMap(Map<String, dynamic> map) {
    return WishlistModel(
      id: map['id'],
      productId: map['productId'],
      title: map['title'],
      price: map['price'],
      image: map['image'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'title': title,
      'price': price,
      'image': image,
    };
  }
}
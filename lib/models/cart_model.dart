class CartModel {
  int? id;
  int productId;
  String title;
  double price;
  int quantity;

  CartModel({
    this.id,
    required this.productId,
    required this.title,
    required this.price,
    required this.quantity,
  });

  factory CartModel.fromMap(Map<String, dynamic> json) => CartModel(
    id: json['id'],
    productId: json['productId'],
    title: json['title'],
    price: json['price'],
    quantity: json['quantity'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'productId': productId,
    'title': title,
    'price': price,
    'quantity': quantity,
  };
}

import 'dart:convert';
import 'dart:typed_data';

class Product {
  String name;
  String category;
  String price;
  String stock;
  Uint8List? imageBytes;

  Product({
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    this.imageBytes,
  });

  int get stockQuantity => int.tryParse(stock) ?? 0;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'stock': stock,
      'imageBytes': imageBytes == null ? null : base64Encode(imageBytes!),
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    final imageString = json['imageBytes'] as String?;

    return Product(
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? 'Others',
      price: json['price']?.toString() ?? '0',
      stock: json['stock']?.toString() ?? '0',
      imageBytes: imageString == null ? null : base64Decode(imageString),
    );
  }
}

import 'package:pets/models/category.dart';

class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String type;
  final String link;
  final Category category;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.type,
    required this.link,
    required this.category,
  });

  // Factory constructor to create a Product from JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '', // default to empty string if null
      price: json['price'],
      imageUrl: json['image'], // assuming this is the correct field for image URL
      type: json['type'],
      link: json['link'],
      category: Category.fromJson(json['category']),
    );
  }

  // Method to convert a Product to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'type': type,
      'link': link,
      'category': category.toJson(),
    };
  }
}

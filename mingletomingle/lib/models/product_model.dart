import 'dart:convert';

/// Product model representing items in the Mingle to Mingle Service Catalog.
/// Demonstrates JSON Array to Product Mapping.
class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final String category;
  final double rating;
  final String thumbnail;
  final int stock;
  final String brand;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    this.rating = 4.8,
    required this.thumbnail,
    this.stock = 50,
    this.brand = 'Mingle Services',
  });

  /// Factory constructor to map a JSON Object to a [Product] instance.
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? 'Untitled Product',
      description: json['description']?.toString() ?? 'No description provided.',
      price: json['price'] != null
          ? (json['price'] is num
              ? (json['price'] as num).toDouble()
              : double.tryParse(json['price'].toString()) ?? 0.0)
          : 0.0,
      category: json['category']?.toString() ?? 'General',
      rating: json['rating'] != null
          ? (json['rating'] is num
              ? (json['rating'] as num).toDouble()
              : double.tryParse(json['rating'].toString()) ?? 4.5)
          : 4.5,
      thumbnail: json['thumbnail']?.toString() ??
          (json['images'] is List && (json['images'] as List).isNotEmpty
              ? json['images'][0].toString()
              : 'https://images.unsplash.com/photo-1518199266791-5375a83190b7?auto=format&fit=crop&w=400&q=80'),
      stock: json['stock'] is int
          ? json['stock']
          : int.tryParse(json['stock']?.toString() ?? '50') ?? 50,
      brand: json['brand']?.toString() ?? 'Mingle Services',
    );
  }

  /// Converts a [Product] instance into a JSON-compatible Map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      'rating': rating,
      'thumbnail': thumbnail,
      'stock': stock,
      'brand': brand,
    };
  }

  /// JSON Array to Product Mapping:
  /// Maps a dynamic JSON List / Array directly into a `List<Product>`.
  static List<Product> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Maps a raw JSON string containing an array or object with 'products' list.
  static List<Product> fromRawJson(String rawJson) {
    final decoded = json.decode(rawJson);
    if (decoded is List) {
      return fromJsonList(decoded);
    } else if (decoded is Map<String, dynamic> && decoded.containsKey('products')) {
      return fromJsonList(decoded['products'] as List<dynamic>);
    }
    return [];
  }

  /// Helper to create a copy with modified fields.
  Product copyWith({
    int? id,
    String? title,
    String? description,
    double? price,
    String? category,
    double? rating,
    String? thumbnail,
    int? stock,
    String? brand,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      thumbnail: thumbnail ?? this.thumbnail,
      stock: stock ?? this.stock,
      brand: brand ?? this.brand,
    );
  }
}

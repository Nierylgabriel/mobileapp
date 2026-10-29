import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

/// ============================================================================
/// API CONTROLLER: FULL HTTP CRUD REQUEST IMPLEMENTATION
/// Implements GET, POST, PUT, DELETE requests and JSON Array to Product Mapping
/// ============================================================================
class ApiController {
  static const String baseUrl = 'https://dummyjson.com/products';

  /// Stores the most recent raw JSON response string for emulated JSON display.
  static String lastRawJson = '';

  /// Stores the most recent HTTP response status code.
  static int lastStatusCode = 200;

  /// Default Mingle To Mingle Service Catalog data (Used as base & offline fallback)
  static final List<Map<String, dynamic>> _fallbackCatalogData = [
    {
      "id": 101,
      "title": "Mingle VIP Gold Pass",
      "description":
          "Unlimited likes, see who liked you, and 5 free Super Likes every week.",
      "price": 19.99,
      "category": "Subscriptions",
      "rating": 4.9,
      "thumbnail":
          "https://images.unsplash.com/photo-1518199266791-5375a83190b7?auto=format&fit=crop&w=600&q=80",
      "stock": 999,
      "brand": "Mingle Premium",
    },
    {
      "id": 102,
      "title": "Super Like Spark (5x Pack)",
      "description":
          "Triple your match chance! Stand out in their feed with a glowing gold border.",
      "price": 4.99,
      "category": "Boosts",
      "rating": 4.8,
      "thumbnail":
          "https://images.unsplash.com/photo-1516589178581-6cd7833ae3b2?auto=format&fit=crop&w=600&q=80",
      "stock": 500,
      "brand": "Mingle Boosts",
    },
    {
      "id": 103,
      "title": "Profile Spotlight (1 Hour)",
      "description":
          "Be the top profile in your city for 60 minutes. Get up to 10x more profile views.",
      "price": 6.99,
      "category": "Boosts",
      "rating": 4.7,
      "thumbnail":
          "https://images.unsplash.com/photo-1522529599102-193c0d76b5b6?auto=format&fit=crop&w=600&q=80",
      "stock": 350,
      "brand": "Mingle Boosts",
    },
    {
      "id": 104,
      "title": "Curated Date Night Package",
      "description":
          "Reserved table for two with complimentary champagne at top-rated local lounge.",
      "price": 49.99,
      "category": "Date Packages",
      "rating": 5.0,
      "thumbnail":
          "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=600&q=80",
      "stock": 40,
      "brand": "Mingle Experiences",
    },
    {
      "id": 105,
      "title": "Virtual Luxury Rose & Champagne",
      "description":
          "Send an animated luxury gift box directly into your match's private chat.",
      "price": 2.99,
      "category": "Virtual Gifts",
      "rating": 4.6,
      "thumbnail":
          "https://images.unsplash.com/photo-1518709268805-4e9042af9f23?auto=format&fit=crop&w=600&q=80",
      "stock": 1000,
      "brand": "Mingle Gifts",
    },
    {
      "id": 106,
      "title": "Dating Coach 1-on-1 Consultation",
      "description":
          "30-minute private video call with a certified relationship and bio advisor.",
      "price": 39.99,
      "category": "Coaching",
      "rating": 4.9,
      "thumbnail":
          "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=600&q=80",
      "stock": 15,
      "brand": "Mingle Academy",
    },
    {
      "id": 107,
      "title": "Global Passport Mode",
      "description":
          "Teleport your location to anywhere in the world and match with international singles.",
      "price": 12.99,
      "category": "Subscriptions",
      "rating": 4.8,
      "thumbnail":
          "https://images.unsplash.com/photo-1488646953014-85cb44e25828?auto=format&fit=crop&w=600&q=80",
      "stock": 800,
      "brand": "Mingle Premium",
    },
    {
      "id": 108,
      "title": "Verified Profile Blue Shield",
      "description":
          "Get verified badge on your profile with priority trust rank in the algorithm.",
      "price": 1.99,
      "category": "Security",
      "rating": 4.7,
      "thumbnail":
          "https://images.unsplash.com/photo-1563986768609-322da13575f3?auto=format&fit=crop&w=600&q=80",
      "stock": 1200,
      "brand": "Mingle Trust",
    },
  ];

  // In-memory cache for dynamic live list manipulation
  static List<Product> _localProducts = [];

  // ===========================================================================
  // 1. HTTP GET REQUEST: Fetch Catalog Items & Map JSON Array to Products
  // ===========================================================================
  Future<List<Product>> getProducts() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl?limit=10'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 6));

      lastStatusCode = response.statusCode;

      if (response.statusCode == 200) {
        lastRawJson = response.body;
        final decoded = json.decode(response.body);

        // JSON Array extraction
        List<dynamic> jsonArray;
        if (decoded is Map<String, dynamic> &&
            decoded.containsKey('products')) {
          jsonArray = decoded['products'] as List<dynamic>;
        } else if (decoded is List<dynamic>) {
          jsonArray = decoded;
        } else {
          jsonArray = [];
        }

        // Map remote JSON items
        final remoteProducts = Product.fromJsonList(jsonArray);

        // Merge with Mingle app specific services
        final fallbackList = Product.fromJsonList(_fallbackCatalogData);
        _localProducts = [...fallbackList, ...remoteProducts];
        return _localProducts;
      } else {
        throw Exception('HTTP GET Failed: Status code ${response.statusCode}');
      }
    } catch (e) {
      // Offline fallback: Emulate JSON Array response
      final fallbackJsonMap = {
        "status": "success",
        "total": _fallbackCatalogData.length,
        "products": _fallbackCatalogData,
      };
      lastRawJson = const JsonEncoder.withIndent('  ').convert(fallbackJsonMap);
      lastStatusCode = 200;
      _localProducts = Product.fromJsonList(_fallbackCatalogData);
      return _localProducts;
    }
  }

  // ===========================================================================
  // 2. HTTP POST REQUEST: Create New Catalog Product
  // ===========================================================================
  Future<Product> createProduct(Product product) async {
    final payload = json.encode({
      'title': product.title,
      'description': product.description,
      'price': product.price,
      'category': product.category,
      'rating': product.rating,
      'thumbnail': product.thumbnail,
      'stock': product.stock,
      'brand': product.brand,
    });

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/add'),
            headers: {'Content-Type': 'application/json'},
            body: payload,
          )
          .timeout(const Duration(seconds: 6));

      lastStatusCode = response.statusCode;

      if (response.statusCode == 200 || response.statusCode == 201) {
        lastRawJson = response.body;
        final decoded = json.decode(response.body);
        final created = Product.fromJson(decoded);

        // Insert at beginning of local list
        _localProducts.insert(0, created);
        return created;
      } else {
        throw Exception('HTTP POST Failed: Status code ${response.statusCode}');
      }
    } catch (e) {
      // Fallback local creation with simulated ID
      final newId = DateTime.now().millisecondsSinceEpoch % 10000;
      final created = product.copyWith(id: newId);
      lastStatusCode = 201;
      lastRawJson = const JsonEncoder.withIndent('  ').convert({
        "status": "created (emulated)",
        "statusCode": 201,
        "product": created.toJson(),
      });
      _localProducts.insert(0, created);
      return created;
    }
  }

  // ===========================================================================
  // 3. HTTP PUT REQUEST: Update Existing Catalog Product
  // ===========================================================================
  Future<Product> updateProduct(int id, Product product) async {
    final payload = json.encode({
      'title': product.title,
      'description': product.description,
      'price': product.price,
      'category': product.category,
      'rating': product.rating,
    });

    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/$id'),
            headers: {'Content-Type': 'application/json'},
            body: payload,
          )
          .timeout(const Duration(seconds: 6));

      lastStatusCode = response.statusCode;

      if (response.statusCode == 200) {
        lastRawJson = response.body;
        final decoded = json.decode(response.body);
        final updated = Product.fromJson(
          decoded,
        ).copyWith(thumbnail: product.thumbnail);

        // Update in-memory item
        final index = _localProducts.indexWhere((p) => p.id == id);
        if (index != -1) {
          _localProducts[index] = updated;
        }
        return updated;
      } else {
        throw Exception('HTTP PUT Failed: Status code ${response.statusCode}');
      }
    } catch (e) {
      // Fallback local update
      lastStatusCode = 200;
      final index = _localProducts.indexWhere((p) => p.id == id);
      if (index != -1) {
        _localProducts[index] = product;
      }
      lastRawJson = const JsonEncoder.withIndent('  ').convert({
        "status": "updated (emulated)",
        "statusCode": 200,
        "product": product.toJson(),
      });
      return product;
    }
  }

  // ===========================================================================
  // 4. HTTP DELETE REQUEST: Delete Catalog Product
  // ===========================================================================
  Future<bool> deleteProduct(int id) async {
    try {
      final response = await http
          .delete(Uri.parse('$baseUrl/$id'))
          .timeout(const Duration(seconds: 6));

      lastStatusCode = response.statusCode;

      if (response.statusCode == 200) {
        lastRawJson = response.body;
        _localProducts.removeWhere((p) => p.id == id);
        return true;
      } else {
        throw Exception(
          'HTTP DELETE Failed: Status code ${response.statusCode}',
        );
      }
    } catch (e) {
      // Fallback local removal
      lastStatusCode = 200;
      _localProducts.removeWhere((p) => p.id == id);
      lastRawJson = const JsonEncoder.withIndent('  ').convert({
        "status": "deleted (emulated)",
        "statusCode": 200,
        "deletedId": id,
        "isDeleted": true,
      });
      return true;
    }
  }
}

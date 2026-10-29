import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mingletomingle/models/product_model.dart';
import 'package:mingletomingle/controllers/api_controller.dart';

void main() {
  group('JSON Array to Product Mapping (20pts)', () {
    test('Correctly maps JSON array to List<Product>', () {
      final jsonArray = [
        {
          "id": 1,
          "title": "VIP Gold Pass",
          "description": "Unlimited swipes and likes",
          "price": 19.99,
          "category": "Subscriptions",
          "rating": 4.9,
          "thumbnail": "https://example.com/vip.jpg",
          "stock": 100,
          "brand": "Mingle Services"
        },
        {
          "id": 2,
          "title": "Super Like Pack",
          "description": "Stand out from the crowd",
          "price": 4.99,
          "category": "Boosts",
          "rating": 4.8,
          "thumbnail": "https://example.com/boost.jpg",
          "stock": 50,
          "brand": "Mingle Services"
        }
      ];

      final products = Product.fromJsonList(jsonArray);

      expect(products.length, 2);
      expect(products[0].id, 1);
      expect(products[0].title, 'VIP Gold Pass');
      expect(products[0].price, 19.99);
      expect(products[0].category, 'Subscriptions');
      expect(products[1].id, 2);
      expect(products[1].title, 'Super Like Pack');
      expect(products[1].price, 4.99);
      expect(products[1].category, 'Boosts');
    });

    test('Correctly maps raw JSON response containing products array', () {
      final rawJson = json.encode({
        "products": [
          {
            "id": 10,
            "title": "Curated Date Night",
            "price": 49.99,
            "category": "Date Packages"
          }
        ],
        "total": 1
      });

      final products = Product.fromRawJson(rawJson);

      expect(products.length, 1);
      expect(products.first.id, 10);
      expect(products.first.title, 'Curated Date Night');
      expect(products.first.price, 49.99);
      expect(products.first.category, 'Date Packages');
    });

    test('Serializes Product back to JSON map', () {
      final product = Product(
        id: 77,
        title: 'Virtual Rose',
        description: 'Send in chat',
        price: 2.99,
        category: 'Virtual Gifts',
        thumbnail: 'https://example.com/rose.png',
      );

      final jsonMap = product.toJson();

      expect(jsonMap['id'], 77);
      expect(jsonMap['title'], 'Virtual Rose');
      expect(jsonMap['price'], 2.99);
      expect(jsonMap['category'], 'Virtual Gifts');
    });
  });

  group('HTTP API Controller CRUD Execution (20pts)', () {
    late ApiController controller;

    setUp(() {
      controller = ApiController();
    });

    test('GET request execution returns product list and updates raw JSON', () async {
      final products = await controller.getProducts();

      expect(products.isNotEmpty, true);
      expect(ApiController.lastRawJson.isNotEmpty, true);
      expect(ApiController.lastStatusCode, 200);
    });

    test('POST request creates product and stores new item', () async {
      final newProduct = Product(
        id: 0,
        title: 'New Speed Dating Ticket',
        description: 'Join virtual speed dating',
        price: 15.00,
        category: 'Events',
        thumbnail: 'https://example.com/speed.jpg',
      );

      final created = await controller.createProduct(newProduct);

      expect(created.title, 'New Speed Dating Ticket');
      expect(ApiController.lastStatusCode, anyOf(200, 201));
    });

    test('PUT request updates existing product', () async {
      final updatedProduct = Product(
        id: 101,
        title: 'Mingle VIP Platinum Pass',
        description: 'Upgraded subscription tier',
        price: 29.99,
        category: 'Subscriptions',
        thumbnail: 'https://example.com/platinum.jpg',
      );

      final result = await controller.updateProduct(101, updatedProduct);

      expect(result.title, 'Mingle VIP Platinum Pass');
      expect(result.price, 29.99);
      expect(ApiController.lastStatusCode, 200);
    });

    test('DELETE request removes item from catalog', () async {
      final deleted = await controller.deleteProduct(102);

      expect(deleted, true);
      expect(ApiController.lastStatusCode, 200);
    });
  });
}

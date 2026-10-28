import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'product.dart';

class ProductStore {
  ProductStore._();

  static final ProductStore instance = ProductStore._();

  static const String _storageKey = 'dukan_products';

  final List<Product> products = [
    Product(name: 'Coffee', category: 'Drinks', price: '2.50', stock: '25'),
    Product(name: 'Tea', category: 'Drinks', price: '1.80', stock: '40'),
    Product(name: 'Juice', category: 'Drinks', price: '3.00', stock: '15'),
  ];

  Future<void> loadFromStorage(SharedPreferences preferences) async {
    final savedData = preferences.getString(_storageKey);

    if (savedData == null) {
      await saveToStorage(preferences);
      return;
    }

    try {
      final decoded = jsonDecode(savedData) as List<dynamic>;

      products
        ..clear()
        ..addAll(
          decoded.map(
            (item) => Product.fromJson(Map<String, dynamic>.from(item as Map)),
          ),
        );
    } catch (error) {
      // Keep the existing products if saved data cannot be decoded.
      debugPrint('Could not load saved products: $error');
    }
  }

  Future<void> saveToStorage(SharedPreferences preferences) async {
    final encoded = jsonEncode(
      products.map((product) => product.toJson()).toList(),
    );

    final saved = await preferences.setString(_storageKey, encoded);

    if (!saved) {
      throw Exception('Could not save products to local storage.');
    }
  }
}

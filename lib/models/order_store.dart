import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'sale_order.dart';

class OrderStore {
  OrderStore._();

  static final OrderStore instance = OrderStore._();

  static const String _storageKey = 'dukan_orders';

  final List<SaleOrder> orders = [];

  Future<void> loadFromStorage(SharedPreferences preferences) async {
    final savedData = preferences.getString(_storageKey);

    if (savedData == null) {
      await saveToStorage(preferences);
      return;
    }

    try {
      final decoded = jsonDecode(savedData) as List<dynamic>;

      orders
        ..clear()
        ..addAll(
          decoded.map(
            (item) =>
                SaleOrder.fromJson(Map<String, dynamic>.from(item as Map)),
          ),
        );
    } catch (error) {
      debugPrint('Could not load saved orders: $error');
    }
  }

  Future<void> saveToStorage(SharedPreferences preferences) async {
    final encoded = jsonEncode(orders.map((order) => order.toJson()).toList());

    final saved = await preferences.setString(_storageKey, encoded);

    if (!saved) {
      throw Exception('Could not save orders to local storage.');
    }
  }
}

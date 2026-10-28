import 'product.dart';

class SaleOrderItem {
  final Product product;
  final int quantity;

  SaleOrderItem({required this.product, required this.quantity});

  double get total {
    final price = double.tryParse(product.price) ?? 0.0;
    return price * quantity;
  }

  Map<String, dynamic> toJson() {
    return {'product': product.toJson(), 'quantity': quantity};
  }

  factory SaleOrderItem.fromJson(Map<String, dynamic> json) {
    return SaleOrderItem(
      product: Product.fromJson(
        Map<String, dynamic>.from(json['product'] as Map),
      ),
      quantity: json['quantity'] as int? ?? 1,
    );
  }
}

class SaleOrder {
  final String id;
  final DateTime date;
  final List<SaleOrderItem> items;
  final double total;
  final String paymentMethod;

  SaleOrder({
    required this.id,
    required this.date,
    required this.items,
    required this.total,
    required this.paymentMethod,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
      'paymentMethod': paymentMethod,
    };
  }

  factory SaleOrder.fromJson(Map<String, dynamic> json) {
    return SaleOrder(
      id: json['id'] as String? ?? '',
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      items: (json['items'] as List<dynamic>? ?? [])
          .map(
            (item) =>
                SaleOrderItem.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'] as String? ?? 'Cash',
    );
  }
}

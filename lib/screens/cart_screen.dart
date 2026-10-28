import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';
import '../models/sale_order.dart';
import '../models/order_store.dart';
import '../models/product_store.dart';
import 'checkout_screen.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get total {
    final price = double.tryParse(product.price) ?? 0.0;
    return price * quantity;
  }
}

class CartScreen extends StatefulWidget {
  final List<Product> products;

  const CartScreen({super.key, required this.products});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final List<CartItem> cartItems = [];

  void addToCart(Product product) {
    setState(() {
      final existingIndex = cartItems.indexWhere(
        (item) => item.product == product,
      );

      if (existingIndex >= 0) {
        final item = cartItems[existingIndex];

        if (item.quantity < product.stockQuantity) {
          item.quantity++;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Only ${product.stockQuantity} '
                '${product.name} available.',
              ),
            ),
          );
        }
      } else {
        if (product.stockQuantity > 0) {
          cartItems.add(CartItem(product: product));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${product.name} is out of stock.')),
          );
        }
      }
    });
  }

  void increaseQuantity(int index) {
    setState(() {
      final item = cartItems[index];

      if (item.quantity < item.product.stockQuantity) {
        item.quantity++;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Only ${item.product.stockQuantity} '
              '${item.product.name} available.',
            ),
          ),
        );
      }
    });
  }

  void decreaseQuantity(int index) {
    setState(() {
      if (cartItems[index].quantity > 1) {
        cartItems[index].quantity--;
      } else {
        cartItems.removeAt(index);
      }
    });
  }

  void removeItem(int index) {
    setState(() {
      cartItems.removeAt(index);
    });
  }

  double get subtotal {
    double total = 0.0;

    for (final item in cartItems) {
      total += item.total;
    }

    return total;
  }

  Future<void> checkout() async {
    if (cartItems.isEmpty) return;

    // Copy the cart items before opening checkout.
    final saleItems = cartItems
        .map((item) => CartItem(product: item.product, quantity: item.quantity))
        .toList();

    final saleTotal = subtotal;

    final paymentMethod = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CheckoutScreen(cartItems: saleItems, subtotal: saleTotal),
      ),
    );

    if (paymentMethod == null || !mounted) return;

    final now = DateTime.now();

    // Create order items with product details saved for sales history.
    final orderItems = saleItems.map((item) {
      final productSnapshot = Product(
        name: item.product.name,
        category: item.product.category,
        price: item.product.price,
        stock: item.product.stock,
        imageBytes: item.product.imageBytes,
      );

      return SaleOrderItem(product: productSnapshot, quantity: item.quantity);
    }).toList();

    // Deduct sold quantities from the actual products.
    for (final item in saleItems) {
      final remaining = item.product.stockQuantity - item.quantity;

      item.product.stock = remaining.toString();
    }

    // Record the completed sale.
    final order = SaleOrder(
      id: now.millisecondsSinceEpoch.toString(),
      date: now,
      items: orderItems,
      total: saleTotal,
      paymentMethod: paymentMethod,
    );

    OrderStore.instance.orders.add(order);

    setState(() {
      cartItems.clear();
    });

    // Save products and sales to browser storage.
    try {
      final preferences = await SharedPreferences.getInstance();

      await ProductStore.instance.saveToStorage(preferences);
      await OrderStore.instance.saveToStorage(preferences);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sale saved successfully via $paymentMethod.')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Sale completed, but saving failed. Please check storage.',
          ),
        ),
      );

      debugPrint('Error saving sale: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('POS Billing'), centerTitle: true),
      body: Row(
        children: [
          // PRODUCTS
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Products',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.2,
                          ),
                      itemCount: widget.products.length,
                      itemBuilder: (context, index) {
                        final product = widget.products[index];

                        return Card(
                          elevation: 3,
                          child: InkWell(
                            onTap: () => addToCart(product),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (product.imageBytes != null)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.memory(
                                        product.imageBytes!,
                                        height: 70,
                                        width: 70,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  else
                                    const Icon(Icons.shopping_bag, size: 50),
                                  const SizedBox(height: 8),
                                  Text(
                                    product.name,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('£${product.price}'),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Stock: ${product.stockQuantity}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: product.stockQuantity > 0
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const VerticalDivider(width: 1),

          // CART
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cart',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: cartItems.isEmpty
                        ? const Center(
                            child: Text(
                              'Cart is empty',
                              style: TextStyle(fontSize: 18),
                            ),
                          )
                        : ListView.builder(
                            itemCount: cartItems.length,
                            itemBuilder: (context, index) {
                              final item = cartItems[index];
                              final price =
                                  double.tryParse(item.product.price) ?? 0.0;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text('£${price.toStringAsFixed(2)} each'),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          IconButton(
                                            onPressed: () =>
                                                decreaseQuantity(index),
                                            icon: const Icon(Icons.remove),
                                          ),
                                          Text(
                                            '${item.quantity}',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () =>
                                                increaseQuantity(index),
                                            icon: const Icon(Icons.add),
                                          ),
                                          const Spacer(),
                                          Text(
                                            '£${item.total.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: () => removeItem(index),
                                          child: const Text('Remove'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Subtotal',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '£${subtotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: cartItems.isEmpty ? null : checkout,
                      child: const Text(
                        'CHECKOUT',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

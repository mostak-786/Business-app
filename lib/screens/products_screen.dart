import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';
import '../models/product_store.dart';
import 'add_product_screen.dart';
import 'cart_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<Product> get products => ProductStore.instance.products;

  List<Product> filteredProducts = [];

  @override
  void initState() {
    super.initState();
    filteredProducts = List.from(products);
  }

  Future<void> _saveProducts() async {
    final preferences = await SharedPreferences.getInstance();
    await ProductStore.instance.saveToStorage(preferences);
  }

  void searchProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredProducts = List.from(products);
      } else {
        filteredProducts = products.where((product) {
          return product.name.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _addProduct() async {
    final Product? newProduct = await Navigator.push<Product>(
      context,
      MaterialPageRoute(builder: (context) => const AddProductScreen()),
    );

    if (!mounted || newProduct == null) return;

    setState(() {
      products.add(newProduct);
      filteredProducts = List.from(products);
    });

    await _saveProducts();
  }

  Future<void> _editProduct(int index) async {
    final selectedProduct = filteredProducts[index];

    final Product? updatedProduct = await Navigator.push<Product>(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductScreen(product: selectedProduct),
      ),
    );

    if (!mounted || updatedProduct == null) return;

    setState(() {
      final originalIndex = products.indexOf(selectedProduct);

      if (originalIndex != -1) {
        products[originalIndex] = updatedProduct;
      }

      filteredProducts = List.from(products);
    });

    await _saveProducts();
  }

  Future<void> _deleteProduct(int index) async {
    final selectedProduct = filteredProducts[index];

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text(
          'Are you sure you want to delete ${selectedProduct.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    setState(() {
      products.remove(selectedProduct);
      filteredProducts = List.from(products);
    });

    await _saveProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.point_of_sale),
            tooltip: 'POS Billing',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartScreen(products: products),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              onChanged: searchProducts,
              decoration: InputDecoration(
                hintText: 'Search Products',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addProduct,
                icon: const Icon(Icons.add),
                label: const Text('Add Product'),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: filteredProducts.isEmpty
                  ? const Center(
                      child: Text('No products found. Add a product to begin.'),
                    )
                  : ListView.builder(
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 25,
                              backgroundImage: product.imageBytes != null
                                  ? MemoryImage(product.imageBytes!)
                                  : null,
                              child: product.imageBytes == null
                                  ? const Icon(Icons.shopping_bag, size: 30)
                                  : null,
                            ),
                            title: Text(product.name),
                            subtitle: Text(
                              'Category: ${product.category}\n'
                              'Price: £${product.price}\n'
                              'Stock: ${product.stock}',
                            ),
                            isThreeLine: true,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () => _editProduct(index),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _deleteProduct(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

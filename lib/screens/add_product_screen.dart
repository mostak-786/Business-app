import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/product.dart';

class AddProductScreen extends StatefulWidget {
  final Product? product;

  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController stockController;

  Uint8List? selectedImage;

  final ImagePicker _picker = ImagePicker();

  String selectedCategory = "Drinks";

  final List<String> categories = [
    "Drinks",
    "Dairy",
    "Snacks",
    "Bakery",
    "Fruits",
    "Vegetables",
    "Household",
    "Others",
  ];

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.product?.name ?? "");

    priceController = TextEditingController(text: widget.product?.price ?? "");

    stockController = TextEditingController(text: widget.product?.stock ?? "");

    selectedCategory = widget.product?.category ?? "Drinks";

    if (widget.product?.imageBytes != null) {
      selectedImage = Uint8List.fromList(widget.product!.imageBytes!);
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await image.readAsBytes();

      setState(() {
        selectedImage = bytes;
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? "Add Product" : "Edit Product"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Product Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              initialValue: selectedCategory,
              decoration: const InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(),
              ),
              items: categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
            ),

            const SizedBox(height: 15),

            TextField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: "Price",
                prefixText: "£ ",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: stockController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Stock Quantity",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text("Select Image"),
            ),

            const SizedBox(height: 15),

            if (selectedImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  selectedImage!,
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                ),
              )
            else
              const Text("No image selected"),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (nameController.text.trim().isEmpty ||
                      priceController.text.trim().isEmpty ||
                      stockController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please fill all fields")),
                    );
                    return;
                  }

                  final product = Product(
                    name: nameController.text.trim(),
                    category: selectedCategory,
                    price: priceController.text.trim(),
                    stock: stockController.text.trim(),
                    imageBytes: selectedImage,
                  );

                  Navigator.pop(context, product);
                },
                child: Text(
                  widget.product == null ? "Add Product" : "Update Product",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

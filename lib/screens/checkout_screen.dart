import 'package:flutter/material.dart';

import 'cart_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final double subtotal;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.subtotal,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String paymentMethod = 'Cash';

  final TextEditingController amountController = TextEditingController();

  double get amountReceived => double.tryParse(amountController.text) ?? 0.0;

  double get change {
    final result = amountReceived - widget.subtotal;
    return result > 0 ? result : 0.0;
  }

  bool get paymentComplete {
    if (paymentMethod == 'Card') {
      return true;
    }

    return amountReceived >= widget.subtotal;
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  void completeSale() {
    if (!paymentComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter enough cash to complete the payment.'),
        ),
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Sale Complete'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 60),
              const SizedBox(height: 15),
              Text('Total: £${widget.subtotal.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              if (paymentMethod == 'Cash')
                Text('Change: £${change.toStringAsFixed(2)}'),
              const SizedBox(height: 10),
              Text('Payment: $paymentMethod'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Close the success dialog.
                Navigator.pop(dialogContext);

                // Return to the cart with the payment method.
                Navigator.pop(context, paymentMethod);
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            ...widget.cartItems.map((item) {
              final price = double.tryParse(item.product.price) ?? 0.0;

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(item.product.name),
                  subtitle: Text(
                    '${item.quantity} × £${price.toStringAsFixed(2)}',
                  ),
                  trailing: Text(
                    '£${item.total.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }),

            const Divider(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  '£${widget.subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              'Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              initialValue: paymentMethod,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Payment Method',
              ),
              items: const [
                DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                DropdownMenuItem(value: 'Card', child: Text('Card')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    paymentMethod = value;
                  });
                }
              },
            ),

            if (paymentMethod == 'Cash') ...[
              const SizedBox(height: 20),

              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) {
                  setState(() {});
                },
                decoration: const InputDecoration(
                  labelText: 'Amount Received',
                  prefixText: '£ ',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Change',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '£${change.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: paymentComplete ? completeSale : null,
                icon: const Icon(Icons.check),
                label: const Text(
                  'COMPLETE SALE',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

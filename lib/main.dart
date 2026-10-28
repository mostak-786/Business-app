import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/login_screen.dart';
import 'models/product_store.dart';
import 'models/order_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Open browser/device local storage.
  final preferences = await SharedPreferences.getInstance();

  // Load saved products and orders before showing the app.
  await ProductStore.instance.loadFromStorage(preferences);
  await OrderStore.instance.loadFromStorage(preferences);

  runApp(const DukanApp());
}

class DukanApp extends StatelessWidget {
  const DukanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dukan POS',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(),
    );
  }
}

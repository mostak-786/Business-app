import 'package:flutter/material.dart';

import '../models/product.dart';
import '../models/product_store.dart';
import '../models/sale_order.dart';
import '../models/order_store.dart';
import 'products_screen.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';
import 'reports_screen.dart';

const Color navy = Color(0xFF102F55);
const Color blue = Color(0xFF1976D2);
const Color pageBg = Color(0xFFF2F6FC);

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String selectedMenu = 'Dashboard';

  List<Product> get products => ProductStore.instance.products;

  List<SaleOrder> get orders => OrderStore.instance.orders;

  double get totalSales {
    return orders.fold(0.0, (total, order) => total + order.total);
  }

  int get totalOrders => orders.length;

  int get lowStockCount {
    return products.where((product) => product.stockQuantity <= 5).length;
  }

  final List<Map<String, dynamic>> menuItems = [
    {'name': 'Dashboard', 'icon': Icons.dashboard_rounded},
    {'name': 'Products', 'icon': Icons.inventory_2_rounded},
    {'name': 'POS / Cart', 'icon': Icons.shopping_cart_rounded},
    {'name': 'Customers', 'icon': Icons.people_rounded},
    {'name': 'Inventory', 'icon': Icons.warehouse_rounded},
    {'name': 'Orders', 'icon': Icons.receipt_long_rounded},
    {'name': 'Reports', 'icon': Icons.bar_chart_rounded},
    {'name': 'Settings', 'icon': Icons.settings_rounded},
  ];

  Future<void> selectMenu(String name) async {
    setState(() => selectedMenu = name);

    if (name == 'Dashboard') return;

    if (name == 'Products') {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProductsScreen()),
      );
      if (mounted) setState(() {});
      return;
    }

    if (name == 'POS / Cart') {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CartScreen(products: products)),
      );
      if (mounted) setState(() {});
      return;
    }

    if (name == 'Orders') {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const OrdersScreen()),
      );
      if (mounted) setState(() {});
      return;
    }

    if (name == 'Reports') {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ReportsScreen()),
      );
      if (mounted) setState(() {});
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$name will be connected next.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBg,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 800;

          return Row(
            children: [
              if (wide) _buildSidebar(),
              Expanded(
                child: Column(
                  children: [
                    _buildTopBar(wide),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: _buildDashboard(wide),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 220,
      color: navy,
      child: Column(
        children: [
          const SizedBox(height: 25),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.storefront, color: Colors.white, size: 34),
              SizedBox(width: 10),
              Text(
                'Dukan POS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 35),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: menuItems.map((item) {
                final name = item['name'] as String;
                final active = selectedMenu == name;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    selected: active,
                    selectedTileColor: blue,
                    leading: Icon(
                      item['icon'] as IconData,
                      color: Colors.white,
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () => selectMenu(name),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(bool wide) {
    return Container(
      height: 72,
      color: blue,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          if (!wide)
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (sheetContext) {
                    return SafeArea(
                      child: ListView(
                        shrinkWrap: true,
                        children: menuItems.map((item) {
                          final name = item['name'] as String;

                          return ListTile(
                            leading: Icon(item['icon'] as IconData),
                            title: Text(name),
                            selected: selectedMenu == name,
                            onTap: () {
                              Navigator.pop(sheetContext);
                              selectMenu(name);
                            },
                          );
                        }).toList(),
                      ),
                    );
                  },
                );
              },
              icon: const Icon(Icons.menu, color: Colors.white),
            ),
          const Spacer(),
          const Icon(Icons.account_circle, color: Colors.white, size: 34),
          const SizedBox(width: 10),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Dukan POS',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(bool wide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Welcome Back!',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Color(0xFF14243B),
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          "Here's what's happening in your store today.",
          style: TextStyle(color: Colors.blueGrey, fontSize: 16),
        ),
        const SizedBox(height: 25),

        GridView.count(
          crossAxisCount: wide ? 4 : 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: wide ? 1.3 : 1.05,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            SummaryCard(
              title: 'Total Sales',
              value: '£${totalSales.toStringAsFixed(2)}',
              icon: Icons.currency_pound,
              color: const Color(0xFF19AD79),
              background: const Color(0xFFE4F8F0),
            ),
            SummaryCard(
              title: 'Orders',
              value: '$totalOrders',
              icon: Icons.shopping_bag,
              color: const Color(0xFF1976F3),
              background: const Color(0xFFE7F1FF),
            ),
            const SummaryCard(
              title: 'Customers',
              value: '156',
              icon: Icons.people,
              color: Color(0xFF9146E8),
              background: Color(0xFFF2E9FF),
            ),
            SummaryCard(
              title: 'Low Stock',
              value: '$lowStockCount',
              icon: Icons.inventory_2,
              color: const Color(0xFFFF7900),
              background: const Color(0xFFFFF0DF),
            ),
          ],
        ),

        const SizedBox(height: 25),

        if (wide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _salesChart()),
              const SizedBox(width: 16),
              Expanded(child: _categoryCard()),
            ],
          )
        else
          Column(
            children: [
              _salesChart(),
              const SizedBox(height: 16),
              _categoryCard(),
            ],
          ),

        const SizedBox(height: 25),

        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _quickAction(
              'Manage Products',
              Icons.inventory_2,
              const Color(0xFFE2F0FF),
              'Products',
            ),
            _quickAction(
              'POS / Billing',
              Icons.shopping_cart,
              const Color(0xFFE0F8EC),
              'POS / Cart',
            ),
            _quickAction(
              'Customers',
              Icons.people,
              const Color(0xFFF1E7FF),
              'Customers',
            ),
            _quickAction(
              'Inventory',
              Icons.storage,
              const Color(0xFFFFEBD9),
              'Inventory',
            ),
          ],
        ),

        const SizedBox(height: 25),
        _recentSales(),
        const SizedBox(height: 20),
        _lowStock(),
        const SizedBox(height: 25),

        const Center(
          child: Text(
            'Dukan POS  •  Simple. Fast. Reliable.',
            style: TextStyle(color: Colors.blueGrey),
          ),
        ),
      ],
    );
  }

  Widget _salesChart() {
    // Placeholder chart until sales are grouped by day.
    final sales = orders.isEmpty
        ? [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        : List<double>.generate(7, (index) {
            final day = DateTime.now().subtract(Duration(days: 6 - index));

            return orders
                .where(
                  (order) =>
                      order.date.year == day.year &&
                      order.date.month == day.month &&
                      order.date.day == day.day,
                )
                .fold(0.0, (sum, order) => sum + order.total);
          });

    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final maxSales = sales.fold<double>(
      1.0,
      (maximum, amount) => amount > maximum ? amount : maximum,
    );

    return _panel(
      'Sales Overview (Last 7 Days)',
      SizedBox(
        height: 205,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(sales.length, (i) {
            final barHeight = sales[i] == 0 ? 4.0 : (sales[i] / maxSales) * 130;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      sales[i] == 0 ? '£0' : '£${sales[i].toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 10),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: blue.withValues(alpha: 0.8),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      days[DateTime.now()
                              .subtract(Duration(days: 6 - i))
                              .weekday -
                          1],
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _categoryCard() {
    final Map<String, double> totals = {};

    for (final order in orders) {
      for (final item in order.items) {
        final category = item.product.category;
        totals[category] = (totals[category] ?? 0) + item.total;
      }
    }

    final grandTotal = totals.values.fold<double>(
      0,
      (sum, amount) => sum + amount,
    );

    const colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];

    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return _panel(
      'Top Categories',
      entries.isEmpty
          ? const Text(
              'Category sales will appear after your first sale.',
              style: TextStyle(color: Colors.blueGrey),
            )
          : Column(
              children: entries.take(5).toList().asMap().entries.map((entry) {
                final index = entry.key;
                final category = entry.value;
                final percentage = grandTotal == 0
                    ? 0
                    : category.value / grandTotal * 100;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 13,
                        color: colors[index % colors.length],
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(category.key)),
                      Text(
                        '${percentage.toStringAsFixed(0)}%',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _quickAction(
    String title,
    IconData icon,
    Color background,
    String destination,
  ) {
    return SizedBox(
      width: 210,
      child: Card(
        color: background,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: ListTile(
          contentPadding: const EdgeInsets.all(10),
          leading: Icon(icon, color: navy, size: 28),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 15),
          onTap: () => selectMenu(destination),
        ),
      ),
    );
  }

  Widget _recentSales() {
    final recentOrders = orders.reversed.take(5).toList();

    return _panel(
      'Recent Sales',
      recentOrders.isEmpty
          ? const Text(
              'No sales yet. Complete a checkout to see recent sales here.',
              style: TextStyle(color: Colors.blueGrey),
            )
          : Column(
              children: [
                const Row(
                  children: [
                    Expanded(flex: 2, child: Text('Order')),
                    Expanded(flex: 3, child: Text('Items')),
                    Expanded(flex: 2, child: Text('Payment')),
                    Expanded(flex: 2, child: Text('Total')),
                  ],
                ),
                const Divider(),
                ...recentOrders.map((order) {
                  final itemCount = order.items.fold<int>(
                    0,
                    (sum, item) => sum + item.quantity,
                  );

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            order.id.length > 6
                                ? order.id.substring(order.id.length - 6)
                                : order.id,
                          ),
                        ),
                        Expanded(flex: 3, child: Text('$itemCount item(s)')),
                        Expanded(flex: 2, child: Text(order.paymentMethod)),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '£${order.total.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
    );
  }

  Widget _lowStock() {
    final lowStockProducts =
        products.where((product) => product.stockQuantity <= 5).toList()
          ..sort((a, b) => a.stockQuantity.compareTo(b.stockQuantity));

    return _panel(
      'Low Stock Items',
      lowStockProducts.isEmpty
          ? const Text(
              'All products currently have more than 5 units in stock.',
              style: TextStyle(color: Colors.blueGrey),
            )
          : Column(
              children: lowStockProducts.map((product) {
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.inventory_2,
                    color: Colors.deepOrange,
                  ),
                  title: Text(product.name),
                  subtitle: Text('Category: ${product.category}'),
                  trailing: Text(
                    'Stock: ${product.stockQuantity}',
                    style: TextStyle(
                      color: product.stockQuantity == 0
                          ? Colors.red
                          : Colors.deepOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _panel(String title, Widget content) {
    return Card(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 18),
            content,
          ],
        ),
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color background;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: background,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: navy),
            ),
            const SizedBox(height: 5),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

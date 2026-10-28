import 'package:flutter/material.dart';

import '../models/order_store.dart';
import '../models/sale_order.dart';

enum ReportPeriod { today, last7Days, last30Days, allTime }

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  ReportPeriod selectedPeriod = ReportPeriod.last7Days;

  List<SaleOrder> get filteredOrders {
    final orders = OrderStore.instance.orders.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final now = DateTime.now();

    return orders.where((order) {
      switch (selectedPeriod) {
        case ReportPeriod.today:
          return order.date.year == now.year &&
              order.date.month == now.month &&
              order.date.day == now.day;

        case ReportPeriod.last7Days:
          final start = DateTime(
            now.year,
            now.month,
            now.day,
          ).subtract(const Duration(days: 6));
          return !order.date.isBefore(start) && !order.date.isAfter(now);

        case ReportPeriod.last30Days:
          final start = DateTime(
            now.year,
            now.month,
            now.day,
          ).subtract(const Duration(days: 29));
          return !order.date.isBefore(start) && !order.date.isAfter(now);

        case ReportPeriod.allTime:
          return true;
      }
    }).toList();
  }

  double get totalRevenue =>
      filteredOrders.fold(0.0, (sum, order) => sum + order.total);

  double get averageOrderValue =>
      filteredOrders.isEmpty ? 0 : totalRevenue / filteredOrders.length;

  int get unitsSold => filteredOrders.fold(
    0,
    (sum, order) =>
        sum + order.items.fold(0, (quantity, item) => quantity + item.quantity),
  );

  Map<String, int> get bestSellingProducts {
    final totals = <String, int>{};

    for (final order in filteredOrders) {
      for (final item in order.items) {
        totals[item.product.name] =
            (totals[item.product.name] ?? 0) + item.quantity;
      }
    }

    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(entries.take(5));
  }

  Map<String, double> get paymentBreakdown {
    final totals = <String, double>{};

    for (final order in filteredOrders) {
      totals[order.paymentMethod] =
          (totals[order.paymentMethod] ?? 0) + order.total;
    }

    return totals;
  }

  List<MapEntry<String, double>> get dailyRevenue {
    final now = DateTime.now();
    final days = <MapEntry<String, double>>[];

    final numberOfDays = selectedPeriod == ReportPeriod.today ? 1 : 7;

    for (int i = numberOfDays - 1; i >= 0; i--) {
      final day = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i));

      double revenue = 0;

      for (final order in filteredOrders) {
        if (order.date.year == day.year &&
            order.date.month == day.month &&
            order.date.day == day.day) {
          revenue += order.total;
        }
      }

      const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final label = '${weekdays[day.weekday - 1]} ${day.day}';

      days.add(MapEntry(label, revenue));
    }

    return days;
  }

  String get periodLabel {
    switch (selectedPeriod) {
      case ReportPeriod.today:
        return 'Today';
      case ReportPeriod.last7Days:
        return 'Last 7 days';
      case ReportPeriod.last30Days:
        return 'Last 30 days';
      case ReportPeriod.allTime:
        return 'All time';
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = filteredOrders;
    final daily = dailyRevenue;
    final maxRevenue = daily.fold<double>(
      0,
      (maximum, entry) => entry.value > maximum ? entry.value : maximum,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Reports & Analytics'),
        actions: [
          IconButton(
            tooltip: 'Refresh reports',
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Sales overview',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text('Track your shop performance and completed sales.'),
          const SizedBox(height: 20),

          DropdownButtonFormField<ReportPeriod>(
            initialValue: selectedPeriod,
            decoration: const InputDecoration(
              labelText: 'Report period',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: ReportPeriod.today, child: Text('Today')),
              DropdownMenuItem(
                value: ReportPeriod.last7Days,
                child: Text('Last 7 days'),
              ),
              DropdownMenuItem(
                value: ReportPeriod.last30Days,
                child: Text('Last 30 days'),
              ),
              DropdownMenuItem(
                value: ReportPeriod.allTime,
                child: Text('All time'),
              ),
            ],
            onChanged: (period) {
              if (period != null) {
                setState(() => selectedPeriod = period);
              }
            },
          ),

          const SizedBox(height: 16),

          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 650 ? 4 : 2;
              final cardWidth =
                  (constraints.maxWidth - (columns - 1) * 12) / columns;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: _StatCard(
                      title: 'Revenue',
                      value: '£${totalRevenue.toStringAsFixed(2)}',
                      icon: Icons.currency_pound,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _StatCard(
                      title: 'Orders',
                      value: '${orders.length}',
                      icon: Icons.receipt_long,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _StatCard(
                      title: 'Average order',
                      value: '£${averageOrderValue.toStringAsFixed(2)}',
                      icon: Icons.shopping_bag,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _StatCard(
                      title: 'Units sold',
                      value: '$unitsSold',
                      icon: Icons.inventory_2,
                      color: Colors.purple,
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 28),

          const Text(
            'Daily revenue',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: daily.every((entry) => entry.value == 0)
                  ? const SizedBox(
                      height: 130,
                      child: Center(
                        child: Text('No sales recorded for this chart yet.'),
                      ),
                    )
                  : Column(
                      children: daily.map((entry) {
                        final fraction = maxRevenue > 0
                            ? entry.value / maxRevenue
                            : 0.0;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 65,
                                child: Text(
                                  entry.key,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: fraction,
                                    minHeight: 22,
                                    backgroundColor: Colors.grey.shade200,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 76,
                                child: Text(
                                  '£${entry.value.toStringAsFixed(2)}',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ),

          const SizedBox(height: 28),

          const Text(
            'Best-selling products',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Card(
            child: bestSellingProducts.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No product sales found for this period.'),
                  )
                : Column(
                    children: bestSellingProducts.entries.map((entry) {
                      return ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.inventory_2),
                        ),
                        title: Text(entry.key),
                        trailing: Text(
                          '${entry.value} sold',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    }).toList(),
                  ),
          ),

          const SizedBox(height: 28),

          const Text(
            'Payment breakdown',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Card(
            child: paymentBreakdown.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No payment data available yet.'),
                  )
                : Column(
                    children: paymentBreakdown.entries.map((entry) {
                      final percentage = totalRevenue > 0
                          ? entry.value / totalRevenue * 100
                          : 0.0;

                      return ListTile(
                        leading: const Icon(Icons.payments),
                        title: Text(entry.key),
                        subtitle: Text(
                          '${percentage.toStringAsFixed(1)}% of revenue',
                        ),
                        trailing: Text(
                          '£${entry.value.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    }).toList(),
                  ),
          ),

          const SizedBox(height: 28),

          Text(
            'Recent transactions — $periodLabel',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          if (orders.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'No completed sales for this period. Complete a checkout to see reports here.',
                ),
              ),
            )
          else
            ...orders
                .take(10)
                .map(
                  (order) => Card(
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.receipt)),
                      title: Text('Order #${order.id}'),
                      subtitle: Text(
                        '${order.date.day.toString().padLeft(2, '0')}/'
                        '${order.date.month.toString().padLeft(2, '0')}/'
                        '${order.date.year} • ${order.paymentMethod}',
                      ),
                      trailing: Text(
                        '£${order.total.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

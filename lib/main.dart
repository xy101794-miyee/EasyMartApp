import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() {
  runApp(const EasyMartApp());
}

class EasyMartApp extends StatelessWidget {
  const EasyMartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EasyMart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1F9D55),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F8F3),
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: const Color(0xFF1D2F1F),
          displayColor: const Color(0xFF1D2F1F),
        ),
      ),
      home: const EasyMartHomePage(),
    );
  }
}

class EasyMartHomePage extends StatefulWidget {
  const EasyMartHomePage({super.key});

  @override
  State<EasyMartHomePage> createState() => _EasyMartHomePageState();
}

class _EasyMartHomePageState extends State<EasyMartHomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _selectedPeriod = 'weekly';

  List<Product> get _filteredProducts {
    final query = _searchController.text.trim().toLowerCase();
    return products.where((product) {
      final matchesCategory =
          _selectedCategory == 'All' || product.category == _selectedCategory;
      final matchesQuery = query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  double get _grossSales => orders.fold(0.0, (sum, order) => sum + order.subtotal);

  double get _avgBasket => orders.isEmpty ? 0 : _grossSales / orders.length;

  String get _topCategory {
    final map = <String, int>{};
    for (final order in orders) {
      for (final line in order.items) {
        final product = productMap[line.productId]!;
        map[product.category] = (map[product.category] ?? 0) + line.quantity;
      }
    }

    if (map.isEmpty) return 'N/A';
    final entry = map.entries.reduce((best, current) {
      return current.value > best.value ? current : best;
    });
    return entry.key;
  }

  List<ChartPoint> get _currentChartData {
    if (_selectedPeriod == 'monthly') {
      final labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct'];
      final values = <double>[];

      for (int i = 0; i < labels.length; i++) {
        final monthValue = orders.where((order) {
          final orderDate = DateTime.parse(order.date);
          return orderDate.month == (i + 1);
        }).fold<double>(0.0, (sum, order) => sum + order.subtotal);
        values.add(monthValue);
      }

      return [
        for (int i = 0; i < labels.length; i++) ChartPoint(labels[i], values[i]),
      ];
    }

    final week = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final values = <double>[];
    for (int i = 0; i < week.length; i++) {
      final dayValue = orders.where((order) {
        final parsed = DateTime.parse(order.date);
        final targetDay = DateTime(2026, 10, 3).subtract(Duration(days: 6 - i));
        return parsed.year == targetDay.year &&
            parsed.month == targetDay.month &&
            parsed.day == targetDay.day;
      }).fold<double>(0.0, (sum, order) => sum + order.subtotal);
      values.add(dayValue);
    }

    return [
      for (int i = 0; i < week.length; i++) ChartPoint(week[i], values[i]),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('EasyMart'),
        centerTitle: false,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundColor: Color(0xFFEAF6EE),
              child: Icon(Icons.shopping_basket_outlined, color: Color(0xFF1F9D55)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Fresh picks and fast delivery',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: Color(0xFF1F9D55),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Groceries made simple',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              _buildSummaryCards(),
              const SizedBox(height: 20),
              _buildCatalogSection(screenWidth),
              const SizedBox(height: 20),
              _buildAnalyticsPanel(),
              const SizedBox(height: 20),
              _buildOrderHistory(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final summaryItems = [
      SummaryItem(label: 'Gross sales', value: _formatCurrency(_grossSales)),
      SummaryItem(label: 'Orders', value: '${orders.length}'),
      SummaryItem(label: 'Avg. basket', value: _formatCurrency(_avgBasket)),
      SummaryItem(label: 'Top category', value: _topCategory),
    ];

    return GridView.builder(
      itemCount: summaryItems.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemBuilder: (context, index) {
        final item = summaryItems[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2EDE5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label,
                style: const TextStyle(
                  color: Color(0xFF58715A),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                item.value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCatalogSection(double screenWidth) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE7EFE9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fresh groceries',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search fruits, dairy, pantry...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: const Color(0xFFF2F6F3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: categories.map((category) {
              final isSelected = category == _selectedCategory;
              return ChoiceChip(
                label: Text(category),
                selected: isSelected,
                selectedColor: const Color(0xFFEAF6EE),
                labelStyle: TextStyle(
                  color: isSelected ? const Color(0xFF1F9D55) : const Color(0xFF52675A),
                  fontWeight: FontWeight.w700,
                ),
                backgroundColor: const Color(0xFFF2F6F3),
                onSelected: (_) {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          GridView.builder(
            itemCount: _filteredProducts.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: screenWidth > 600 ? 2 : 1,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.86,
            ),
            itemBuilder: (context, index) {
              final product = _filteredProducts[index];
              return Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                      child: Image.network(
                        product.imageUrl,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEAF6EE),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  product.category,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1F9D55),
                                  ),
                                ),
                              ),
                              Text(
                                '⭐ ${product.rating.toStringAsFixed(1)}',
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatCurrency(product.price),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF1F9D55),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {},
                                child: const Text('Add'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          if (_filteredProducts.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 22),
              child: Center(
                child: Text(
                  'No products match your search.',
                  style: TextStyle(color: Color(0xFF59715D), fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsPanel() {
    final chartData = _currentChartData;
    final maxValue = chartData.fold<double>(0.0, (max, point) => math.max(max, point.value));
    final total = chartData.fold<double>(0.0, (sum, point) => sum + point.value);
    final average = chartData.isEmpty ? 0.0 : total / chartData.length;
    final bestPoint = chartData.reduce((best, current) =>
        current.value > best.value ? current : best);

    final categorySpend = <String, double>{};
    for (final order in orders) {
      for (final line in order.items) {
        final product = productMap[line.productId]!;
        categorySpend[product.category] =
            (categorySpend[product.category] ?? 0.0) + (product.price * line.quantity);
      }
    }

    final topCategories = categorySpend.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE7EFE9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Purchase analytics',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'weekly', label: Text('Weekly')),
                  ButtonSegment(value: 'monthly', label: Text('Monthly')),
                ],
                selected: {_selectedPeriod},
                onSelectionChanged: (selection) {
                  setState(() {
                    _selectedPeriod = selection.first;
                  });
                },
                showSelectedIcon: false,
              ),
            ],
          ),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.8,
            children: [
              _metricCard('Spend', _formatCurrency(total)),
              _metricCard('Average', _formatCurrency(average)),
              _metricCard('Best', bestPoint.label),
              _metricCard('Orders', '${orders.length}'),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: chartData.map((point) {
                final height = maxValue == 0 ? 0.0 : (point.value / maxValue) * 100;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: height,
                          constraints: const BoxConstraints(minHeight: 16),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            gradient: const LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Color(0xFF1F9D55), Color(0xFF7CCB9B)],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          point.label,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF58715A)),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Category volume',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...topCategories.take(4).map((entry) {
            final index = topCategories.indexOf(entry);
            final palette = [
              const Color(0xFF2DBB74),
              const Color(0xFF7CCB9B),
              const Color(0xFFF4C96F),
              const Color(0xFF8CA8FF),
            ];

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: palette[index % palette.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const Text(
                          'Category volume',
                          style: TextStyle(fontSize: 11, color: Color(0xFF58715A)),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatCurrency(entry.value),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _metricCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FBF7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3F0E6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF58715A)),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderHistory() {
    final weeklySpend = orders
        .where((order) => DateTime.parse(order.date).isAfter(DateTime(2026, 9, 27)))
        .fold<double>(0.0, (sum, order) => sum + order.subtotal);
    final monthlySpend = orders
        .where((order) => DateTime.parse(order.date).month == 9)
        .fold<double>(0.0, (sum, order) => sum + order.subtotal);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE7EFE9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order history',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              Chip(
                label: Text('Weekly ${_formatCurrency(weeklySpend)}'),
                backgroundColor: const Color(0xFFEAF6EE),
              ),
              Chip(
                label: Text('Monthly ${_formatCurrency(monthlySpend)}'),
                backgroundColor: const Color(0xFFEAF6EE),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...orders.map((order) {
            return InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => _showOrderDetails(order),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FBF9),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE6EFE7)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          order.id,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF6EE),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            order.status,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF1F9D55),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF58715A)),
                        const SizedBox(width: 6),
                        Text(_formatDate(order.date), style: const TextStyle(color: Color(0xFF58715A))),
                        const SizedBox(width: 18),
                        const Icon(Icons.local_shipping_outlined, size: 16, color: Color(0xFF58715A)),
                        const SizedBox(width: 6),
                        Text(order.deliveryMethod, style: const TextStyle(color: Color(0xFF58715A))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${order.items.length} items', style: const TextStyle(color: Color(0xFF58715A))),
                        Text(
                          _formatCurrency(order.subtotal),
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showOrderDetails(StoreOrder order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Order details',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  order.id,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_formatDate(order.date)} • ${order.status} • ${order.deliveryMethod}',
                  style: const TextStyle(color: Color(0xFF58715A)),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    itemCount: order.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final line = order.items[index];
                      final product = productMap[line.productId]!;
                      final total = product.price * line.quantity;

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              product.imageUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Qty: ${line.quantity} • ${_formatCurrency(product.price)} each',
                                  style: const TextStyle(color: Color(0xFF58715A)),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            _formatCurrency(total),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const Divider(),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Total: ${_formatCurrency(order.subtotal)}',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatCurrency(double value) {
    return ' 24${value.toStringAsFixed(2)}';
  }

  String _formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    return '${_month(date.month)} ${date.day}, ${date.year}';
  }

  String _month(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}

class SummaryItem {
  const SummaryItem({required this.label, required this.value});

  final String label;
  final String value;
}

class ChartPoint {
  const ChartPoint(this.label, this.value);

  final String label;
  final double value;
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.rating,
  });

  final String id;
  final String name;
  final String category;
  final double price;
  final String imageUrl;
  final double rating;
}

class OrderLine {
  const OrderLine({required this.productId, required this.quantity});

  final String productId;
  final int quantity;
}

class StoreOrder {
  const StoreOrder({
    required this.id,
    required this.date,
    required this.status,
    required this.deliveryMethod,
    required this.items,
    required this.subtotal,
    required this.channel,
  });

  final String id;
  final String date;
  final String status;
  final String deliveryMethod;
  final List<OrderLine> items;
  final double subtotal;
  final String channel;
}

const List<String> categories = [
  'All',
  'Fruits',
  'Vegetables',
  'Dairy',
  'Meat',
  'Pantry',
  'Frozen',
  'Bakery',
];

final List<Product> products = [
  const Product(
    id: 'apple',
    name: 'Royal Gala Apples',
    category: 'Fruits',
    price: 4.20,
    imageUrl: 'https://images.unsplash.com/photo-1567306226416-28f0efdc88ce?auto=format&fit=crop&w=900&q=80',
    rating: 4.8,
  ),
  const Product(
    id: 'banana',
    name: 'Bananas',
    category: 'Fruits',
    price: 2.60,
    imageUrl: 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?auto=format&fit=crop&w=900&q=80',
    rating: 4.6,
  ),
  const Product(
    id: 'spinach',
    name: 'Baby Spinach',
    category: 'Vegetables',
    price: 3.60,
    imageUrl: 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?auto=format&fit=crop&w=900&q=80',
    rating: 4.7,
  ),
  const Product(
    id: 'carrot',
    name: 'Crunchy Carrots',
    category: 'Vegetables',
    price: 2.40,
    imageUrl: 'https://images.unsplash.com/photo-1445282768818-728615cc910a?auto=format&fit=crop&w=900&q=80',
    rating: 4.8,
  ),
  const Product(
    id: 'milk',
    name: 'Organic Whole Milk',
    category: 'Dairy',
    price: 4.90,
    imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=900&q=80',
    rating: 4.7,
  ),
  const Product(
    id: 'yogurt',
    name: 'Greek Yogurt',
    category: 'Dairy',
    price: 5.80,
    imageUrl: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&w=900&q=80',
    rating: 4.8,
  ),
  const Product(
    id: 'chicken',
    name: 'Chicken Breast',
    category: 'Meat',
    price: 8.90,
    imageUrl: 'https://images.unsplash.com/photo-1607623814075-e51df1d8cba7?auto=format&fit=crop&w=900&q=80',
    rating: 4.8,
  ),
  const Product(
    id: 'salmon',
    name: 'Atlantic Salmon',
    category: 'Meat',
    price: 12.50,
    imageUrl: 'https://images.unsplash.com/photo-1467003909585-2f8a72700288?auto=format&fit=crop&w=900&q=80',
    rating: 4.9,
  ),
  const Product(
    id: 'rice',
    name: 'Jasmine Rice',
    category: 'Pantry',
    price: 6.40,
    imageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31f?auto=format&fit=crop&w=900&q=80',
    rating: 4.7,
  ),
  const Product(
    id: 'pasta',
    name: 'Italian Pasta',
    category: 'Pantry',
    price: 3.50,
    imageUrl: 'https://images.unsplash.com/photo-1555949258-eb67b1ef0ceb?auto=format&fit=crop&w=900&q=80',
    rating: 4.8,
  ),
  const Product(
    id: 'peas',
    name: 'Frozen Peas',
    category: 'Frozen',
    price: 2.70,
    imageUrl: 'https://images.unsplash.com/photo-1461354464878-ad92f492a5a0?auto=format&fit=crop&w=900&q=80',
    rating: 4.7,
  ),
  const Product(
    id: 'icecream',
    name: 'Vanilla Ice Cream',
    category: 'Frozen',
    price: 6.80,
    imageUrl: 'https://images.unsplash.com/photo-1570197788417-0e82375c9371?auto=format&fit=crop&w=900&q=80',
    rating: 4.9,
  ),
  const Product(
    id: 'sourdough',
    name: 'Country Sourdough',
    category: 'Bakery',
    price: 5.90,
    imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=900&q=80',
    rating: 4.8,
  ),
  const Product(
    id: 'croissant',
    name: 'Butter Croissant',
    category: 'Bakery',
    price: 4.70,
    imageUrl: 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=900&q=80',
    rating: 4.9,
  ),
  const Product(
    id: 'eggs',
    name: 'Free Range Eggs',
    category: 'Dairy',
    price: 5.20,
    imageUrl: 'https://images.unsplash.com/photo-1506975094-7d1d0f80eb45?auto=format&fit=crop&w=900&q=80',
    rating: 4.8,
  ),
  const Product(
    id: 'bread',
    name: 'Whole Grain Bread',
    category: 'Bakery',
    price: 4.10,
    imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=900&q=80',
    rating: 4.7,
  ),
  const Product(
    id: 'orange',
    name: 'Citrus Oranges',
    category: 'Fruits',
    price: 3.80,
    imageUrl: 'https://images.unsplash.com/photo-1611080626919-7cf5a9dbab5b?auto=format&fit=crop&w=900&q=80',
    rating: 4.7,
  ),
  const Product(
    id: 'tomato',
    name: 'Roma Tomatoes',
    category: 'Vegetables',
    price: 3.40,
    imageUrl: 'https://images.unsplash.com/photo-1546094096-0df4bcaaa337?auto=format&fit=crop&w=900&q=80',
    rating: 4.9,
  ),
];

final Map<String, Product> productMap = {
  for (final product in products) product.id: product,
};

final List<StoreOrder> orders = [
  StoreOrder(
    id: 'EM-1048',
    date: '2026-10-03',
    status: 'Delivered',
    deliveryMethod: 'Home delivery',
    channel: 'App',
    subtotal: 72.45,
    items: const [
      OrderLine(productId: 'apple', quantity: 3),
      OrderLine(productId: 'milk', quantity: 2),
      OrderLine(productId: 'sourdough', quantity: 1),
      OrderLine(productId: 'spinach', quantity: 2),
    ],
  ),
  StoreOrder(
    id: 'EM-1042',
    date: '2026-09-28',
    status: 'Delivered',
    deliveryMethod: 'Pickup',
    channel: 'Web',
    subtotal: 58.90,
    items: const [
      OrderLine(productId: 'chicken', quantity: 1),
      OrderLine(productId: 'rice', quantity: 2),
      OrderLine(productId: 'carrot', quantity: 3),
      OrderLine(productId: 'peas', quantity: 2),
    ],
  ),
  StoreOrder(
    id: 'EM-1037',
    date: '2026-09-18',
    status: 'Delivered',
    deliveryMethod: 'Home delivery',
    channel: 'App',
    subtotal: 64.80,
    items: const [
      OrderLine(productId: 'orange', quantity: 4),
      OrderLine(productId: 'yogurt', quantity: 2),
      OrderLine(productId: 'pasta', quantity: 3),
      OrderLine(productId: 'icecream', quantity: 1),
    ],
  ),
  StoreOrder(
    id: 'EM-1031',
    date: '2026-09-10',
    status: 'Delivered',
    deliveryMethod: 'Pickup',
    channel: 'Store',
    subtotal: 49.60,
    items: const [
      OrderLine(productId: 'banana', quantity: 5),
      OrderLine(productId: 'eggs', quantity: 2),
      OrderLine(productId: 'bread', quantity: 2),
      OrderLine(productId: 'tomato', quantity: 2),
    ],
  ),
  StoreOrder(
    id: 'EM-1025',
    date: '2026-08-25',
    status: 'Delivered',
    deliveryMethod: 'Home delivery',
    channel: 'App',
    subtotal: 81.70,
    items: const [
      OrderLine(productId: 'salmon', quantity: 2),
      OrderLine(productId: 'croissant', quantity: 2),
      OrderLine(productId: 'apple', quantity: 3),
      OrderLine(productId: 'rice', quantity: 1),
    ],
  ),
  StoreOrder(
    id: 'EM-1019',
    date: '2026-08-14',
    status: 'Delivered',
    deliveryMethod: 'Home delivery',
    channel: 'Web',
    subtotal: 67.25,
    items: const [
      OrderLine(productId: 'chicken', quantity: 2),
      OrderLine(productId: 'milk', quantity: 2),
      OrderLine(productId: 'bread', quantity: 3),
      OrderLine(productId: 'peas', quantity: 4),
    ],
  ),
];


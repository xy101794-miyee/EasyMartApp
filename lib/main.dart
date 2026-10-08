import 'dart:async';
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
          seedColor: const Color(0xFFFF6D2E),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: const Color(0xFF0D2347),
          displayColor: const Color(0xFF0D2347),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _selectedRole = 'user';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              SizedBox(
                height: 120,
                child: Image.network(
                  'https://www.svgrepo.com/show/13666/shopping-cart.svg',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6D2E), Color(0xFFFFA500)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(Icons.shopping_cart, size: 60, color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'EasyMart',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
              ),
              const Text(
                'Easy Shop, Smart Choice',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 60),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'Select Your Role',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 24),
                      _roleOption('user', Icons.person, 'Customer'),
                      const SizedBox(height: 12),
                      _roleOption('admin', Icons.admin_panel_settings, 'Admin'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6D2E),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (_selectedRole == 'user') {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const UserDashboard()),
                      );
                    } else {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const AdminDashboard()),
                      );
                    }
                  },
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleOption(String value, IconData icon, String label) {
    final isSelected = _selectedRole == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF6D2E) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? const Color(0xFFFFF5F0) : Colors.white,
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: isSelected ? const Color(0xFFFF6D2E) : Colors.grey),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xFFFF6D2E) : Colors.black,
              ),
            ),
            const Spacer(),
            Radio<String>(
              value: value,
              groupValue: _selectedRole,
              onChanged: (v) => setState(() => _selectedRole = v!),
              activeColor: const Color(0xFFFF6D2E),
            ),
          ],
        ),
      ),
    );
  }
}

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _selectedPeriod = 'weekly';
  int _selectedNavIndex = 0;

  List<Product> get _filteredProducts {
    final query = _searchController.text.trim().toLowerCase();
    return products.where((product) {
      final matchesCategory = _selectedCategory == 'All' || product.category == _selectedCategory;
      final matchesQuery = query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EasyMart'),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {},
              child: CircleAvatar(
                backgroundColor: const Color(0xFFFFF5F0),
                child: const Icon(Icons.shopping_basket_outlined, color: Color(0xFFFF6D2E)),
              ),
            ),
          ),
        ],
      ),
      body: _selectedNavIndex == 0
          ? _buildCatalogView()
          : _selectedNavIndex == 1
              ? _buildOrderHistoryView()
              : _buildAnalyticsView(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedNavIndex,
        onTap: (index) => setState(() => _selectedNavIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Shop'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analytics'),
        ],
      ),
    );
  }

  Widget _buildCatalogView() {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fresh Groceries',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade100,
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
                selectedColor: const Color(0xFFFF6D2E),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF0D2347),
                  fontWeight: FontWeight.w700,
                ),
                backgroundColor: Colors.grey.shade200,
                onSelected: (_) => setState(() => _selectedCategory = category),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
                                  color: const Color(0xFFFFF5F0),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: const Color(0xFFFF6D2E), width: 1),
                                ),
                                child: Text(
                                  product.category,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFFF6D2E),
                                  ),
                                ),
                              ),
                              Text(
                                '⭐ ${product.rating.toStringAsFixed(1)}',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            product.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFFF6D2E),
                                ),
                              ),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF6D2E),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {},
                                child: const Text('Add', style: TextStyle(fontSize: 12)),
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
        ],
      ),
    );
  }

  Widget _buildOrderHistoryView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Orders',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          ...orders.map((order) {
            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => OrderTrackingPage(order: order),
                ),
              ),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                    ),
                  ],
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
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF5F0),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: const Color(0xFFFF6D2E), width: 1),
                          ),
                          child: Text(
                            order.status,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFFF6D2E),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Text(
                          _formatDate(order.date),
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                        const SizedBox(width: 18),
                        Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Text(
                          order.deliveryMethod,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${order.items.length} items',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '\$${order.subtotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFFF6D2E),
                          ),
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

  Widget _buildAnalyticsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Analytics',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'weekly', label: Text('Weekly')),
              ButtonSegment(value: 'monthly', label: Text('Monthly')),
            ],
            selected: {_selectedPeriod},
            onSelectionChanged: (selection) {
              setState(() => _selectedPeriod = selection.first);
            },
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
              _metricCard('Total Orders', '${orders.length}'),
              _metricCard('Total Spend', '\$${orders.fold<double>(0.0, (sum, order) => sum + order.subtotal).toStringAsFixed(2)}'),
              _metricCard('Avg. Basket', '\$${(orders.fold<double>(0.0, (sum, order) => sum + order.subtotal) / orders.length).toStringAsFixed(2)}'),
              _metricCard('Saved', '\$${(orders.length * 5.5).toStringAsFixed(2)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF666)),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    return '${['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][date.month - 1]} ${date.day}, ${date.year}';
  }
}

class OrderTrackingPage extends StatefulWidget {
  final StoreOrder order;

  const OrderTrackingPage({super.key, required this.order});

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  late Timer _timer;
  late int _elapsedSeconds;
  late Map<String, dynamic> _locationData;

  @override
  void initState() {
    super.initState();
    _elapsedSeconds = 0;
    _locationData = {
      'latitude': 40.7128 + (math.Random().nextDouble() - 0.5) * 0.05,
      'longitude': -74.0060 + (math.Random().nextDouble() - 0.5) * 0.05,
      'accuracy': 50 + math.Random().nextInt(50),
    };

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsedSeconds++;
        _locationData['latitude'] += (math.Random().nextDouble() - 0.5) * 0.001;
        _locationData['longitude'] += (math.Random().nextDouble() - 0.5) * 0.001;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '$hours h ${minutes} min ${secs} sec';
    } else if (minutes > 0) {
      return '$minutes min ${secs} sec';
    } else {
      return '$secs sec';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Track Order')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 300,
              color: Colors.grey.shade200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue.shade200,
                          Colors.green.shade200,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: ((_locationData['longitude'] + 74.0060) / 0.1) * 100,
                    top: ((40.7128 - _locationData['latitude']) / 0.1) * 100,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6D2E),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.5),
                            blurRadius: 15,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.directions_bike,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    top: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Elapsed Time',
                            style: TextStyle(fontSize: 10, color: Color(0xFF666)),
                          ),
                          Text(
                            _formatTime(_elapsedSeconds),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.order.id,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF5F0),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: const Color(0xFFFF6D2E), width: 1),
                        ),
                        child: const Text(
                          'Out for Delivery',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFFFF6D2E),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Order Items',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  ...widget.order.items.map((item) {
                    final product = productMap[item.productId]!;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              product.imageUrl,
                              width: 60,
                              height: 60,
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
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  'Qty: ${item.quantity}',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '\$${(product.price * item.quantity).toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total:', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        '\$${widget.order.subtotal.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFFFF6D2E)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF5F0),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFF6D2E), width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Color(0xFFFF6D2E)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Delivery',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                              Text(
                                'Arriving in approximately ${25 + math.Random().nextInt(35)} minutes',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        centerTitle: false,
      ),
      body: _selectedNavIndex == 0
          ? _buildOrdersView()
          : _selectedNavIndex == 1
              ? _buildAnalyticsView()
              : _buildProductsView(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedNavIndex,
        onTap: (index) => setState(() => _selectedNavIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analytics'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Products'),
        ],
      ),
    );
  }

  Widget _buildOrdersView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Management',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          ...orders.map((order) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF5F0),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: const Color(0xFFFF6D2E), width: 1),
                        ),
                        child: Text(
                          order.status,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFFF6D2E),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Items: ${order.items.length}', style: const TextStyle(color: Color(0xFF666))),
                      Text(
                        '\$${order.subtotal.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFFFF6D2E)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {},
                          child: const Text('Accept'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {},
                          child: const Text('Reject'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAnalyticsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard Analytics',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.8,
            children: [
              _metricCard('Total Orders', '${orders.length}', Colors.blue),
              _metricCard('Total Revenue', '\$${orders.fold<double>(0.0, (sum, order) => sum + order.subtotal).toStringAsFixed(2)}', Colors.green),
              _metricCard('Avg. Order', '\$${(orders.fold<double>(0.0, (sum, order) => sum + order.subtotal) / orders.length).toStringAsFixed(2)}', Colors.orange),
              _metricCard('Products', '${products.length}', Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product Inventory',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          ...products.take(10).map((product) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.imageUrl,
                      width: 50,
                      height: 50,
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
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          product.category,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
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

  Widget _metricCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
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

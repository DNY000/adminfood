import 'package:admin/screens/dashboard/components/topselling_pie_chart.dart';
import 'package:admin/screens/dashboard/components/user_registration_chart.dart';
import 'package:admin/screens/dashboard/components/chart_order.dart';
import 'package:admin/screens/main/components/side_menu.dart';
import 'package:admin/viewmodels/order_viewmodel.dart';
import 'package:admin/reponsive.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<OrderViewModel>();
      viewModel.loadTodayOrderCount();
      viewModel.loadTodayRevenue();
      // Load data for charts if needed here
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Add AppBar for mobile view
      appBar: Responsive.isMobile(context)
          ? AppBar(
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu), // Menu icon
                  onPressed: () {
                    // When icon is pressed
                    Scaffold.of(context).openDrawer(); // Open the drawer
                  },
                ),
              ),
              title: Text('Dashboard',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.white)), // Title
              backgroundColor: Theme.of(context)
                  .scaffoldBackgroundColor, // Match background color
              elevation: 0, // Remove shadow
            )
          : null, // No AppBar on desktop
      drawer: Responsive.isMobile(context)
          ? const SideMenu()
          : null, // Use SideMenu as drawer on mobile
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16), // Giảm padding trên mobile
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Remove this as title is now in AppBar on mobile
              if (!Responsive.isMobile(
                  context)) // Only show title in body on desktop
                Text(
                  'Dashboard',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              if (!Responsive.isMobile(
                  context)) // Add spacing only on desktop if title is in body
                const SizedBox(height: 16),
              // Summary Cards (responsive)
              if (Responsive.isDesktop(context)) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Selector<OrderViewModel, int>(
                      builder: (BuildContext context, value, Widget? child) {
                        return _SummaryCard(
                            title: 'Đơn hàng hôm nay',
                            value: value.toString(),
                            icon: Icons.shopping_cart,
                            color: Colors.blue);
                      },
                      selector:
                          (BuildContext context, OrderViewModel viewModel) {
                        return viewModel.todayOrderCount;
                      },
                    ),
                    Selector<OrderViewModel, double>(
                      builder: (BuildContext context, value, Widget? child) {
                        // Format revenue to millions (tr)
                        final revenueInMillions = value / 1000000;
                        final formattedRevenue =
                            revenueInMillions.toStringAsFixed(1);
                        return _SummaryCard(
                            title: 'Doanh thu hôm nay',
                            value: '$formattedRevenue tr',
                            icon: Icons.attach_money,
                            color: Colors.green);
                      },
                      selector:
                          (BuildContext context, OrderViewModel viewModel) {
                        return viewModel.todayRevenue;
                      },
                    ),
                    _SummaryCard(
                        title: 'Nhà hàng mới',
                        value: '2',
                        icon: Icons.store,
                        color: Colors.purple),
                  ],
                ),
              ] else ...[
                // Mobile layout for Summary Cards
                Wrap(
                  spacing: 8.0, // Khoảng cách giữa các card theo chiều ngang
                  runSpacing: 8.0, // Khoảng cách giữa các dòng card
                  children: [
                    Selector<OrderViewModel, int>(
                      builder: (BuildContext context, value, Widget? child) {
                        return SizedBox(
                          // Use SizedBox instead of Expanded
                          width: 160, // Set a fixed width for the card
                          child: _SummaryCard(
                              title: 'Đơn hàng hôm nay',
                              value: value.toString(),
                              icon: Icons.shopping_cart,
                              color: Colors.blue),
                        );
                      },
                      selector:
                          (BuildContext context, OrderViewModel viewModel) {
                        return viewModel.todayOrderCount;
                      },
                    ),
                    Selector<OrderViewModel, double>(
                      builder: (BuildContext context, value, Widget? child) {
                        // Format revenue to millions (tr)
                        final revenueInMillions = value / 1000000;
                        final formattedRevenue =
                            revenueInMillions.toStringAsFixed(1);
                        return SizedBox(
                            // Use SizedBox instead of Expanded
                            width: 160, // Set a fixed width for the card
                            child: _SummaryCard(
                                title: 'Doanh thu hôm nay',
                                value: '$formattedRevenue tr',
                                icon: Icons.attach_money,
                                color: Colors.green));
                      },
                      selector:
                          (BuildContext context, OrderViewModel viewModel) {
                        return viewModel.todayRevenue;
                      },
                    ),
                    SizedBox(
                        // Use SizedBox instead of Expanded
                        width: 160, // Set a fixed width for the card
                        child: _SummaryCard(
                            title: 'Nhà hàng mới',
                            value: '2',
                            icon: Icons.store,
                            color: Colors.purple)),
                    SizedBox(
                        // Use SizedBox instead of Expanded
                        width: 160, // Set a fixed width for the card
                        child: _SummaryCard(
                            title: 'Shipper mới',
                            value: '3',
                            icon: Icons.delivery_dining,
                            color: Colors.teal)),
                  ],
                ),
              ],

              const SizedBox(height: 32),

              // Charts (responsive)
              if (Responsive.isDesktop(context)) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: Main charts
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          UserRegistrationChart(),
                          SizedBox(height: 24),
                          OrderChart()
                        ],
                      ),
                    ),
                    SizedBox(width: 24),
                    // Right: Pie chart + stats
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          _FakePieChart(title: 'Tỉ lệ trạng thái đơn hàng'),
                        ],
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Mobile layout for Charts
                Column(
                  children: [
                    UserRegistrationChart(),
                    SizedBox(
                        height: 16), // Khoảng cách giữa các biểu đồ trên mobile
                    OrderChart(),
                    SizedBox(height: 16),
                    // Use TopSellingPieChart directly or wrap in a suitable container if needed
                    TopSellingPieChart(
                      key: UniqueKey(),
                    )
                  ],
                ),
              ],

              const SizedBox(height: 16),

              // Recent Orders Table (assuming it's responsive enough or needs separate mobile view)
              Text('Đơn hàng gần đây',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              const RecentOrdersTable(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  const _SummaryCard(
      {required this.title,
      required this.value,
      required this.icon,
      required this.color});
  @override
  Widget build(BuildContext context) {
    // Removed fixed width to allow cards to be flexible in Wrap
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        // width: 160, // Removed fixed width
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Use min size for content
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold)), // Giảm font size cho mobile
            const SizedBox(height: 4),
            Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14)), // Giảm font size cho mobile
          ],
        ),
      ),
    );
  }
}

// Keep _FakeChart and _FakePieChart if still used elsewhere, otherwise remove
class _FakeChart extends StatelessWidget {
  final String title;
  const _FakeChart({required this.title});
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        height: 200,
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Center(
            child: Text('Biểu đồ: $title',
                style: const TextStyle(color: Colors.grey))),
      ),
    );
  }
}

class _FakePieChart extends StatelessWidget {
  final String title;
  const _FakePieChart({required this.title});
  @override
  Widget build(BuildContext context) {
    // This fake pie chart might not be needed anymore if TopSellingPieChart is used directly
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const SizedBox(
          height: 500,
          width: double.infinity,
          child:
              TopSellingPieChart()), // Consider if SizedBox is necessary and its dimensions
    );
  }
}

class RecentOrdersTable extends StatefulWidget {
  const RecentOrdersTable({super.key});

  @override
  State<RecentOrdersTable> createState() => _RecentOrdersTableState();
}

class _RecentOrdersTableState extends State<RecentOrdersTable> {
  final Map<String, String> _restaurantNames = {};

  @override
  void initState() {
    super.initState();
    // Load recent orders after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderViewModel>().loadRecentOrders();
    });
  }

  Future<void> _loadRestaurantName(String restaurantId) async {
    if (_restaurantNames.containsKey(restaurantId)) return;

    final name =
        await context.read<OrderViewModel>().getRestaurantName(restaurantId);
    if (mounted) {
      setState(() {
        _restaurantNames[restaurantId] = name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OrderViewModel>();
    final orders = viewModel.recentOrders;

    // Load restaurant names for each order
    for (final order in orders) {
      _loadRestaurantName(order.restaurantId);
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.error != null
              ? Center(child: Text('Lỗi: ${viewModel.error}'))
              : SingleChildScrollView(
                  // Allow horizontal scrolling for the table if needed
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Mã đơn')),
                        DataColumn(label: Text('Khách hàng')),
                        DataColumn(label: Text('Nhà hàng')),
                        DataColumn(label: Text('Tổng tiền')),
                        DataColumn(label: Text('Trạng thái')),
                        // Add more columns as needed
                      ],
                      rows: orders.map((order) {
                        // Get restaurant name from the cached map
                        final restaurantName =
                            _restaurantNames[order.restaurantId] ??
                                'Đang tải...';

                        return DataRow(
                          cells: [
                            DataCell(Text(order.id)),
                            DataCell(Text(order
                                .userId)), // Assuming userId is the customer identifier
                            DataCell(Text(restaurantName)),
                            DataCell(Text(order.totalPrice
                                .toStringAsFixed(2))), // Format price
                            DataCell(Text(order.status
                                .toString()
                                .split('.')
                                .last)), // Display enum name
                            // Add more cells corresponding to columns
                          ],
                        );
                      }).toList()),
                ),
    );
  }
}

// Consider if this is still needed or can be replaced by direct chart widgets
/*
class _MiniStatCard extends StatelessWidget {
  final String title;
  final String value;
  const _MiniStatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity, // Card takes full width
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 16, color: Colors.grey)),
            SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
*/

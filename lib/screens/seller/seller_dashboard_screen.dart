import 'package:admin/viewmodels/order_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../routes/seller_router.dart';
import 'package:admin/screens/seller/components/seller_side_menu.dart';
import 'package:admin/responsive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:admin/models/food_model.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({Key? key}) : super(key: key);

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  int _selectedIndex = 0;
  String _selectedRevenuePeriod = 'week'; // hoặc 'month'
  String? _restaurantId;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final restaurantDoc = await FirebaseFirestore.instance
        .collection('restaurants')
        .where('token', isEqualTo: user.uid)
        .get();
    if (restaurantDoc.docs.isNotEmpty) {
      final restaurantId = restaurantDoc.docs.first.id;
      _restaurantId = restaurantId;
      final orderVM = Provider.of<OrderViewModel>(context, listen: false);
      await orderVM.loadOrdersByRestaurant(restaurantId);
      await orderVM.loadTodayOrderCount();
      await orderVM.loadTodayRevenue();
      await orderVM.loadRecentOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: Responsive.isMobile(context) ? null : GlobalKey<ScaffoldState>(),
      drawer: Responsive.isMobile(context) ? const SellerSideMenu() : null,
      appBar: AppBar(
        title: const Text('Seller Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.go(SellerRouter.settings);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (Responsive.isDesktop(context))
              const Expanded(
                flex: 1,
                child: SellerSideMenu(),
              ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tổng quan',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Stats Cards
                    Consumer<OrderViewModel>(
                      builder: (context, orderVM, child) {
                        return Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Tổng đơn hàng',
                                '${orderVM.orders.length}',
                                Icons.shopping_cart,
                                Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                'Đơn hàng hôm nay',
                                '${orderVM.todayOrderCount}',
                                Icons.today,
                                Colors.green,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                'Tổng doanh thu',
                                '${orderVM.todayRevenue}đ',
                                Icons.attach_money,
                                Colors.orange,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    // Biểu đồ doanh thu
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartData {
  final String label;
  final double value;
  _ChartData(this.label, this.value);
}

class SellerTopSellingPieChart extends StatefulWidget {
  final String restaurantId;
  const SellerTopSellingPieChart({super.key, required this.restaurantId});

  @override
  State<SellerTopSellingPieChart> createState() =>
      _SellerTopSellingPieChartState();
}

class _SellerTopSellingPieChartState extends State<SellerTopSellingPieChart> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<OrderViewModel>()
          .getTopSellingFoods(restaurantId: widget.restaurantId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderViewModel>(
      builder: (context, orderVM, child) {
        if (orderVM.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        final foods = orderVM.topSellingFoods;
        final totalSold =
            // ignore: avoid_types_as_parameter_names
            foods.fold<int>(0, (sum, food) => sum + (food['soid'] as int));
        final List<_PieChartData> chartData = foods.map((food) {
          final percent =
              totalSold > 0 ? (food['soid'] as int) / totalSold * 100 : 0.0;
          return _PieChartData(food['name'], food['soid'] as int, percent);
        }).toList();

        return Container(
          height: 400,
          child: SfCircularChart(
            title: ChartTitle(
              text: 'Top 5 món ăn bán chạy',
              textStyle: Theme.of(context).textTheme.titleMedium,
            ),
            legend: const Legend(
              isVisible: true,
              position: LegendPosition.bottom,
              orientation: LegendItemOrientation.horizontal,
              overflowMode: LegendItemOverflowMode.wrap,
            ),
            tooltipBehavior: TooltipBehavior(
              enable: true,
              format: 'point.x : point.y ',
            ),
            series: <CircularSeries>[
              PieSeries<_PieChartData, String>(
                dataSource: chartData,
                xValueMapper: (_PieChartData data, _) => data.x,
                yValueMapper: (_PieChartData data, _) => data.y,
                dataLabelSettings: const DataLabelSettings(
                  isVisible: false,
                  labelPosition: ChartDataLabelPosition.outside,
                  textStyle: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
                enableTooltip: true,
                explode: true,
                explodeAll: false,
                explodeIndex: 0,
                dataLabelMapper: (_PieChartData data, _) =>
                    '${data.x}\n${data.percentage.toStringAsFixed(1)}%',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PieChartData {
  final String x;
  final int y;
  final double percentage;

  _PieChartData(this.x, this.y, this.percentage);
}

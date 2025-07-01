import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:admin/viewmodels/order_viewmodel.dart';

class DoanhThuByRestaurantScreen extends StatefulWidget {
  final String restaurantId;
  const DoanhThuByRestaurantScreen({super.key, required this.restaurantId});

  @override
  State<DoanhThuByRestaurantScreen> createState() =>
      _DoanhThuByRestaurantScreenState();
}

class _DoanhThuByRestaurantScreenState
    extends State<DoanhThuByRestaurantScreen> {
  String _selectedRangeOrder = 'week'; // 'week' hoặc 'month' cho số đơn
  String _selectedRangeRevenue = 'week'; // 'week' hoặc 'month' cho doanh thu
  Map<String, double> _dailyRevenue = {};
  Map<String, int> _dailyOrderCount = {};
  bool _loadingOrder = true;
  bool _loadingRevenue = true;
  String? _errorOrder;
  String? _errorRevenue;

  @override
  void initState() {
    super.initState();
    _fetchOrderStats();
    _fetchRevenueStats();
  }

  Future<void> _fetchOrderStats() async {
    setState(() {
      _loadingOrder = true;
      _errorOrder = null;
    });
    try {
      final now = DateTime.now();
      DateTime fromDate;
      if (_selectedRangeOrder == 'week') {
        fromDate = now.subtract(Duration(days: now.weekday - 1)); // Đầu tuần
      } else {
        fromDate = DateTime(now.year, now.month, 1); // Đầu tháng
      }
      final stats = await context.read<OrderViewModel>().getRevenueStats(
            restaurantId: widget.restaurantId,
            fromDate: fromDate,
            toDate: now,
          );
      setState(() {
        // Tính số đơn mỗi ngày
        _dailyOrderCount = {};
        final dailyOrderCount = stats['dailyOrderCount'] ?? {};
        _dailyOrderCount = Map<String, int>.from(dailyOrderCount);
        _loadingOrder = false;
      });
    } catch (e) {
      setState(() {
        _errorOrder = e.toString();
        _loadingOrder = false;
      });
    }
  }

  Future<void> _fetchRevenueStats() async {
    setState(() {
      _loadingRevenue = true;
      _errorRevenue = null;
    });
    try {
      final now = DateTime.now();
      DateTime fromDate;
      if (_selectedRangeRevenue == 'week') {
        fromDate = now.subtract(Duration(days: now.weekday - 1)); // Đầu tuần
      } else {
        fromDate = DateTime(now.year, now.month, 1); // Đầu tháng
      }
      final stats = await context.read<OrderViewModel>().getRevenueStats(
            restaurantId: widget.restaurantId,
            fromDate: fromDate,
            toDate: now,
          );
      setState(() {
        _dailyRevenue = Map<String, double>.from(stats['dailyRevenue'] ?? {});
        _loadingRevenue = false;
      });
    } catch (e) {
      setState(() {
        _errorRevenue = e.toString();
        _loadingRevenue = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Tổng số đơn hàng - Biểu đồ cột
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tổng số đơn hàng',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                DropdownButton<String>(
                  value: _selectedRangeOrder,
                  items: const [
                    DropdownMenuItem(value: 'week', child: Text('Tuần này')),
                    DropdownMenuItem(value: 'month', child: Text('Tháng này')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedRangeOrder = value);
                      _fetchOrderStats();
                    }
                  },
                ),
              ],
            ),
            _loadingOrder
                ? const Center(child: CircularProgressIndicator())
                : _errorOrder != null
                    ? Center(child: Text(_errorOrder!))
                    : Expanded(
                        child: SfCartesianChart(
                          title:
                              const ChartTitle(text: 'Số đơn hàng theo ngày'),
                          primaryXAxis: const CategoryAxis(),
                          series: <CartesianSeries<MapEntry<String, int>,
                              String>>[
                            ColumnSeries<MapEntry<String, int>, String>(
                              dataSource: _dailyOrderCount.entries.toList(),
                              xValueMapper: (entry, _) => entry.key,
                              yValueMapper: (entry, _) => entry.value,
                              name: 'Số đơn',
                              color: Colors.green,
                            ),
                          ],
                        ),
                      ),
            const SizedBox(height: 24),
            // Tổng doanh thu - Biểu đồ cột
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tổng doanh thu',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                DropdownButton<String>(
                  value: _selectedRangeRevenue,
                  items: const [
                    DropdownMenuItem(value: 'week', child: Text('Tuần này')),
                    DropdownMenuItem(value: 'month', child: Text('Tháng này')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedRangeRevenue = value);
                      _fetchRevenueStats();
                    }
                  },
                ),
              ],
            ),
            _loadingRevenue
                ? const Center(child: CircularProgressIndicator())
                : _errorRevenue != null
                    ? Center(child: Text(_errorRevenue!))
                    : Expanded(
                        child: SfCartesianChart(
                          title: const ChartTitle(text: 'Doanh thu theo ngày'),
                          primaryXAxis: const CategoryAxis(),
                          series: <CartesianSeries<MapEntry<String, double>,
                              String>>[
                            ColumnSeries<MapEntry<String, double>, String>(
                              dataSource: _dailyRevenue.entries.toList(),
                              xValueMapper: (entry, _) => entry.key,
                              yValueMapper: (entry, _) => entry.value,
                              name: 'Doanh thu',
                              color: Colors.blue,
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

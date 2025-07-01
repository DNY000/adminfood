import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:provider/provider.dart';
import 'package:admin/viewmodels/order_viewmodel.dart';

class OrderChart extends StatefulWidget {
  const OrderChart({super.key});

  @override
  State<OrderChart> createState() => _OrderChartState();
}

class _OrderChartState extends State<OrderChart> {
  String selectedPeriod = 'week'; // 'week' or 'month'

  @override
  void initState() {
    super.initState();
    // Fetch initial data when the widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderViewModel>().getOrderStats(selectedPeriod);
    });
  }

  void _onPeriodChanged(String? value) {
    if (value != null && value != selectedPeriod) {
      setState(() {
        selectedPeriod = value;
      });
      // Fetch new data when the period changes
      context.read<OrderViewModel>().getOrderStats(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the ViewModel for state changes
    final viewModel = context.watch<OrderViewModel>();
    final stats = viewModel.orderStats;
    final isLoading = viewModel.isStatsLoading;
    final error = viewModel.statsError;

    // Determine labels based on the selected period
    final List<String> labels = selectedPeriod == 'week'
        ? ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN']
        : ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'];

    // Create chart data objects from fetched stats and labels
    final List<_ChartData> chartData = [
      for (int i = 0; i < labels.length; i++)
        // Ensure index is within bounds of fetched stats list
        _ChartData(labels[i], (i < stats.length) ? stats[i] : 0)
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Thống kê đơn hàng',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                DropdownButton<String>(
                  value: selectedPeriod,
                  items: const [
                    DropdownMenuItem(value: 'week', child: Text('Tuần')),
                    DropdownMenuItem(value: 'month', child: Text('Tháng')),
                  ],
                  onChanged: _onPeriodChanged,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Display loading, error, or chart based on state
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (error != null)
              Center(
                  child:
                      Text('Lỗi: $error', style: TextStyle(color: Colors.red)))
            else
              SizedBox(
                height: 250,
                child: SfCartesianChart(
                  primaryXAxis: const CategoryAxis(),
                  title: ChartTitle(
                      text: selectedPeriod == 'week'
                          ? '7 ngày gần nhất'
                          : '12 tháng'),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  legend: const Legend(
                    isVisible: true,
                    position: LegendPosition.bottom,
                    overflowMode: LegendItemOverflowMode.wrap,
                  ),
                  series: <CartesianSeries<_ChartData, String>>[
                    ColumnSeries<_ChartData, String>(
                      dataSource: chartData,
                      xValueMapper: (_ChartData d, _) => d.label,
                      yValueMapper: (_ChartData d, _) => d.value,
                      name: 'Số đơn hàng',
                      color: Colors.green,
                      dataLabelSettings:
                          const DataLabelSettings(isVisible: true),
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

class _ChartData {
  final String label;
  final int value;
  _ChartData(this.label, this.value);
}

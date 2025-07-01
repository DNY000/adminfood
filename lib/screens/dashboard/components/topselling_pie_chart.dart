import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:admin/models/food_model.dart';
import 'package:admin/viewmodels/food_viewmodel.dart';

class TopSellingPieChart extends StatefulWidget {
  const TopSellingPieChart({super.key});

  @override
  State<TopSellingPieChart> createState() => _TopSellingPieChartState();
}

class _TopSellingPieChartState extends State<TopSellingPieChart> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FoodViewModel>().loadTopSellingFoods();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FoodViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.error != null) {
          return Center(
            child: Text('Lỗi: ${viewModel.error}',
                style: const TextStyle(color: Colors.red)),
          );
        }

        final categoryData = viewModel.getTopSellingCategories();
        final totalQuantity =
            categoryData.values.fold<int>(0, (sum, qty) => sum + qty);

        final List<_PieChartData> chartData = categoryData.entries.map((entry) {
          final percentage = entry.value / totalQuantity * 100;
          return _PieChartData(
            entry.key, // category name
            entry.value, // total sold
            percentage,
          );
        }).toList();

        return Container(
          height: 400,
          // padding: const EdgeInsets.all(16),
          child: SfCircularChart(
            title: ChartTitle(
              text: 'Top loại món ăn bán chạy',
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

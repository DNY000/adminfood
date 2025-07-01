import 'package:admin/viewmodels/order_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderByRestaurantScreen extends StatefulWidget {
  final String restaurantId;
  const OrderByRestaurantScreen({super.key, required this.restaurantId});

  @override
  State<OrderByRestaurantScreen> createState() =>
      _OrderByRestaurantScreenState();
}

class _OrderByRestaurantScreenState extends State<OrderByRestaurantScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context
        .read<OrderViewModel>()
        .loadOrdersByRestaurant(widget.restaurantId));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderViewModel>(
      builder: (context, orderVM, child) {
        if (orderVM.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (orderVM.error != null) {
          return Center(child: Text(orderVM.error!));
        }
        if (orderVM.orders.isEmpty) {
          return const Center(child: Text('Không có đơn hàng nào.'));
        }
        return ListView.builder(
          itemCount: orderVM.orders.length,
          itemBuilder: (context, index) {
            final order = orderVM.orders[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text('Mã đơn: ${order.id}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Khách: ${order.userId}'),
                    Text('Tổng tiền: ${order.totalAmount}'),
                    Text('Trạng thái: ${order.status.name}'),
                    Text('Ngày tạo: ${order.createdAt}'),
                  ],
                ),
                // Bạn có thể thêm các nút thao tác ở đây
              ),
            );
          },
        );
      },
    );
  }
}

import 'package:admin/models/restaurant_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin/screens/seller/components/seller_side_menu.dart';
import 'package:admin/responsive.dart';
import 'package:admin/viewmodels/order_viewmodel.dart';
import 'package:admin/ultils/const/enum.dart';
import 'package:admin/models/order_model.dart';

class SellerOrderManagementScreen extends StatefulWidget {
  final bool showDetailDialog;
  final String? orderId;

  const SellerOrderManagementScreen({
    super.key,
    this.showDetailDialog = false,
    this.orderId,
  });

  @override
  State<SellerOrderManagementScreen> createState() => _SellerOrderScreenState();
}

class _SellerOrderScreenState extends State<SellerOrderManagementScreen> {
  final Map<String, OrderState?> statusOptions = {
    'Tất cả': null,
    'Chờ xác nhận': OrderState.pending,
    'Đã xác nhận': OrderState.confirmed,
    'Hoàn thành': OrderState.delivered,
    'Đã hủy': OrderState.cancelled,
  };

  String _selectedStatus = 'Tất cả';
  String? restaurantId;
  RestaurantModel? restaurant;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRestaurantData();
  }

  Future<void> _loadRestaurantData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return;
      }

      final restaurantDoc = await FirebaseFirestore.instance
          .collection('restaurants')
          .where('token', isEqualTo: user.uid)
          .get();

      if (restaurantDoc.docs.isNotEmpty) {
        Provider.of<OrderViewModel>(context, listen: false)
            .loadOrdersByRestaurant(
          user.uid,
        );
      } else {}
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: Responsive.isMobile(context) ? null : GlobalKey<ScaffoldState>(),
      drawer: Responsive.isMobile(context) ? const SellerSideMenu() : null,
      appBar: AppBar(
        title: const Text('Quản lý đơn hàng'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (Responsive.isDesktop(context))
              const Expanded(flex: 1, child: SellerSideMenu()),
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  _buildStatusFilter(),
                  Expanded(
                    child: Consumer<OrderViewModel>(
                      builder: (context, orderVM, child) {
                        if (orderVM.isLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final filteredOrders =
                            statusOptions[_selectedStatus] == null
                                ? orderVM.orders
                                : orderVM.orders
                                    .where((order) =>
                                        order.status ==
                                        statusOptions[_selectedStatus])
                                    .toList();

                        if (filteredOrders.isEmpty) {
                          return const Center(
                              child: Text('Không có đơn hàng nào'));
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredOrders.length,
                          itemBuilder: (context, index) {
                            final order = filteredOrders[index];
                            return _buildOrderItem(order);
                          },
                        );
                      },
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

  Widget _buildStatusFilter() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: statusOptions.keys.map(_buildStatusChip).toList(),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final isSelected = _selectedStatus == status;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: FilterChip(
        label: Text(status),
        selected: isSelected,
        onSelected: (_) {
          setState(() {
            _selectedStatus = status;
          });
        },
      ),
    );
  }

  void _showOrderDetailDialog(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chi tiết đơn hàng'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mã đơn hàng: #${order.id}'),
              const SizedBox(height: 8),
              Text('Trạng thái: ${_getStatusText(order.status)}'),
              const SizedBox(height: 8),
              Text('Thời gian đặt: ${order.createdAt}'),
              const SizedBox(height: 16),
              Text('Danh sách món:'),
              const SizedBox(height: 8),
              ...order.items
                  .map((item) => Text(
                      '• ${item.foodName} - ${item.price}đ x${item.quantity}'))
                  .toList(),
              const SizedBox(height: 16),
              Text('Tổng tiền: ${order.totalAmount}đ'),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng')),
          if (order.status == OrderState.pending)
            ElevatedButton(
                onPressed: () async {
                  final orderVM =
                      Provider.of<OrderViewModel>(context, listen: false);
                  await orderVM.updateOrderStatus(
                      order.id, OrderState.confirmed.name);
                  Navigator.pop(context);
                  _loadRestaurantData();
                },
                child: const Text('Xác nhận đơn')),
        ],
      ),
    );
  }

  String _getStatusText(OrderState status) {
    switch (status) {
      case OrderState.pending:
        return 'Chờ xác nhận';
      case OrderState.confirmed:
        return 'Đã xác nhận';
      case OrderState.delivered:
        return 'Hoàn thành';
      case OrderState.cancelled:
        return 'Đã hủy';
      default:
        return status.name;
    }
  }

  Widget _buildOrderItem(order) {
    return Card(
      child: ListTile(
        leading: order.items.isNotEmpty && order.items.first.image != null
            ? CircleAvatar(
                backgroundImage: NetworkImage(order.items.first.image),
              )
            : const CircleAvatar(child: Icon(Icons.shopping_cart)),
        title: Text('Mã đơn: #${order.id}'),
        subtitle: Text(
            'Tổng tiền: ${order.totalAmount}đ\nTrạng thái: ${_getStatusText(order.status)}'),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'view', child: Text('Xem chi tiết')),
            if (order.status == OrderState.pending)
              const PopupMenuItem(value: 'confirm', child: Text('Xác nhận')),
            if (order.status == OrderState.confirmed)
              const PopupMenuItem(
                  value: 'delivered', child: Text('Hoàn thành')),
            const PopupMenuItem(value: 'cancel', child: Text('Hủy đơn')),
          ],
          onSelected: (value) async {
            final orderVM = Provider.of<OrderViewModel>(context, listen: false);
            if (value == 'view') {
              _showOrderDetailDialog(order);
            } else if (value == 'confirm') {
              await orderVM.updateOrderStatus(
                  order.id, OrderState.confirmed.name);
              _loadRestaurantData();
            } else if (value == 'delivered') {
              await orderVM.updateOrderStatus(
                  order.id, OrderState.delivered.name);
              _loadRestaurantData();
            } else if (value == 'cancel') {
              await orderVM.cancelOrder(order.id, 'Seller cancelled');
              _loadRestaurantData();
            }
          },
        ),
      ),
    );
  }
}

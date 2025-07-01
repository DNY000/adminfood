import 'package:admin/screens/restaurant/widget/food_by_restaurant.dart';
import 'package:admin/screens/restaurant/widget/order_by_restaurant.dart';
import 'package:admin/screens/restaurant/widget/thong_ke.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:admin/routes/name_router.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final String restaurantId;
  final int initialTab;
  final bool showAddFoodDialog;
  final bool showUpdateFoodDialog;
  final String? foodId;

  const RestaurantDetailScreen({
    Key? key,
    required this.restaurantId,
    this.initialTab = 0,
    this.showAddFoodDialog = false,
    this.showUpdateFoodDialog = false,
    this.foodId,
  }) : super(key: key);

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab,
    );

    // Show dialogs if needed after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDialogsIfNeeded();
    });
  }

  @override
  void didUpdateWidget(covariant RestaurantDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.restaurantId != oldWidget.restaurantId ||
        widget.initialTab != oldWidget.initialTab ||
        widget.showAddFoodDialog != oldWidget.showAddFoodDialog ||
        widget.showUpdateFoodDialog != oldWidget.showUpdateFoodDialog ||
        widget.foodId != oldWidget.foodId) {
      _tabController.index = widget.initialTab;
      _showDialogsIfNeeded();
    }
  }

  void _showDialogsIfNeeded() {
    if (widget.showAddFoodDialog == true) {
      _showAddFoodDialog();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted)
          context.go(
              '${NameRouter.detailRestaurants}/${widget.restaurantId}?tab=${_tabController.index}');
      });
    } else if (widget.showUpdateFoodDialog == true && widget.foodId != null) {
      _showUpdateFoodDialog(widget.foodId!);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted)
          context.go(
              '${NameRouter.detailRestaurants}/${widget.restaurantId}?tab=${_tabController.index}');
      });
    }
  }

  void _showAddFoodDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm món ăn mới'),
        content: Text('Dialog thêm món ăn cho nhà hàng ${widget.restaurantId}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Handle add food logic
              Navigator.pop(context);
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _showUpdateFoodDialog(String foodId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cập nhật món ăn'),
        content: Text(
            'Dialog cập nhật món ăn $foodId cho nhà hàng ${widget.restaurantId}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Handle update food logic
              Navigator.pop(context);
            },
            child: const Text('Cập nhật'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết Nhà hàng'),
        leading: IconButton(
          onPressed: () {
            context.go(NameRouter.restaurants);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Thống kê'),
            Tab(text: 'Đơn hàng'),
            Tab(text: 'Món ăn'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          DoanhThuByRestaurantScreen(restaurantId: widget.restaurantId),
          OrderByRestaurantScreen(restaurantId: widget.restaurantId),
          FoodByRestaurantScreen(restaurantId: widget.restaurantId),
        ],
      ),
    );
  }
}

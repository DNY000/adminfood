import 'package:admin/data/repositories/food_repository.dart';
import 'package:admin/data/repositories/order_repository.dart';
import 'package:admin/data/repositories/user_repository.dart';
import 'package:admin/models/cart_item_model.dart';
import 'package:admin/models/food_model.dart';
import 'package:admin/models/notification_model.dart';
import 'package:admin/models/order_model.dart';
import 'package:admin/models/shipper_model.dart';
import 'package:admin/models/user_model.dart';
import 'package:admin/services/notifications_service.dart';
import 'package:admin/ultils/const/enum.dart';
import 'package:admin/viewmodels/notification_viewmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class OrderViewModel extends ChangeNotifier {
  final OrderRepository _repository;
  List<OrderModel> _orders = [];
  OrderModel? _selectedOrder;
  bool _isLoading = false;
  String? _error;
  final FoodRepository _foodRepository;
  List<Map<String, dynamic>> _topSellingFoods = [];
  List<FoodModel> _recommendedFoods = [];
  Stream<List<OrderModel>>? _ordersStream;
  List<int>? _orderStats = [];
  bool _isStatsLoading = false;
  String? _statsError;
  List<OrderModel> _recentOrders = [];
  int _todayOrderCount = 0;
  double _todayRevenue = 0;

  OrderViewModel(this._repository, {FoodRepository? foodRepository})
      : _foodRepository = foodRepository ?? FoodRepository();

  // Getters
  List<OrderModel> get orders => _orders;
  OrderModel? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, dynamic>> get topSellingFoods => _topSellingFoods;
  List<FoodModel> get recommendedFoods => _recommendedFoods;
  Stream<List<OrderModel>>? get ordersStream => _ordersStream;
  List<int> get orderStats => _orderStats ?? [];
  bool get isStatsLoading => _isStatsLoading;
  String? get statsError => _statsError;
  List<OrderModel> get recentOrders => _recentOrders;
  int get todayOrderCount => _todayOrderCount;
  double get todayRevenue => _todayRevenue;

  // Tạo đơn hàng mới
  Future<void> createOrder({
    required String userId,
    required String restaurantId,
    required List<CartItemModel> items,
    required String address,
    required PaymentMethod paymentMethod,
    String? note,
    UserModel? currentUser,
  }) async {
    try {
      final _notificationViewModel = NotificationViewModel();
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Tính tổng tiền
      final totalAmount = items.fold<double>(
        0,
        (sum, item) => sum + item.totalAmount,
      );

      // Lấy thông tin người dùng hiện tại nếu chưa được cung cấp
      UserModel? user = currentUser;
      if (user == null) {
        final userRepository = UserRepository();
        user = await userRepository.getUserById(userId);
      }

      // Lấy vị trí nhà hàng cố định từ Firestore
      String restaurantName = '';
      GeoPoint? restaurantLocation;
      final doc = await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restaurantId)
          .get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['location'] is GeoPoint) {
          restaurantLocation = data['location'] as GeoPoint;
          restaurantName = data['name'] ?? '';
        }
      }

      // Tạo metadata với thông tin người dùng
      final Map<String, dynamic> orderMetadata = {
        'fullName': user?.name ?? '',
        'phoneNumber': user?.phoneNumber ?? '',
        'address': user?.defaultAddress?.street ?? '',
        'createdAt': Timestamp.now(),
      };

      // Tạo đơn hàng mới
      final order = OrderModel(
        id: '',
        userId: userId,
        restaurantId: restaurantId,
        restaurantName: restaurantName,
        items: items,
        totalAmount: totalAmount,
        address: address,
        paymentMethod: paymentMethod,
        status: OrderState.pending,
        createdAt: DateTime.now(),
        note: note,
        idShipper: "",
        metadata: orderMetadata,
        restaurantLocation: restaurantLocation,
      );

      await _repository.createOrder(order);

      final notification = NotificationModel(
        id: '',
        userId: userId,
        title: 'Đặt đơn thành công',
        content: 'Xem chi tiết',
        type: NotificationType.order.name,
        createdAt: DateTime.now(),
        isRead: false,
        data: {},
      );
      await _notificationViewModel.createNotification(notification);
      await NotificationsService.showLocalNotification(
        title: 'Đặt đơn thành công',
        body: 'Xem chi tiết',
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Lấy danh sách đơn hàng của user
  Future<bool> loadUserOrders(String userId) async {
    _isLoading = true;
    _error = null;
    _orders = []; // Xoá dữ liệu cũ để tránh hiển thị nhầm
    notifyListeners();

    try {
      final orders = await _repository.getUserOrders(userId);
      _orders = orders;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e, stack) {
      _orders = [];
      _error = e.toString();
      _isLoading = false;
      debugPrint('Lỗi loadUserOrders: $e\n$stack');
      notifyListeners();
      return false;
    }
  }

  @Deprecated('Use loadUserOrders instead')
  void listenToUserOrders(String userId) {
    loadUserOrders(userId);
  }

  // Hủy đơn hàng
  Future<void> cancelOrder(String orderId, String reason) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.cancelOrder(orderId, reason);

      // Cập nhật lại trạng thái đơn hàng trong danh sách
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        final updatedOrder = _orders[index].copyWith(
          status: OrderState.cancelled,
          cancelReason: reason,
        );
        _orders[index] = updatedOrder;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Cập nhật trạng thái đơn hàng
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      _setLoading(true);
      await _repository.updateOrderStatus(orderId, status);
      _error = null;
    } catch (e) {
      _error = 'Không thể cập nhật trạng thái đơn hàng: $e';
      if (kDebugMode) {
        print(_error);
      }
    } finally {
      _setLoading(false);
    }
  }

  // Lấy đơn hàng theo ngày
  Future<void> loadOrders({
    DateTime? fromDate,
    DateTime? toDate,
    OrderState? status,
    int limit = 10,
  }) async {
    try {
      _setLoading(true);
      _orders = await _repository.getOrders(
        fromDate: fromDate,
        toDate: toDate,
        status: status,
        limit: limit,
      );
      _error = null;
    } catch (e) {
      _error = 'Không thể tải danh sách đơn hàng: $e';
      if (kDebugMode) {
        print(_error);
      }
    } finally {
      _setLoading(false);
    }
  }

  // // Lấy đơn hàng theo khách hàng
  // Future<void> loadOrdersByCustomer(
  //   String customerId, {
  //   OrderState? status,
  //   int limit = 10,
  // }) async {
  //   try {
  //     _setLoading(true);
  //     _orders = await _repository.getOrdersByCustomer(
  //       customerId,
  //       status: status,
  //       limit: limit,
  //     );
  //     _error = null;
  //   } catch (e) {
  //     _error = 'Không thể tải đơn hàng của khách hàng: $e';
  //     if (kDebugMode) {
  //       print(_error);
  //     }
  //   } finally {
  //     _setLoading(false);
  //   }
  // }

  // Lấy đơn hàng theo nhà hàng
  Future<void> loadOrdersByRestaurant(String restaurantId,
      {int limit = 10, OrderState? status}) async {
    try {
      _setLoading(true);
      _orders = await _repository.getOrdersByRestaurant(
        restaurantId,
        status: status,
        limit: limit,
      );
      _error = null;
    } catch (e) {
      _error = 'Không thể tải đơn hàng của nhà hàng: $e';
      if (kDebugMode) {
        print(_error);
      }
    } finally {
      _setLoading(false);
    }
  }

  // Lấy thống kê món ăn bán chạy
  Future<List<FoodModel>> getTopSellingFoods({
    String? restaurantId,
    int limit = 10,
  }) async {
    try {
      _setLoading(true);
      final result = await _repository.getTopSellingFoods(
        restaurantId: restaurantId ?? '',
        limit: limit,
      );
      _error = null;
      return result;
    } catch (e) {
      _error = 'Không thể lấy thống kê món ăn bán chạy: $e';
      if (kDebugMode) {
        print(_error);
      }
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // Lấy thống kê doanh thu
  Future<Map<String, dynamic>> getRevenueStats({
    String? restaurantId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      _setLoading(true);
      final result = await _repository.getRevenueStats(
        // restaurantId: restaurantId,
        fromDate: fromDate,
        toDate: toDate,
      );
      _error = null;
      return result;
    } catch (e) {
      _error = 'Không thể lấy thống kê doanh thu: $e';
      if (kDebugMode) {
        print(_error);
      }
      return {};
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setSelectedOrder(OrderModel order) {
    _selectedOrder = order;
    notifyListeners();
  }

  void clearSelectedOrder() {
    _selectedOrder = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Lọc đơn hàng theo trạng thái
  List<OrderModel> filterByStatus(OrderState status) {
    return _orders.where((order) => order.status == status).toList();
  }

  // Lọc đơn hàng theo khoảng thời gian
  List<OrderModel> filterByDateRange(DateTime fromDate, DateTime toDate) {
    return _orders
        .where(
          (order) =>
              order.orderTime.isAfter(fromDate) &&
              order.orderTime.isBefore(toDate),
        )
        .toList();
  }

  // Sắp xếp theo thời gian
  void sortByOrderTime({bool ascending = false}) {
    _orders.sort(
      (a, b) => ascending
          ? a.orderTime.compareTo(b.orderTime)
          : b.orderTime.compareTo(a.orderTime),
    );
    notifyListeners();
  }

  // Sắp xếp theo tổng tiền
  void sortByTotalAmount({bool ascending = false}) {
    _orders.sort(
      (a, b) => ascending
          ? a.totalPrice.compareTo(b.totalPrice)
          : b.totalPrice.compareTo(a.totalPrice),
    );
    notifyListeners();
  }

  // Thêm phương thức để lọc món ăn bán chạy theo danh mục
  List<Map<String, dynamic>> getTopSellingFoodsByCategory(String category) {
    return _topSellingFoods
        .where((food) => food['category'] == category)
        .toList();
  }

  // Thêm phương thức để lấy tổng doanh thu của các món ăn bán chạy
  double getTotalRevenue() {
    return _topSellingFoods.fold(
      0,
      (sum, food) => sum + (food['totalRevenue'] as double),
    );
  }

  // Thêm phương thức để lấy tổng số lượng món đã bán
  int getTotalQuantitySold() {
    return _topSellingFoods.fold(
      0,
      (sum, food) => sum + (food['quantity'] as int),
    );
  }

  Future<void> loadRecommendedFoods() async {
    _isLoading = true;
    notifyListeners();

    try {
      _recommendedFoods = await _foodRepository.getRecommendedFoods();
    } catch (e) {
      debugPrint('Error loading recommended foods: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Lấy danh sách đơn hàng đang chờ shipper
  void listenToOrdersWaitingForShipper() {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _ordersStream = _repository.getOrdersWaitingForShipper();
    _ordersStream?.listen(
      (orders) {
        _orders = orders;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Shipper nhận đơn hàng
  Future<void> acceptOrder(String orderId, String shipperId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.assignShipperToOrder(orderId, shipperId);

      // Cập nhật lại trạng thái đơn hàng trong danh sách
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        final updatedOrder = _orders[index].copyWith(
          idShipper: shipperId,
          status: OrderState.shipperAssigned,
        );
        _orders[index] = updatedOrder;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Lấy danh sách đơn hàng của shipper
  void listenToShipperOrders(String shipperId) {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _ordersStream = _repository.getShipperOrders(shipperId);
    _ordersStream?.listen(
      (orders) {
        _orders = orders;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> updateDeliveryStatus(String orderId, OrderState status) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.updateDeliveryStatus(orderId, status);

      // Cập nhật lại trạng thái đơn hàng trong danh sách
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        final updatedOrder = _orders[index].copyWith(status: status);
        _orders[index] = updatedOrder;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateShipperLocation(String orderId, GeoPoint location) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.updateShipperLocation(orderId, location);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<ShipperModel> getShipperInfo(String shipperId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final info = await _repository.getShipperInfo(shipperId);

      _isLoading = false;
      notifyListeners();
      return info;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Thống kê số lượng đơn hàng
  Future<void> getOrderStats(String period) async {
    try {
      _isStatsLoading = true;
      _statsError = null;
      notifyListeners();

      _orderStats = await _repository.getOrderStats(period);
    } catch (e) {
      _statsError = e.toString();
      if (kDebugMode) {
        print('Error getting order stats: $e');
      }
    } finally {
      _isStatsLoading = false;
      notifyListeners();
    }
  }

  // Lấy 5 đơn hàng gần nhất
  Future<void> loadRecentOrders() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _recentOrders = await _repository.getRecentOrders();
      print('don hang gan nhat ${_recentOrders.length}');
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error loading recent orders: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Lấy tên nhà hàng theo ID
  Future<String> getRestaurantName(String restaurantId) async {
    try {
      return await _repository.getRestaurantName(restaurantId);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting restaurant name: $e');
      }
      return 'Không xác định';
    }
  }

  // Lấy số lượng đơn hàng hôm nay
  Future<void> loadTodayOrderCount() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _todayOrderCount = await _repository.getTodayOrderCount();
      print('số lương đơn hôm nay $_todayOrderCount');
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error loading today order count: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Lấy doanh thu hôm nay
  Future<void> loadTodayRevenue() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _todayRevenue = await _repository.getTodayRevenue();
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error loading today revenue: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

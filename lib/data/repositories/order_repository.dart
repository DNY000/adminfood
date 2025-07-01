import 'package:admin/data/repositories/food_repository.dart';
import 'package:admin/models/food_model.dart';
import 'package:admin/models/order_model.dart';
import 'package:admin/models/shipper_model.dart';
import 'package:admin/ultils/const/enum.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:intl/intl.dart';

class OrderRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'orders';

  OrderRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Tạo đơn hàng mới
  Future<String> createOrder(OrderModel order) async {
    try {
      final docRef = _firestore.collection(_collection).doc();
      final orderWithId = order.copyWith(id: docRef.id);
      await docRef.set(orderWithId.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Không thể tạo đơn hàng: $e');
    }
  }

  // Lấy danh sách đơn hàng của người dùng
  Future<List<OrderModel>> getUserOrders(String userId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs
        .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Lấy chi tiết một đơn hàng
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(orderId).get();
      if (!doc.exists) return null;
      return OrderModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Không thể lấy thông tin đơn hàng: $e');
    }
  }

  // Cập nhật trạng thái đơn hàng
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore.collection(_collection).doc(orderId).update({
        'status': newStatus,
      });
    } catch (e) {
      throw Exception('Không thể cập nhật trạng thái đơn hàng: $e');
    }
  }

  // Hủy đơn hàng
  Future<void> cancelOrder(String orderId, String reason) async {
    try {
      await _firestore.collection(_collection).doc(orderId).update({
        'status': OrderState.cancelled.toString().split('.').last,
        'cancelReason': reason,
      });
    } catch (e) {
      throw Exception('Không thể hủy đơn hàng: $e');
    }
  }

  // Lấy đơn hàng của nhà hàng
  Stream<List<OrderModel>> getRestaurantOrders(String restaurantId) {
    return _firestore
        .collection(_collection)
        .where('restaurantId', isEqualTo: restaurantId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // Lấy số lượng đơn hàng theo trạng thái
  Future<int> getOrderCountByStatus(String userId, OrderState status) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: status.toString().split('.').last)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw Exception('Không thể lấy số lượng đơn hàng: $e');
    }
  }

  // Cập nhật thông tin giao hàng
  Future<void> updateDeliveryInfo(
    String orderId,
    Map<String, dynamic> deliveryInfo,
  ) async {
    try {
      await _firestore.collection(_collection).doc(orderId).update({
        'delivery': deliveryInfo,
        'metadata.lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Không thể cập nhật thông tin giao hàng: $e');
    }
  }

  // Lấy đơn hàng theo ngày
  Future<List<OrderModel>> getOrders({
    DateTime? fromDate,
    DateTime? toDate,
    OrderState? status,
    int limit = 10,
  }) async {
    try {
      Query query = _firestore.collection(_collection);

      if (fromDate != null) {
        query = query.where(
          'metadata.orderTime',
          isGreaterThanOrEqualTo: Timestamp.fromDate(fromDate),
        );
      }

      if (toDate != null) {
        query = query.where(
          'metadata.orderTime',
          isLessThanOrEqualTo: Timestamp.fromDate(toDate),
        );
      }

      if (status != null) {
        query = query.where('metadata.status', isEqualTo: status.name);
      }

      query =
          query.orderBy('metadata.orderTime', descending: true).limit(limit);

      final snapshot = await query.get();
      return snapshot.docs
          .map(
            (doc) =>
                OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      throw Exception('Không thể lấy danh sách đơn hàng: $e');
    }
  }

  // Lấy đơn hàng theo khách hàng
  Future<List<OrderModel>> getOrdersByCustomer(
    String customerId, {
    OrderState? status,
    int limit = 10,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('participants.customerId', isEqualTo: customerId);

      if (status != null) {
        query = query.where('metadata.status', isEqualTo: status.name);
      }

      query =
          query.orderBy('metadata.orderTime', descending: true).limit(limit);

      final snapshot = await query.get();
      return snapshot.docs
          .map(
            (doc) =>
                OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      throw Exception('Không thể lấy đơn hàng của khách hàng: $e');
    }
  }

  // Lấy đơn hàng theo nhà hàng
  Future<List<OrderModel>> getOrdersByRestaurant(
    String restaurantId, {
    OrderState? status,
    int limit = 10,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('restaurantId', isEqualTo: restaurantId);
      // query = query.orderBy('createdAt', descending: true).limit(limit);

      final snapshot = await query.get();
      var orders = snapshot.docs
          .map(
            (doc) =>
                OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
      if (status != null) {
        orders = orders.where((order) => order.status == status).toList();
      }
      return orders;
    } catch (e) {
      throw Exception('Không thể lấy đơn hàng của nhà hàng: $e');
    }
  }

  // Thống kê món ăn bán chạy
  Future<List<FoodModel>> getTopSellingFoods({
    required String restaurantId,
    int limit = 10,
  }) async {
    try {
      // Lấy tất cả order của nhà hàng có trạng thái delivered
      Query query = _firestore
          .collection(_collection)
          .where('status', isEqualTo: OrderState.delivered.name);
      // .where('restaurantId', isEqualTo: restaurantId);

      final snapshot = await query.get();
      Map<String, int> foodCount = {};
      for (var doc in snapshot.docs) {
        final order = OrderModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
        for (var item in order.items) {
          final foodKey = item.foodId;
          if (foodKey.isEmpty) continue;
          foodCount[foodKey] = (foodCount[foodKey] ?? 0) + 1;
        }
      }

      // Sắp xếp theo số lần xuất hiện giảm dần
      var sortedFoodIds = foodCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final topFoodIds = sortedFoodIds.take(limit).map((e) => e.key).toList();

      // Lấy chi tiết từng món ăn
      List<FoodModel> foods = [];
      for (final id in topFoodIds) {
        try {
          final food = await FoodRepository().getFoodById(id);
          foods.add(food);
        } catch (e) {
          continue;
        }
      }
      return foods;
    } catch (e) {
      throw Exception('Không thể lấy thống kê món ăn bán chạy: $e');
    }
  }

  // Tính doanh thu hôm nay
  Future<double> getTodayRevenue() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Lấy tất cả đơn hàng đã hoàn thành
      final snapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: OrderState.delivered.name)
          .get();

      double totalRevenue = 0;
      for (var doc in snapshot.docs) {
        final order =
            OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        // Lọc theo thời gian ở phía client
        if (order.createdAt.isAfter(startOfDay) &&
            order.createdAt.isBefore(endOfDay)) {
          totalRevenue += order.totalPrice;
        }
      }

      return totalRevenue;
    } catch (e) {
      print('Error calculating today revenue: $e');
      return 0;
    }
  }

  // Tính doanh thu từ đơn hàng đã hoàn thành
  Future<Map<String, dynamic>> getRevenueStats({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      // Lấy tất cả đơn hàng đã hoàn thành
      final snapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: OrderState.delivered.name)
          .get();

      double totalRevenue = 0;
      int totalOrders = 0;
      Map<String, double> dailyRevenue = {};

      for (var doc in snapshot.docs) {
        final order =
            OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);

        // Lọc theo khoảng thời gian ở phía client
        if (fromDate != null && order.createdAt.isBefore(fromDate)) continue;
        if (toDate != null && order.createdAt.isAfter(toDate)) continue;

        totalRevenue += order.totalPrice;
        totalOrders++;

        // Thống kê theo ngày
        final dateKey = DateFormat('yyyy-MM-dd').format(order.createdAt);
        dailyRevenue[dateKey] = (dailyRevenue[dateKey] ?? 0) + order.totalPrice;
      }

      return {
        'totalRevenue': totalRevenue,
        'totalOrders': totalOrders,
        'averageOrderValue': totalOrders > 0 ? totalRevenue / totalOrders : 0,
        'dailyRevenue': dailyRevenue,
      };
    } catch (e) {
      print('Error calculating revenue: $e');
      return {
        'totalRevenue': 0,
        'totalOrders': 0,
        'averageOrderValue': 0,
        'dailyRevenue': {},
      };
    }
  }

  // Lấy danh sách đơn hàng đang chờ shipper
  Stream<List<OrderModel>> getOrdersWaitingForShipper() {
    return _firestore
        .collection(_collection)
        .where(
          'status',
          isEqualTo: OrderState.waitingForShipper.toString().split('.').last,
        )
        .where('idShipper', isEqualTo: '')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // Cập nhật shipper cho đơn hàng
  Future<void> assignShipperToOrder(String orderId, String shipperId) async {
    try {
      await _firestore.collection(_collection).doc(orderId).update({
        'idShipper': shipperId,
        'status': OrderState.shipperAssigned.toString().split('.').last,
      });
    } catch (e) {
      throw Exception('Không thể cập nhật shipper cho đơn hàng: $e');
    }
  }

  // Lấy danh sách đơn hàng của shipper
  Stream<List<OrderModel>> getShipperOrders(String shipperId) {
    return _firestore
        .collection(_collection)
        .where('idShipper', isEqualTo: shipperId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // Cập nhật trạng thái giao hàng
  Future<void> updateDeliveryStatus(String orderId, OrderState status) async {
    try {
      await _firestore.collection(_collection).doc(orderId).update({
        'status': status.toString().split('.').last,
      });
    } catch (e) {
      throw Exception('Không thể cập nhật trạng thái giao hàng: $e');
    }
  }

  // Cập nhật vị trí shipper
  Future<void> updateShipperLocation(String orderId, GeoPoint location) async {
    try {
      await _firestore.collection(_collection).doc(orderId).update({
        'delivery.location': location,
        'delivery.lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Không thể cập nhật vị trí shipper: $e');
    }
  }

  // Lấy thông tin shipper
  Future<ShipperModel> getShipperInfo(String shipperId) async {
    try {
      final doc = await _firestore.collection('shippers').doc(shipperId).get();
      if (!doc.exists) throw Exception('Không tìm thấy shipper');
      return ShipperModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw Exception('Không thể lấy thông tin shipper: $e');
    }
  }

  // Thống kê số lượng đơn hàng theo thời gian
  Future<List<int>?> getOrderStats(String period) async {
    try {
      final now = DateTime.now();
      final List<int> stats = [];

      if (period == 'week') {
        // Lấy số lượng đơn hàng trong 7 ngày gần nhất
        for (int i = 6; i >= 0; i--) {
          final date = now.subtract(Duration(days: i));
          final startOfDay = DateTime(date.year, date.month, date.day);
          final endOfDay = startOfDay.add(const Duration(days: 1));

          final snapshot = await _firestore
              .collection(_collection)
              .where('createdAt',
                  isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
              .where('createdAt', isLessThan: Timestamp.fromDate(endOfDay))
              .count()
              .get();

          stats.add(snapshot.count ?? 0);
        }
      } else {
        // Lấy số lượng đơn hàng trong 12 tháng gần nhất
        for (int i = 11; i >= 0; i--) {
          final date = DateTime(now.year, now.month - i, 1);
          final startOfMonth = DateTime(date.year, date.month, 1);
          final endOfMonth = DateTime(date.year, date.month + 1, 1);

          final snapshot = await _firestore
              .collection(_collection)
              .where('createdAt',
                  isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
              .where('createdAt', isLessThan: Timestamp.fromDate(endOfMonth))
              .count()
              .get();

          stats.add(snapshot.count ?? 0);
        }
      }

      return stats;
    } catch (e) {
      throw Exception('Không thể lấy thống kê đơn hàng: $e');
    }
  }

  // Lấy 5 đơn hàng gần nhất
  Future<List<OrderModel>> getRecentOrders() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();
      print('DOn hoang gan nhat');
      return snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Không thể lấy danh sách đơn hàng gần đây: $e');
    }
  }

  // Lấy tên nhà hàng theo ID
  Future<String> getRestaurantName(String restaurantId) async {
    try {
      final doc =
          await _firestore.collection('restaurants').doc(restaurantId).get();
      if (!doc.exists) return 'Không xác định';
      return doc.data()?['name'] ?? 'Không xác định';
    } catch (e) {
      print('Error getting restaurant name: $e');
      return 'Không xác định';
    }
  }

  // Lấy số lượng đơn hàng hôm nay
  Future<int> getTodayOrderCount() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _firestore
          .collection(_collection)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('createdAt', isLessThan: Timestamp.fromDate(endOfDay))
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      print('Error getting today order count: $e');
      return 0;
    }
  }
}

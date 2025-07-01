import 'package:admin/models/cart_item_model.dart';
import 'package:admin/ultils/const/enum.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String userId;
  final String restaurantId;
  final String restaurantName;
  final List<CartItemModel> items;
  final double totalAmount;
  final String address;
  final PaymentMethod paymentMethod;
  final OrderState status;
  final DateTime createdAt;
  final String? note;
  final String? cancelReason;
  final Map<String, dynamic>? delivery;
  final Map<String, dynamic>? metadata;
  final String idShipper;
  final GeoPoint? restaurantLocation;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.items,
    required this.restaurantName,
    required this.totalAmount,
    required this.address,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    this.note,
    this.cancelReason,
    this.delivery,
    this.metadata,
    this.idShipper = "",
    this.restaurantLocation,
  });

  // Tính tổng giá trị đơn hàng
  double get totalPrice {
    return items.fold(0.0, (sum, item) {
      final price = item.price.toDouble();
      final quantity = item.quantity;
      return sum + (price * quantity);
    });
  }

  // Alias cho createdAt để tương thích với code cũ
  DateTime get orderTime => createdAt;

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    final statusStr = map['status']?.toString() ?? '';
    return OrderModel(
      id: id,
      userId: map['userId'] ?? '',
      restaurantId: map['restaurantId'] ?? '',
      restaurantName: map['restaurantName'] ?? '',
      items: (map['items'] as List<dynamic>?)
              ?.map((e) => CartItemModel.fromMap(e))
              .toList() ??
          [],
      totalAmount: map['totalAmount'] ?? 0.0,
      address: map['address'] ?? '',
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.toString() == map['paymentMethod'],
        orElse: () => PaymentMethod.thanhtoankhinhanhang,
      ),
      status: OrderState.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => OrderState.pending, // hoặc giá trị mặc định của bạn
      ),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      note: map['note'] ?? '',
      idShipper: map['idShipper'] ?? '',
      metadata: map['metadata'] ?? {},
      restaurantLocation: map['restaurantLocation'] as GeoPoint?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'restaurantId': restaurantId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'address': address,
      'paymentMethod': paymentMethod.toString().split('.').last,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'note': note,
      'cancelReason': cancelReason,
      'delivery': delivery,
      'metadata': metadata,
      'idShipper': idShipper,
      'restaurantLocation': restaurantLocation,
    };
  }

  // Helper method để hiển thị thông tin đơn hàng ngắn gọn
  Map<String, dynamic> toListView() {
    final firstItem = items.isNotEmpty ? items.first : null;
    final itemsDescription = firstItem != null
        ? "${firstItem.foodName} ${items.length > 1 ? 'và ${items.length - 1} món khác' : ''}"
        : "Không có món";

    return {
      'id': id,
      'createdAt': createdAt,
      'status': status.name,
      'totalAmount': totalAmount,
      'itemsDescription': itemsDescription,
      'itemCount': items.length,
    };
  }

  // Copy with method để tạo bản sao với một số thuộc tính được thay đổi
  OrderModel copyWith({
    String? id,
    String? userId,
    String? restaurantId,
    List<CartItemModel>? items,
    double? totalAmount,
    String? address,
    PaymentMethod? paymentMethod,
    OrderState? status,
    DateTime? createdAt,
    String? note,
    String? cancelReason,
    Map<String, dynamic>? delivery,
    Map<String, dynamic>? metadata,
    String? idShipper,
    GeoPoint? restaurantLocation,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      restaurantId: restaurantId ?? this.restaurantId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      address: address ?? this.address,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      note: note ?? this.note,
      cancelReason: cancelReason ?? this.cancelReason,
      delivery: delivery ?? this.delivery,
      metadata: metadata ?? this.metadata,
      idShipper: idShipper ?? this.idShipper,
      restaurantLocation: restaurantLocation ?? this.restaurantLocation,
      restaurantName: restaurantName,
    );
  }
}

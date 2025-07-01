class CartItemModel {
  final String id;
  final String foodId;
  final String foodName;
  final int quantity;
  final double price;
  final String image;
  final String? note;
  final Map<String, dynamic>? options;

  CartItemModel({
    required this.id,
    required this.foodId,
    required this.foodName,
    required this.quantity,
    required this.price,
    required this.image,
    this.note,
    this.options,
  });

  // Tính tổng tiền cho item này
  double get totalAmount => price * quantity;

  CartItemModel copyWith({
    String? id,
    String? foodId,
    String? foodName,
    int? quantity,
    double? price,
    String? image,
    String? note,
    Map<String, dynamic>? options,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      foodId: foodId ?? this.foodId,
      foodName: foodName ?? this.foodName,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      image: image ?? this.image,
      note: note ?? this.note,
      options: options ?? this.options,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'foodId': foodId,
      'foodName': foodName,
      'quantity': quantity,
      'price': price,
      'image': image,
      'note': note,
      'options': options,
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      id: (map['id'] ?? DateTime.now().toString()).toString(),
      foodId: (map['foodId'] ?? '').toString(),
      foodName: (map['foodName'] ?? '').toString(),
      quantity: (map['quantity'] is int)
          ? map['quantity'] as int
          : int.tryParse(map['quantity']?.toString() ?? '0') ?? 0,
      price: (map['price'] is num)
          ? (map['price'] as num).toDouble()
          : double.tryParse(map['price']?.toString() ?? '0') ?? 0.0,
      image: (map['image'] ?? '').toString(),
      note: map['note']?.toString(),
      options: map['options'] as Map<String, dynamic>?,
    );
  }

  // Để tương thích với code cũ sử dụng toJson
  Map<String, dynamic> toJson() => toMap();

  // Helper method để tạo JSON đơn giản cho hiển thị trong danh sách
  Map<String, dynamic> toListItemMap() {
    return {
      'foodName': foodName,
      'foodImage': image,
      'quantity': quantity,
      'totalPrice': totalAmount,
    };
  }
}

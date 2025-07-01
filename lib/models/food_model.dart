import 'package:admin/ultils/const/enum.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FoodModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final List<String> images;
  final List<String> ingredients;
  final CategoryFood category;
  final String restaurantId;
  final bool isAvailable;
  final double rating;
  final int soldCount;
  final Timestamp createdAt;

  FoodModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.images,
    required this.ingredients,
    required this.category,
    required this.restaurantId,
    this.isAvailable = true,
    this.rating = 0.0,
    this.soldCount = 0,
    required this.createdAt,
  });

  factory FoodModel.fromMap(Map<String, dynamic> map, String docId) {
    return FoodModel(
      id: docId,
      name: map['name'] ?? "",
      description: map['description'] ?? "",
      price: (map['price'] as num).toDouble(),
      discountPrice: (map['discountPrice'] as num?)?.toDouble(),
      images: List<String>.from(map['images'] as List),
      ingredients: List<String>.from(map['ingredients'] as List),
      category: CategoryFood.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => CategoryFood.other,
      ),
      restaurantId: map['restaurantId'] ?? "",
      isAvailable: map['isAvailable'] as bool? ?? true,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      soldCount: map['soldCount'] as int? ?? 0,
      createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'discountPrice': discountPrice,
      'images': images,
      'ingredients': ingredients,
      'category': category.name,
      'restaurantId': restaurantId,
      'isAvailable': isAvailable,
      'rating': rating,
      'soldCount': soldCount,
      'createdAt': createdAt,
    };
  }

  FoodModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? discountPrice,
    List<String>? images,
    List<String>? ingredients,
    CategoryFood? category,
    String? restaurantId,
    bool? isAvailable,
    double? rating,
    int? soldCount,
    Timestamp? createdAt,
  }) {
    return FoodModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      images: images ?? this.images,
      ingredients: ingredients ?? this.ingredients,
      category: category ?? this.category,
      restaurantId: restaurantId ?? this.restaurantId,
      isAvailable: isAvailable ?? this.isAvailable,
      rating: rating ?? this.rating,
      soldCount: soldCount ?? this.soldCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Tính giá cuối cùng sau khi giảm giá
  double get finalPrice => discountPrice ?? price;

  // Tính phần trăm giảm giá
  double get discountPercentage {
    if (discountPrice == null || discountPrice! >= price) return 0;
    return ((price - discountPrice!) / price) * 100;
  }
}

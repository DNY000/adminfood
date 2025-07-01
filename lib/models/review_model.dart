import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  String id;
  String userId;
  String targetId; // restaurantId, foodId, hoặc orderId
  String targetType; // 'restaurant', 'food', hoặc 'delivery'
  double rating;
  String comment;
  List<String> images;
  DateTime createdAt;
  int likeCount;
  int reviewCount;
  // Thêm các trường cho đánh giá giao hàng
  String? shipperId;
  double? deliveryRating;
  String? deliveryComment;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.targetId,
    required this.targetType,
    required this.rating,
    required this.comment,
    required this.images,
    required this.createdAt,
    required this.likeCount,
    required this.reviewCount,
    this.shipperId,
    this.deliveryRating,
    this.deliveryComment,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseCreatedAt(dynamic createdAt) {
      if (createdAt is Timestamp) {
        return createdAt.toDate();
      } else if (createdAt is String) {
        return DateTime.parse(createdAt);
      }
      return DateTime.now();
    }

    return ReviewModel(
      id: id,
      userId: map['userId'] ?? '',
      targetId: map['targetId'] ?? '',
      targetType: map['targetType'] ?? '',
      rating: (map['rating'] is double)
          ? map['rating']
          : (map['rating'] is int)
              ? (map['rating'] as int).toDouble()
              : 0.0,
      comment: map['comment'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      createdAt: parseCreatedAt(map['createdAt']),
      likeCount: map['likeCount'] ?? 0,
      reviewCount: map['reviewCount'] ?? 0,
      shipperId: map['shipperId'],
      deliveryRating: (map['deliveryRating'] ?? 0).toDouble(),
      deliveryComment: map['deliveryComment'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'targetId': targetId,
      'targetType': targetType,
      'rating': rating,
      'comment': comment,
      'images': images,
      'createdAt': Timestamp.fromDate(createdAt),
      'likeCount': likeCount,
      'reviewCount': reviewCount,
      'shipperId': shipperId,
      'deliveryRating': deliveryRating,
      'deliveryComment': deliveryComment,
    };
  }

  ReviewModel.empty()
      : this(
          id: '',
          userId: '',
          targetId: '',
          targetType: '',
          rating: 0.0,
          comment: '',
          images: [],
          createdAt: DateTime.now(),
          likeCount: 0,
          reviewCount: 0,
        );
}

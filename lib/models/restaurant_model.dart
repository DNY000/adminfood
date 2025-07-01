import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class RestaurantModel {
  final String id;
  final String name;
  final String description;
  final String address;
  final GeoPoint location;
  final Map<String, String> operatingHours;
  final double rating;
  final Map<String, dynamic> images;
  final String status;
  final double minOrderAmount;
  final DateTime createdAt;
  final List<String> categories;
  final Map<String, dynamic> metadata;
  final String token;
  RestaurantModel({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.location,
    required this.operatingHours,
    required this.rating,
    required this.images,
    required this.status,
    required this.minOrderAmount,
    required this.createdAt,
    required this.categories,
    required this.metadata,
    required this.token,
  });

  // Các getter tiện ích
  String get openTime => operatingHours['openTime'] ?? '08:00';
  String get closeTime => operatingHours['closeTime'] ?? '22:00';
  String get mainImage => images['main'] ?? '';
  List<String> get galleryImages => List<String>.from(images['gallery'] ?? []);
  bool get isVerified => metadata['isVerified'] ?? false;
  bool get isActive => metadata['isActive'] ?? true;
  DateTime? get lastUpdated =>
      (metadata['lastUpdated'] as Timestamp?)?.toDate();

  // Kiểm tra trạng thái mở cửa
  bool get isOpen {
    if (!isActive) return false;

    final now = DateTime.now();
    final formatter = DateFormat('HH:mm');
    final currentTime = formatter.format(now);
    return currentTime.compareTo(openTime) >= 0 &&
        currentTime.compareTo(closeTime) <= 0 &&
        status == 'open';
  }

  // Kiểm tra nhà hàng mới
  bool get isNew {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inDays <= 7;
  }

  String get formattedCreatedDate => DateFormat('dd/MM/yyyy').format(createdAt);

  factory RestaurantModel.fromMap(Map<String, dynamic> map, String id) {
    return RestaurantModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      address: map['address'] ?? '',
      location: map['location'] is GeoPoint
          ? map['location']
          : GeoPoint(
              (map['location']?['latitude'] ?? 0).toDouble(),
              (map['location']?['longitude'] ?? 0).toDouble(),
            ),
      operatingHours: Map<String, String>.from(map['operatingHours'] ??
          {
            'openTime': '08:00',
            'closeTime': '22:00',
          }),
      rating: (map['rating'] ?? 0.0).toDouble(),
      images: Map<String, dynamic>.from(map['images'] ??
          {
            'main': '',
            'gallery': [],
          }),
      status: map['status'] ?? 'closed',
      minOrderAmount: (map['minOrderAmount'] ?? 0.0).toDouble(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      categories: List<String>.from(map['categories'] ?? []),
      metadata: Map<String, dynamic>.from(map['metadata'] ??
          {
            'isActive': true,
            'isVerified': false,
            'lastUpdated': Timestamp.now(),
          }),
      token: map['token'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'location': location,
      'operatingHours': operatingHours,
      'rating': rating,
      'images': images,
      'status': status,
      'minOrderAmount': minOrderAmount,
      'createdAt': Timestamp.fromDate(createdAt),
      'categories': categories,
      'metadata': {
        ...metadata,
        'lastUpdated': Timestamp.now(),
      },
      'token': token,
    };
  }

  // Helper method cho danh sách
  Map<String, dynamic> toListView() {
    return {
      'id': id,
      'name': name,
      'mainImage': mainImage,
      'rating': rating,
      'isOpen': isOpen,
      'isNew': isNew,
      'isVerified': isVerified,
      'minOrderAmount': minOrderAmount,
      'categories': categories,
      'token': token,
    };
  }

  // Helper method cho chi tiết
  Map<String, dynamic> toDetailView() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'location': {
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
      'mainImage': mainImage,
      'galleryImages': galleryImages,
      'rating': rating,
      'openTime': openTime,
      'closeTime': closeTime,
      'isOpen': isOpen,
      'isVerified': isVerified,
      'minOrderAmount': minOrderAmount,
      'categories': categories,
      'token': token,
    };
  }

  // Tạo bản sao với các giá trị mới
  RestaurantModel copyWith({
    String? id,
    String? name,
    String? description,
    String? address,
    GeoPoint? location,
    Map<String, String>? operatingHours,
    double? rating,
    Map<String, dynamic>? images,
    String? status,
    double? minOrderAmount,
    DateTime? createdAt,
    List<String>? categories,
    Map<String, dynamic>? metadata,
    String? token,
  }) {
    return RestaurantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      location: location ?? this.location,
      operatingHours:
          operatingHours ?? Map<String, String>.from(this.operatingHours),
      rating: rating ?? this.rating,
      images: images ?? Map<String, dynamic>.from(this.images),
      status: status ?? this.status,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      createdAt: createdAt ?? this.createdAt,
      categories: categories ?? List<String>.from(this.categories),
      metadata: metadata ?? Map<String, dynamic>.from(this.metadata),
      token: token ?? this.token,
    );
  }
}

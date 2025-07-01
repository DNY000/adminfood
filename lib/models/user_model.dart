import 'package:admin/ultils/const/enum.dart';
import 'package:admin/ultils/fomatter/formatters.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';

class UserModel {
  final String id;

  final String name;
  final String gender;
  final String avatarUrl;
  final String profilePicture;

  // Thông tin liên hệ (contact)
  final String? email;
  final String phoneNumber;
  final List<AddressModel> addresses;

  // Tùy chọn người dùng (preferences)
  final List<String> favorites;
  final String token;

  // Thông tin bổ sung (metadata)
  final Role role;
  final DateTime createdAt;
  final DateTime dateOfBirth;
  final DateTime? lastUpdated;

  String get formatPhoneNumber => TFormatter.formatPhoneNumber(phoneNumber);

  AddressModel? get defaultAddress {
    try {
      return addresses.firstWhere((address) => address.isDefault == true);
    } catch (_) {
      return addresses.isNotEmpty ? addresses.first : null;
    }
  }

  UserModel({
    required this.id,
    this.name = '',
    this.gender = 'Nam',
    this.avatarUrl = '',
    this.profilePicture = '',
    this.email,
    this.phoneNumber = '',
    required this.addresses,
    this.favorites = const [],
    this.token = '',
    this.role = Role.user,
    DateTime? createdAt,
    DateTime? dateOfBirth,
    this.lastUpdated,
  })  : createdAt = createdAt ?? DateTime.now(),
        dateOfBirth = dateOfBirth ?? DateTime.now();

  static String generateUserName(String fullName) {
    if (fullName.isEmpty) return 'cwt_user';

    List<String> parts = fullName.split(' ');
    String firstName = parts[0].toLowerCase();
    String lastName = parts.length > 1 ? parts.last.toLowerCase() : '';

    String camelCaseUserName =
        lastName.isEmpty ? firstName : '\$firstName.\$lastName';
    return 'cwt_\$camelCaseUserName';
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    // Xử lý addresses
    List<AddressModel> addressList = [];
    if (map['addresses'] != null) {
      final addressesData = map['addresses'] as List;
      for (int i = 0; i < addressesData.length; i++) {
        addressList.add(
          AddressModel.fromMap(
            addressesData[i] as Map<String, dynamic>,
            '\${id}_address_\$i',
          ),
        );
      }
    }

    return UserModel(
      id: id,
      // Profile
      name: map['name'] ?? '',
      gender: map['gender'] ?? 'Nam',
      avatarUrl: map['avatarUrl'] ?? '',
      profilePicture: map['profilePicture'] ?? '',

      // Contact
      email: map['email'],
      phoneNumber: map['phoneNumber'] ?? '',
      addresses: addressList,

      // Preferences
      favorites: List<String>.from(map['favorites'] ?? []),
      token: map['token'] ?? '',

      // Metadata
      role: Role.values.firstWhere(
        (e) => e.name == (map['role'] ?? 'user'),
        orElse: () => Role.user,
      ),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dateOfBirth:
          (map['dateOfBirth'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastUpdated: (map['lastUpdated'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    // Chuyển addresses sang list Map
    final List<Map<String, dynamic>> addressesMap =
        addresses.map((address) => address.toMap()).toList();

    return {
      'name': name,
      'gender': gender,
      'avatarUrl': avatarUrl,
      'profilePicture': profilePicture,
      'email': email,
      'phoneNumber': phoneNumber,
      'addresses': addressesMap,
      'favorites': favorites,
      'token': token,
      'role': role.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'lastUpdated': Timestamp.now(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? gender,
    String? avatarUrl,
    String? profilePicture,
    String? email,
    String? phoneNumber,
    List<AddressModel>? addresses,
    List<String>? favorites,
    String? token,
    Role? role,
    DateTime? createdAt,
    DateTime? dateOfBirth,
    DateTime? lastUpdated,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      profilePicture: profilePicture ?? this.profilePicture,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      addresses: addresses ?? this.addresses,
      favorites: favorites ?? this.favorites,
      token: token ?? this.token,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class AddressModel {
  String street;

  Map<double, double>? location;
  bool isDefault;

  AddressModel({required this.street, this.location, this.isDefault = false});

  // Factory method to create an empty address
  factory AddressModel.empty() {
    return AddressModel(street: '', location: {}, isDefault: false);
  }

  factory AddressModel.fromMap(Map<String, dynamic> data, String id) {
    Map<double, double> locationMap = {};

    // Xử lý location nếu có
    if (data['location'] != null) {
      try {
        locationMap = Map<double, double>.from(data['location']);
      } catch (e) {
        // Trong trường hợp lỗi, giữ nguyên map rỗng
      }
    }

    return AddressModel(
      street: data['street'] ?? '',
      location: locationMap,
      isDefault: data['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'street': street,
      'location': location ?? {},
      'isDefault': isDefault,
    };
  }

  static Future<Map<double, double>?> getLocationFromAddress(
    String address,
  ) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations.first;
        return {location.latitude: location.longitude};
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get location from address: $e');
    }
  }

  Future<bool> updateLocationFromFullAddress() async {
    try {
      final newLocation = await AddressModel.getLocationFromAddress(street);
      if (newLocation != null) {
        location = newLocation;
        return true;
      }
    } catch (e) {
      throw Exception('Failed to update location: $e');
    }
    return false;
  }
}

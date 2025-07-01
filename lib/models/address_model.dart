class AddressModel {
  String id;
  String userId;
  String name; // Tên địa chỉ (ví dụ: Nhà, Công ty)
  String address;
  String district;
  String city;
  String phoneNumber;
  Map<String, double> location;
  String note;
  bool isDefault;

  AddressModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.address,
    required this.district,
    required this.city,
    required this.phoneNumber,
    required this.location,
    required this.note,
    this.isDefault = false,
  });

  factory AddressModel.fromMap(Map<String, dynamic> data, String id) {
    return AddressModel(
      id: id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      district: data['district'] ?? '',
      city: data['city'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      location: Map<String, double>.from(data['location'] ?? {}),
      note: data['note'] ?? '',
      isDefault: data['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'address': address,
      'district': district,
      'city': city,
      'phoneNumber': phoneNumber,
      'location': location,
      'note': note,
      'isDefault': isDefault,
    };
  }
}

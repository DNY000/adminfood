class CategoryModel {
  String id;
  String name;
  String image;
  bool isActive;

  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
    this.isActive = true,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> data, String id) {
    return CategoryModel(
      id: id,
      name: data['name'] ?? '',
      image: data['image'] ?? '',
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'image': image, 'isActive': isActive};
  }
}

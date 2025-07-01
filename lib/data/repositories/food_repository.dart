import 'package:admin/models/food_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FoodRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'foods';

  // Lưu món ăn mới hoặc cập nhật
  Future<void> saveFood(FoodModel food) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(food.id)
          .set(food.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Không thể lưu món ăn: $e');
    }
  }

  // Lấy danh sách món ăn với phân trang
  Future<List<FoodModel>> getFoods({
    int limit = 10,
    DocumentSnapshot? startAfter,
    bool? isAvailable,
  }) async {
    try {
      Query query = _firestore.collection(_collection);

      if (isAvailable != null) {
        query = query.where('isAvailable', isEqualTo: isAvailable);
      }

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      return snapshot.docs
          .map(
            (doc) => FoodModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Không thể lấy danh sách món ăn: $e');
    }
  }

  // Lấy món ăn theo category
  Future<List<FoodModel>> getFoodsByCategory(
    String category, {
    int limit = 10,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('category', isEqualTo: category)
          .where('isAvailable', isEqualTo: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => FoodModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Không thể lấy danh sách món ăn theo category: $e');
    }
  }

  // Lấy món ăn của nhà hàng
  Future<List<FoodModel>> getFoodsByRestaurant(String restaurantId) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('restaurantId', isEqualTo: restaurantId);

      final snapshot = await query.get();

      return snapshot.docs
          .map(
            (doc) => FoodModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Không thể lấy danh sách món ăn của nhà hàng: $e');
    }
  }

  // Lấy món ăn theo đánh giá
  Future<List<FoodModel>> getFoodsByRating({
    double minRating = 4.0,
    bool onlyAvailable = true,
    int limit = 10,
  }) async {
    try {
      // Chỉ query theo rating để tránh lỗi composite index
      Query query = _firestore
          .collection(_collection)
          .orderBy('rating', descending: true)
          .limit(50); // Lấy nhiều hơn để có thể lọc ở client

      final snapshot = await query.get();

      // Lọc dữ liệu ở phía client
      final foods = snapshot.docs
          .map(
            (doc) => FoodModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .where((food) => food.rating >= minRating)
          .where((food) => !onlyAvailable || food.isAvailable)
          .take(limit)
          .toList();

      return foods;
    } catch (e) {
      throw Exception('Không thể lấy danh sách món ăn theo rating: $e');
    }
  }

  // Lấy món ăn được đề xuất
  Future<List<FoodModel>> getRecommendedFoods({
    int limit = 5,
    double minRating = 4.0,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('isAvailable', isEqualTo: true)
          // .where('rating', isGreaterThanOrEqualTo: minRating)
          // .orderBy('rating', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => FoodModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Không thể lấy danh sách món ăn đề xuất: $e');
    }
  }

  // Tìm kiếm món ăn
  Future<List<FoodModel>> searchFoods(String query, {int limit = 20}) async {
    try {
      // Convert query to lowercase for case-insensitive search
      final lowercaseQuery = query.toLowerCase();

      // Get all foods first (we'll filter in memory for better search)
      final snapshot = await _firestore
          .collection(_collection)
          .where('isAvailable', isEqualTo: true)
          .get();

      // Filter foods based on name or description containing the query
      final foods = snapshot.docs
          .map((doc) =>
              FoodModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .where(
            (food) =>
                food.name.toLowerCase().contains(lowercaseQuery) ||
                food.description.toLowerCase().contains(lowercaseQuery),
          )
          .take(limit)
          .toList();

      return foods;
    } catch (e) {
      throw Exception('Không thể tìm kiếm món ăn: $e');
    }
  }

  // Lấy chi tiết món ăn
  Future<FoodModel> getFoodById(String foodId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('id', isEqualTo: foodId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Không tìm thấy món ăn với ID: $foodId');
      }

      final doc = querySnapshot.docs.first;
      return FoodModel.fromMap(doc.data(), doc.id);
    } catch (e) {
      throw Exception('Không thể lấy thông tin món ăn: $e');
    }
  }

  Future<void> addFood(FoodModel food) async {
    try {
      await _firestore.collection(_collection).doc().set(food.toMap());
    } catch (e) {
      throw "Fail $e";
    }
  }

  Future<void> updateFood(FoodModel food, String foodId) async {
    try {
      await _firestore.collection(_collection).doc(foodId).update(food.toMap());
    } catch (e) {
      throw "Fail $e";
    }
  }

  Future<void> deleteFood(String foodId) async {
    try {
      await _firestore.collection(_collection).doc(foodId).delete();
    } catch (e) {
      throw "Fail $e";
    }
  }

  // Lấy top món ăn bán chạy
  Future<List<FoodModel>> getTopSellingFoods({int limit = 6}) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('soldCount', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) =>
              FoodModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error getting top selling foods: $e');
      return [];
    }
  }
}

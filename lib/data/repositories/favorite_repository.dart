import 'package:admin/models/food_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<FoodModel>> getFavorites(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final favoriteIds = List<String>.from(userDoc.data()?['favorites'] ?? []);

      if (favoriteIds.isEmpty) return [];

      final foods = await _firestore
          .collection('foods')
          .where(FieldPath.documentId, whereIn: favoriteIds)
          .get();

      return foods.docs
          .map((doc) => FoodModel.fromMap(doc.data()!, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get favorites: $e');
    }
  }

  Future<void> addToFavorites(String userId, String foodId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'favorites': FieldValue.arrayUnion([foodId]),
      });
    } catch (e) {
      throw Exception('Failed to add to favorites: $e');
    }
  }

  Future<void> removeFromFavorites(String userId, String foodId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'favorites': FieldValue.arrayRemove([foodId]),
      });
    } catch (e) {
      throw Exception('Failed to remove from favorites: $e');
    }
  }

  Future<FoodModel?> getFoodById(String foodId) async {
    try {
      final doc = await _firestore.collection('foods').doc(foodId).get();
      if (doc.exists) {
        return FoodModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get food: $e');
    }
  }
}

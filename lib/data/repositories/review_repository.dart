import 'package:admin/models/review_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'reviews';

  Future<List<ReviewModel>> getReviewsByTarget(
    String targetId,
    String targetType,
  ) async {
    try {
      final snapshot =
          await _firestore
              .collection(_collection)
              .where('targetId', isEqualTo: targetId)
              .where('targetType', isEqualTo: targetType)
              .orderBy('createdAt', descending: true)
              .get();
      return snapshot.docs
          .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addReview(ReviewModel review) async {
    try {
      await _firestore.collection(_collection).add(review.toMap());
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> updateReview(String reviewId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_collection).doc(reviewId).update(data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      await _firestore.collection(_collection).doc(reviewId).delete();
    } catch (e) {
      throw Exception(e);
    }
  }
}

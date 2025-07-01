import 'package:admin/models/notification_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'notifications';

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return NotificationModel.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection(_collection).doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      throw Exception('Không thể đánh dấu đã đọc thông báo: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection(_collection).doc(notificationId).delete();
    } catch (e) {
      throw Exception('Không thể xóa thông báo: $e');
    }
  }

  Future<void> createNotification(NotificationModel notification) async {
    try {
      final docRef =
          await _firestore.collection(_collection).add(notification.toMap());
      await docRef.update({'id': docRef.id});
    } catch (e) {
      throw Exception('Không thể tạo thông báo: $e');
    }
  }
}

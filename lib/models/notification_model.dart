import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  String id;
  String userId;
  String title;
  String content;
  String type; // 'order', 'promotion', 'system'
  Map<String, dynamic> data;
  DateTime createdAt;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.type,
    required this.data,
    required this.createdAt,
    this.isRead = false,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> data, String id) {
    return NotificationModel(
      id: id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      type: data['type'] ?? 'system',
      data: Map<String, dynamic>.from(data['data'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'content': content,
      'type': type,
      'data': data,
      'createdAt': createdAt,
      'isRead': isRead,
    };
  }
}

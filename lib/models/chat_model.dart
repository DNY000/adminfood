import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  String id;
  String orderId;
  String customerId;
  String shipperId;
  String message;
  String senderId;
  DateTime timestamp;
  bool isRead;

  ChatModel({
    required this.id,
    required this.orderId,
    required this.customerId,
    required this.shipperId,
    required this.message,
    required this.senderId,
    required this.timestamp,
    this.isRead = false,
  });

  factory ChatModel.fromMap(Map<String, dynamic> data, String id) {
    return ChatModel(
      id: id,
      orderId: data['orderId'] ?? '',
      customerId: data['customerId'] ?? '',
      shipperId: data['shipperId'] ?? '',
      message: data['message'] ?? '',
      senderId: data['senderId'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'customerId': customerId,
      'shipperId': shipperId,
      'message': message,
      'senderId': senderId,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
    };
  }

  ChatModel.empty()
      : this(
          id: '',
          orderId: '',
          customerId: '',
          shipperId: '',
          message: '',
          senderId: '',
          timestamp: DateTime.now(),
          isRead: false,
        );
}

import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  String id;
  String orderId;
  double amount;
  String method;
  String status;
  String? transactionId;
  DateTime paymentTime;

  PaymentModel({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.method,
    required this.status,
    this.transactionId,
    required this.paymentTime,
  });

  factory PaymentModel.fromMap(Map<String, dynamic> data, String id) {
    return PaymentModel(
      id: id,
      orderId: data['orderId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      method: data['method'] ?? '',
      status: data['status'] ?? 'pending',
      transactionId: data['transactionId'],
      paymentTime: (data['paymentTime'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'amount': amount,
      'method': method,
      'status': status,
      'transactionId': transactionId,
      'paymentTime': paymentTime,
    };
  }
}

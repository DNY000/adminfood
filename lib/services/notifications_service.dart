import 'dart:io';
import 'package:admin/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationsService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Channel ID cho Android
  static const String _channelId = 'food_notifications';
  static const String _channelName = 'Thông báo Food';
  static const String _channelDescription = 'Thông báo về đơn hàng và cập nhật';

  // Khởi tạo notification (gọi trong main.dart)
  static Future<void> initialize(BuildContext context) async {
    // iOS: xin quyền
    if (Platform.isIOS) {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
      );
    }

    // Android: xin quyền (Android 13+)
    if (Platform.isAndroid) {
      await Permission.notification.request();

      // Khuyến nghị bật autostart cho Xiaomi, Redmi, OPPO, Vivo
      final bool isXiaomiOrRedmi = await _isXiaomiOrRedmi();
      if (isXiaomiOrRedmi) {
        // Hiển thị hướng dẫn cho user (tuỳ chọn)
        // _showXiaomiPermissionDialog(context);
      }
    }

    // Khởi tạo local notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iOSSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        // Xử lý khi bấm vào thông báo local
        _handleNotificationTap(details.payload);
      },
    );

    // Tạo channel cho Android
    await _createNotificationChannel();

    // Xử lý message khi app foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Xử lý khi bấm vào thông báo (app ở background)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // Xử lý thông báo khi app terminated
    final RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundMessage(initialMessage);
    }

    // Đăng ký token với server
    await refreshToken();
  }

  // Tạo Android Notification Channel
  static Future<void> _createNotificationChannel() async {
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
        enableVibration: true,
        enableLights: true,
        playSound: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  // Hiển thị local notification khi app ở foreground
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    // In thông tin message cho debug

    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null) {
      // Android notification
      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'Thông báo mới',
        icon: android?.smallIcon ?? '@mipmap/ic_launcher',
        color: Colors.orange,
        showWhen: true,
      );

      // iOS notification
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        platformDetails,
        payload: _getPayloadFromMessage(message),
      );
    }
  }

  // Lấy payload từ message
  static String _getPayloadFromMessage(RemoteMessage message) {
    // Parse data payload thành string JSON
    if (message.data.isNotEmpty) {
      return message.data.toString();
    }
    return '';
  }

  // Xử lý khi bấm vào thông báo (từ background)
  static void _handleBackgroundMessage(RemoteMessage message) {
    final String notificationType = message.data['type'] ?? '';

    switch (notificationType) {
      case 'new_order':
        // Navigator.pushNamed(context, '/order-details', arguments: targetId);
        break;
      case 'update_order':
        // Navigator.pushNamed(context, '/order-details', arguments: targetId);
        break;
      default:
        // Navigator.pushNamed(context, '/notifications');
        break;
    }
  }

  // Xử lý khi bấm vào thông báo từ local notification
  static void _handleNotificationTap(String? payload) {
    if (payload != null && payload.isNotEmpty) {
      // Điều hướng đến màn hình thông báo
      navigatorKey.currentState?.pushNamed('/notifications');
    }
  }

  // Lấy FCM token
  static Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  // Làm mới FCM token và đăng ký lại với server
  static Future<void> refreshToken() async {
    final String? token = await getToken();
    if (token != null) {
      print('FCM Token: $token');
      // await ApiService.registerToken(token);
    }
  }

  // Kiểm tra thiết bị có phải Xiaomi hoặc Redmi không
  static Future<bool> _isXiaomiOrRedmi() async {
    if (Platform.isAndroid) {
      final String manufacturer = Platform.operatingSystem.toLowerCase();
      return manufacturer.contains('xiaomi') ||
          manufacturer.contains('redmi') ||
          manufacturer.contains('poco');
    }
    return false;
  }

  // Hiển thị dialog hướng dẫn cài đặt cho thiết bị Xiaomi/Redmi
  static void _showXiaomiPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cài đặt thêm cho thiết bị Xiaomi/Redmi'),
        content: const Text(
          'Để nhận thông báo đầy đủ, vui lòng:\n\n'
          '1. Vào Cài đặt > Ứng dụng > Quản lý ứng dụng\n'
          '2. Tìm ứng dụng này\n'
          '3. Bật "Tự động khởi động" và "Chạy nền"\n'
          '4. Vào mục "Tiết kiệm pin" và chọn "Không giới hạn"',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }

  // Đăng ký đề tài nhận thông báo (topic)
  static Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  // Hủy đăng ký đề tài
  static Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  // Gửi thông báo local ngay lập tức
  static Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }
}

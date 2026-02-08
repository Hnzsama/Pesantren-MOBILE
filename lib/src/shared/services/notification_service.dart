import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'dart:async';
import 'package:pesantren_mobile/src/features/auth/services/auth_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  static NotificationService get instance => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final AuthService _authService = AuthService();

  final _payloadController = StreamController<String?>.broadcast();
  Stream<String?> get payloadStream => _payloadController.stream;

  Future<void> initialize() async {
    // Request permission (iOS/Android 13+)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }

    // Initialize Local Notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification click
        debugPrint('Notification clicked: ${response.payload}');
        _payloadController.add(response.payload);
      },
    );

    // Handle Background/Terminated Click
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('A new onMessageOpenedApp event was published!');
      _payloadController.add(jsonEncode(message.data));
    });

    // Handle Terminated State Initial Message
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('App launched from terminated state via notification');
      // Delay slightly to allow listeners to attach
      Future.delayed(const Duration(milliseconds: 500), () {
        _payloadController.add(jsonEncode(initialMessage.data));
      });
    }

    // Handle Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint(
          'Message also contained a notification: ${message.notification?.title}',
        );
        _showLocalNotification(message);
      }
    });

    // Handle device token refresh
    _fcm.onTokenRefresh.listen((newToken) {
      updateTokenOnBackend(newToken);
    });
  }

  Future<void> updateTokenOnBackend(String? token) async {
    if (token == null) return;

    final authToken = await _authService.getToken();
    if (authToken == null) {
      debugPrint('No auth token, skipping FCM token update');
      return;
    }

    final baseUrl = dotenv.env['APP_URL'] ?? 'http://localhost:8000/api';
    final url = Uri.parse('$baseUrl/user/update-fcm-token');

    try {
      debugPrint('Updating FCM token on backend: $token');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({'fcm_token': token}),
      );

      if (response.statusCode == 200) {
        debugPrint('FCM token updated successfully on backend');
      } else {
        debugPrint(
          'Failed to update FCM token on backend: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error updating FCM token on backend: $e');
    }
  }

  Future<String?> getToken() async {
    try {
      // Add timeout to avoid hanging indefinitely
      String? token = await _fcm.getToken().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('FCM Token retrieval timed out');
          return null;
        },
      );
      debugPrint('FCM Token: $token');
      return token;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      0,
      'Test Notification',
      'Ini adalah notifikasi percobaan dari aplikasi Sandigi.',
      details,
      payload: 'test_payload',
    );
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      details,
      payload: message.data.toString(),
    );
  }
}

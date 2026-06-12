import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

/// Top-level background message handler.
/// Must be a top-level function annotated with @pragma('vm:entry-point')
/// to prevent Dart from tree-shaking it away.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  _showLocalNotification(
    title: message.notification?.title ?? 'Notificação',
    body: message.notification?.body ?? 'Você tem uma nova notificação',
  );
}

final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

/// Shared local notification display logic, used by both
/// foreground and background handlers.
Future<void> _showLocalNotification({
  required String title,
  required String body,
}) async {
  const androidDetails = AndroidNotificationDetails(
    'baby_routine_channel',
    'Baby Routine',
    channelDescription: 'Notificações de rotina do bebê',
    importance: Importance.high,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
    icon: '@mipmap/ic_launcher',
  );

  const iosDetails = DarwinNotificationDetails(
    presentSound: true,
    presentBadge: true,
    presentAlert: true,
  );

  const details = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
  );

  await _localNotifications.show(
    DateTime.now().millisecondsSinceEpoch.remainder(100000),
    title,
    body,
    details,
  );
}

/// Callback type for handling notification taps.
typedef NotificationTapCallback = void Function(Map<String, dynamic>? data);

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  NotificationTapCallback? onNotificationTap;

  /// Initialize Firebase Cloud Messaging and local notifications.
  ///
  /// Call once after Firebase.initializeApp().
  Future<void> initialize({NotificationTapCallback? onTap}) async {
    onNotificationTap = onTap;

    // ── Local notifications setup ──
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // ── Firebase Messaging setup ──
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Request notification permissions (iOS requires explicit prompt)
    await _requestPermission();

    // Foreground message handler
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Handle notification tap when app is in background and opened via notification
    FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationOpenedApp);

    // Handle notification tap when app was terminated and launched from notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage.data);
    }
  }

  /// Retrieve the current FCM registration token.
  ///
  /// Returns null if token retrieval fails or permissions are not granted.
  Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      return token;
    } catch (e) {
      debugPrint('Failed to get FCM token: $e');
      return null;
    }
  }

  /// Request notification permissions from the user (required on iOS).
  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      criticalAlert: false,
      announcement: false,
      carPlay: false,
    );

    debugPrint(
      'FCM permission status: ${settings.authorizationStatus.name}',
    );
  }

  /// Called when a push notification arrives while app is in foreground.
  void _onForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message received: ${message.messageId}');
    _showLocalNotification(
      title: message.notification?.title ?? 'Notificação',
      body: message.notification?.body ?? 'Você tem uma nova notificação',
    );
  }

  /// Called when user taps a notification that opens the app from background.
  void _onNotificationOpenedApp(RemoteMessage message) {
    debugPrint('Notification opened app: ${message.messageId}');
    _handleNotificationTap(message.data);
  }

  /// Called when user taps a local notification while app is in foreground.
  void _onNotificationResponse(NotificationResponse response) {
    debugPrint('Local notification tapped: ${response.payload}');
    if (response.payload != null && response.payload!.isNotEmpty) {
      try {
        // payload is JSON string with notification data
        onNotificationTap?.call({'payload': response.payload});
      } catch (_) {}
    }
  }

  /// Dispatch notification tap to the configured callback.
  void _handleNotificationTap(Map<String, dynamic> data) {
    if (data.isNotEmpty) {
      onNotificationTap?.call(data);
    }
  }
}

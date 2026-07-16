import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmail/core/network/api_client_provider.dart';
import 'package:taskmail/core/constants/api_constants.dart';
import 'package:taskmail/firebase/firebase_bootstrap.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref);
});

class NotificationService {
  NotificationService(this._ref);

  final Ref _ref;
  FirebaseMessaging? _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'taskmail_high_importance',
    'Task Reminders',
    description: 'Notifications for email-derived tasks',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    if (kIsWeb) {
      debugPrint('Skipping notifications on web');
      return;
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
    }

    if (!isFirebaseReady) {
      debugPrint('Skipping FCM setup — Firebase not configured');
      return;
    }

    _messaging = FirebaseMessaging.instance;

    try {
      await _messaging!.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      FirebaseMessaging.onMessage.listen(_showForegroundNotification);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpened);

      final initialMessage = await _messaging!.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpened(initialMessage);
      }
    } catch (e) {
      debugPrint('FCM initialization failed: $e');
    }
  }

  Future<void> registerDeviceToken() async {
    if (!isFirebaseReady || _messaging == null) return;

    try {
      final token = await _messaging!.getToken();
      if (token == null) return;

      final client = _ref.read(apiClientProvider);
      await client.post<void>(
        ApiConstants.registerDevice,
        data: {
          'fcmToken': token,
          'platform': defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
        },
      );
    } catch (e) {
      debugPrint('Failed to register FCM token: $e');
    }
  }

  void _showForegroundNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: message.data['taskId'] as String?,
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    final taskId = response.payload;
    if (taskId != null && taskId.isNotEmpty) {
      // Navigation handled via router listener in app shell
    }
  }

  void _handleMessageOpened(RemoteMessage message) {
    final taskId = message.data['taskId'] as String?;
    debugPrint('Notification opened for task: $taskId');
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message: ${message.messageId}');
}

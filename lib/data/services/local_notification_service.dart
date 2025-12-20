import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../models/notification_payload.dart';
import 'notification_navigation_service.dart';

/// Service for handling local notifications display
///
/// Handles:
/// - Local notification initialization and configuration
/// - Displaying notifications when app is in foreground
/// - Notification tap handling with deep link navigation
class LocalNotificationsService extends GetxService {
  /// Main plugin instance for handling notifications
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  /// Android-specific initialization settings using app launcher icon
  final _androidInitializationSettings = const AndroidInitializationSettings(
    '@mipmap/ic_launcher',
  );

  /// iOS-specific initialization settings with permission requests
  final _iosInitializationSettings = const DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  /// Android notification channel configuration
  static const _androidChannel = AndroidNotificationChannel(
    'salon_one_high_importance',
    'Salon One Notifications',
    description: 'High importance notifications for Salon One appointments',
    importance: Importance.max,
  );

  /// Flag to track initialization status
  bool _isInitialized = false;

  /// Counter for generating unique notification IDs
  int _notificationIdCounter = 0;

  /// Initializes the local notifications plugin for Android and iOS
  Future<void> init() async {
    // Check if already initialized to prevent redundant setup
    if (_isInitialized) {
      return;
    }

    // Create plugin instance
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Combine platform-specific settings
    final initializationSettings = InitializationSettings(
      android: _androidInitializationSettings,
      iOS: _iosInitializationSettings,
    );

    // Initialize plugin with settings and callback for notification taps
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create Android notification channel
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChannel);

    // Mark initialization as complete
    _isInitialized = true;
    debugPrint('LocalNotificationsService initialized');
  }

  /// Handle notification tap callback - navigate to appointments
  void _onNotificationTap(NotificationResponse response) {
    debugPrint('Local notification tapped: ${response.payload}');

    // Parse payload from JSON string
    final payload = NotificationPayload.fromJsonString(response.payload);

    // Navigate using the navigation service
    try {
      final navigationService = Get.find<NotificationNavigationService>();
      navigationService.navigateFromNotification(payload);
    } catch (e) {
      debugPrint('Navigation service not found: $e');
    }
  }

  /// Show a local notification with the given title, body, and payload
  Future<void> showNotification(
    String? title,
    String? body,
    String? payload,
  ) async {
    // Android-specific notification details
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _androidChannel.id,
      _androidChannel.name,
      channelDescription: _androidChannel.description,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    // iOS-specific notification details
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    // Combine platform-specific details
    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Display the notification
    await _flutterLocalNotificationsPlugin.show(
      _notificationIdCounter++,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Get the Android notification channel ID (needed for FCM)
  static String get channelId => _androidChannel.id;
}

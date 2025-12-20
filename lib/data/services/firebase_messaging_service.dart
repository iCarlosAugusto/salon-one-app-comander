import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'local_notification_service.dart';

/// Background message handler - must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized for background isolate
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
  debugPrint('Background message received: ${message.data.toString()}');
}

/// Service for handling Firebase Cloud Messaging push notifications
///
/// Handles:
/// - FCM initialization and token management
/// - Foreground notification display via LocalNotificationsService
/// - Background and terminated state notifications
/// - Notification tap handling
class FirebaseMessagingService extends GetxService {
  /// Current FCM token (observable)
  final RxnString fcmToken = RxnString(null);

  /// Notification permission status
  final Rx<AuthorizationStatus> permissionStatus = Rx<AuthorizationStatus>(
    AuthorizationStatus.notDetermined,
  );

  /// Reference to local notifications service
  late LocalNotificationsService _localNotificationsService;

  /// Initialize Firebase Messaging and set up all message listeners
  Future<void> init() async {
    // Register handler for background messages (app terminated)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Get the LocalNotificationsService from GetX
    _localNotificationsService = Get.find<LocalNotificationsService>();

    // Handle FCM token
    await _handlePushNotificationsToken();

    // Request user permission for notifications
    await _requestPermission();

    // Listen for messages when the app is in foreground
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Listen for notification taps when the app is in background but not terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // Check for initial message that opened the app from terminated state
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _onMessageOpenedApp(initialMessage);
    }

    debugPrint('FirebaseMessagingService initialized');
  }

  /// Retrieves and manages the FCM token for push notifications
  Future<void> _handlePushNotificationsToken() async {
    try {
      // Get the FCM token for the device
      final token = await FirebaseMessaging.instance.getToken();
      fcmToken.value = token;
      debugPrint('FCM Token: $token');

      // TODO: Send token to your backend for server-side notifications
      // Example: await _sendTokenToServer(token);

      // Listen for token refresh events
      FirebaseMessaging.instance.onTokenRefresh
          .listen((newToken) {
            fcmToken.value = newToken;
            debugPrint('FCM Token refreshed: $newToken');
            // TODO: Send updated token to your backend
          })
          .onError((error) {
            debugPrint('Error refreshing FCM token: $error');
          });
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }
  }

  /// Requests notification permission from the user
  Future<void> _requestPermission() async {
    final result = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    permissionStatus.value = result.authorizationStatus;
    debugPrint('Notification permission: ${result.authorizationStatus}');
  }

  /// Handles messages received while the app is in the foreground
  void _onForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message received: ${message.data.toString()}');
    final notificationData = message.notification;
    if (notificationData != null) {
      // Display a local notification using the service
      _localNotificationsService.showNotification(
        notificationData.title,
        notificationData.body,
        message.data.toString(),
      );
    }
  }

  /// Handles notification taps when app is opened from background or terminated state
  void _onMessageOpenedApp(RemoteMessage message) {
    debugPrint('Notification opened app: ${message.data.toString()}');
    // TODO: Add navigation based on message data
    // Example: Navigate to appointment details if appointmentId is in data
    // final appointmentId = message.data['appointmentId'];
    // if (appointmentId != null) {
    //   Get.toNamed(Routes.appointmentDetails, arguments: {'id': appointmentId});
    // }
  }

  /// Get current FCM token for server registration
  Future<String?> getToken() async {
    if (fcmToken.value == null) {
      await _handlePushNotificationsToken();
    }
    return fcmToken.value;
  }

  /// Subscribe to a topic for targeted notifications
  Future<void> subscribeToTopic(String topic) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
    debugPrint('Subscribed to topic: $topic');
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
    debugPrint('Unsubscribed from topic: $topic');
  }
}

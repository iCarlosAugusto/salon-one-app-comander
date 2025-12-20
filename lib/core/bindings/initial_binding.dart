import 'package:get/get.dart';
import '../../data/services/api_client.dart';
import '../../data/services/session_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/salon_service.dart';
import '../../data/services/employee_service.dart';
import '../../data/services/service_service.dart';
import '../../data/services/appointment_service.dart';
import '../../data/services/local_notification_service.dart';
import '../../data/services/firebase_messaging_service.dart';
import '../../data/services/notification_navigation_service.dart';

/// Initial bindings for dependency injection
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Auth services - must be registered first for session management
    Get.put(SessionService(), permanent: true);
    Get.put(AuthService(), permanent: true);

    // API Client
    Get.put(ApiClient(), permanent: true);

    // Notification Services - for push notifications
    Get.put(LocalNotificationsService(), permanent: true);
    Get.put(FirebaseMessagingService(), permanent: true);
    Get.put(NotificationNavigationService(), permanent: true);

    // Domain Services
    Get.lazyPut(() => SalonService(), fenix: true);
    Get.lazyPut(() => EmployeeService(), fenix: true);
    Get.lazyPut(() => ServiceService(), fenix: true);
    Get.lazyPut(() => AppointmentService(), fenix: true);
  }
}

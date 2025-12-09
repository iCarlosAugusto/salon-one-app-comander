import 'package:get/get.dart';
import 'login_controller.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/session_service.dart';

/// Binding for LoginView dependencies
class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure auth services are available
    if (!Get.isRegistered<SessionService>()) {
      Get.put(SessionService(), permanent: true);
    }
    if (!Get.isRegistered<AuthService>()) {
      Get.put(AuthService(), permanent: true);
    }

    // Login controller
    Get.lazyPut<LoginController>(() => LoginController());
  }
}

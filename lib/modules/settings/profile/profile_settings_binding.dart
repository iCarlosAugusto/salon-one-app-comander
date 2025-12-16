import 'package:get/get.dart';
import 'profile_settings_controller.dart';

/// Binding for profile settings screen
class ProfileSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfileSettingsController());
  }
}

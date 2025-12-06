import 'package:get/get.dart';
import 'settings_controller.dart';

/// Binding for the settings module
class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SettingsController());
  }
}

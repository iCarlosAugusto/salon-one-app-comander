import 'package:get/get.dart';
import 'settings_list_controller.dart';

/// Binding for settings list screen
class SettingsListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SettingsListController());
  }
}

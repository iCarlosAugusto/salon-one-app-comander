import 'package:get/get.dart';
import 'dashboard_controller.dart';

/// Binding for the dashboard module
class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DashboardController());
  }
}

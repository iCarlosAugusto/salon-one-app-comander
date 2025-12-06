import 'package:get/get.dart';
import 'appointments_controller.dart';

/// Binding for the appointments module
class AppointmentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AppointmentsController());
  }
}

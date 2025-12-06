import 'package:get/get.dart';
import 'services_controller.dart';

/// Binding for the services module
class ServicesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ServicesController());
  }
}

import 'package:get/get.dart';
import 'service_selection_controller.dart';

/// Binding for service selection screen
class ServiceSelectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ServiceSelectionController());
  }
}

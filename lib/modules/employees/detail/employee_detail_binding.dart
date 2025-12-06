import 'package:get/get.dart';
import 'employee_detail_controller.dart';

/// Binding for employee detail screen
class EmployeeDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmployeeDetailController>(() => EmployeeDetailController());
  }
}

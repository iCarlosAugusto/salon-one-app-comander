import 'package:get/get.dart';
import 'employees_controller.dart';

/// Binding for the employees module
class EmployeesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => EmployeesController());
  }
}

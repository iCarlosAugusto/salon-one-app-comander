import 'package:get/get.dart';
import 'employees_list_controller.dart';

/// Binding for employees list screen
class EmployeesListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmployeesListController>(() => EmployeesListController());
  }
}

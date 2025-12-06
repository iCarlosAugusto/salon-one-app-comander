import 'package:get/get.dart';
import 'employee_form_controller.dart';

/// Binding for employee form screen
class EmployeeFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmployeeFormController>(() => EmployeeFormController());
  }
}

import 'package:get/get.dart';
import '../../../data/models/employee_model.dart';
import '../../../data/models/schedule_model.dart';
import '../../../data/models/service_model.dart';
import '../../../data/services/employee_service.dart';
import '../../../shared/routes/app_routes.dart';

/// Controller for employee detail screen
class EmployeeDetailController extends GetxController {
  final _employeeService = Get.find<EmployeeService>();

  // Route parameter
  String get employeeId => Get.parameters['id'] ?? '';

  // Loading states
  final isLoading = true.obs;
  final isDeleting = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Data
  final employee = Rxn<EmployeeModel>();
  final schedules = <ScheduleModel>[].obs;
  final services = <ServiceModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    if (employeeId.isNotEmpty) {
      loadEmployee();
    } else {
      hasError.value = true;
      errorMessage.value = 'Employee ID not provided';
      isLoading.value = false;
    }
  }

  /// Load employee details with schedules and services
  Future<void> loadEmployee() async {
    isLoading.value = true;
    hasError.value = false;

    try {
      final response = await _employeeService.getEmployeeById(employeeId);
      if (response.isSuccess && response.data != null) {
        employee.value = response.data!;
        await Future.wait([_loadSchedules(), _loadServices()]);
      } else {
        throw Exception(response.error ?? 'Failed to load employee');
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadSchedules() async {
    final response = await _employeeService.getEmployeeSchedules(employeeId);
    if (response.isSuccess && response.data != null) {
      schedules.value = response.data!;
    }
  }

  Future<void> _loadServices() async {
    final response = await _employeeService.getEmployeeServices(employeeId);
    if (response.isSuccess && response.data != null) {
      services.value = response.data!;
    }
  }

  /// Navigate to edit screen
  void navigateToEdit() {
    Get.toNamed(Routes.employeeEditPath(employeeId));
  }

  /// Delete employee
  Future<void> deleteEmployee() async {
    isDeleting.value = true;
    try {
      final response = await _employeeService.deleteEmployee(employeeId);
      if (response.isSuccess) {
        Get.snackbar(
          'Success',
          'Employee deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        goBack();
      } else {
        Get.snackbar(
          'Error',
          response.error ?? 'Failed to delete employee',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isDeleting.value = false;
    }
  }

  /// Go back to list
  void goBack() {
    Get.offNamed(Routes.employees);
  }

  /// Refresh data
  Future<void> refresh() => loadEmployee();
}

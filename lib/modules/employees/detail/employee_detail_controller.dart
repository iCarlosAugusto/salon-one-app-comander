import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/employee_model.dart';
import '../../../data/models/schedule_model.dart';
import '../../../data/models/service_model.dart';
import '../../../data/services/employee_service.dart';
import '../../../data/services/service_service.dart';
import '../../../shared/routes/app_routes.dart';

/// Controller for employee detail screen
class EmployeeDetailController extends GetxController {
  final _employeeService = Get.find<EmployeeService>();
  final _serviceService = Get.find<ServiceService>();

  // Route parameter
  String get employeeId => Get.parameters['id'] ?? '';
  String get salonId => AppConstants.defaultSalonId;

  // Loading states
  final isLoading = true.obs;
  final isDeleting = false.obs;
  final isSavingServices = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Data
  final employee = Rxn<EmployeeModel>();
  final schedules = <ScheduleModel>[].obs;
  final services = <ServiceModel>[].obs;

  // All available services for assignment
  final allServices = <ServiceModel>[].obs;
  final selectedServiceIds = <String>{}.obs;

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
        await Future.wait([
          _loadSchedules(),
          _loadServices(),
          _loadAllServices(),
        ]);
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
      // Update selected service IDs
      selectedServiceIds.assignAll(response.data!.map((s) => s.id).toSet());
    }
  }

  Future<void> _loadAllServices() async {
    final response = await _serviceService.getServices(salonId);
    if (response.isSuccess && response.data != null) {
      allServices.value = response.data!;
    }
  }

  /// Toggle service selection
  void toggleService(String serviceId) {
    if (selectedServiceIds.contains(serviceId)) {
      selectedServiceIds.remove(serviceId);
    } else {
      selectedServiceIds.add(serviceId);
    }
  }

  /// Save service assignments (add new, remove unselected)
  Future<bool> saveServiceAssignments() async {
    isSavingServices.value = true;
    try {
      // Get current service IDs
      final currentIds = services.map((s) => s.id).toSet();
      final selectedIds = selectedServiceIds.toSet();

      // Calculate what to add and remove
      final toAdd = selectedIds.difference(currentIds).toList();
      final toRemove = currentIds.difference(selectedIds).toList();

      bool success = true;

      // Add new services
      if (toAdd.isNotEmpty) {
        final addResponse = await _employeeService.assignServices(
          employeeId,
          toAdd,
        );
        if (!addResponse.isSuccess) {
          success = false;
          Get.snackbar(
            'Error',
            addResponse.error ?? 'Failed to add services',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }

      // Remove unselected services
      if (toRemove.isNotEmpty) {
        final removeResponse = await _employeeService.unassignServices(
          employeeId,
          toRemove,
        );
        if (!removeResponse.isSuccess) {
          success = false;
          Get.snackbar(
            'Error',
            removeResponse.error ?? 'Failed to remove services',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }

      if (success) {
        Get.snackbar(
          'Success',
          'Services updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      }

      // Reload services to reflect changes
      await _loadServices();
      return success;
    } finally {
      isSavingServices.value = false;
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
  @override
  Future<void> refresh() => loadEmployee();
}

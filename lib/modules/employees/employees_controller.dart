import 'package:get/get.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/employee_model.dart';
import '../../data/models/schedule_model.dart';
import '../../data/models/service_model.dart';
import '../../data/services/employee_service.dart';
import '../../data/services/service_service.dart';

/// Controller for employees management
class EmployeesController extends GetxController {
  final _employeeService = Get.find<EmployeeService>();
  final _serviceService = Get.find<ServiceService>();

  // Loading states
  final isLoading = true.obs;
  final isSaving = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Data
  final employees = <EmployeeModel>[].obs;
  final allServices = <ServiceModel>[].obs;

  // Selected employee for detail view
  final selectedEmployee = Rxn<EmployeeModel>();
  final employeeSchedules = <ScheduleModel>[].obs;
  final employeeServices = <ServiceModel>[].obs;

  // Filters
  final searchQuery = ''.obs;
  final showInactiveOnly = false.obs;

  // Form state
  final isFormMode = false.obs;
  final editingEmployee = Rxn<EmployeeModel>();

  String get salonId => AppConstants.defaultSalonId;

  // Filtered employees
  List<EmployeeModel> get filteredEmployees {
    var filtered = employees.toList();

    if (showInactiveOnly.value) {
      filtered = filtered.where((e) => !e.isActive).toList();
    }

    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((e) {
        return e.fullName.toLowerCase().contains(query) ||
            (e.email?.toLowerCase().contains(query) ?? false) ||
            (e.phone?.contains(query) ?? false);
      }).toList();
    }

    // Sort by name
    filtered.sort((a, b) => a.fullName.compareTo(b.fullName));

    return filtered;
  }

  // Stats
  int get activeCount => employees.where((e) => e.isActive).length;
  int get totalCount => employees.length;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  /// Load all data
  Future<void> loadData() async {
    isLoading.value = true;
    hasError.value = false;

    try {
      await Future.wait([_loadEmployees(), _loadAllServices()]);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadEmployees() async {
    final response = await _employeeService.getEmployees(salonId);
    if (response.isSuccess && response.data != null) {
      employees.value = response.data!;
    } else {
      throw Exception(response.error);
    }
  }

  Future<void> _loadAllServices() async {
    final response = await _serviceService.getServices(salonId);
    if (response.isSuccess && response.data != null) {
      allServices.value = response.data!;
    }
  }

  /// Select an employee to view details
  Future<void> selectEmployee(EmployeeModel employee) async {
    selectedEmployee.value = employee;
    await Future.wait([
      _loadEmployeeSchedules(employee.id),
      _loadEmployeeServices(employee.id),
    ]);
  }

  Future<void> _loadEmployeeSchedules(String employeeId) async {
    final response = await _employeeService.getEmployeeSchedules(employeeId);
    if (response.isSuccess && response.data != null) {
      employeeSchedules.value = response.data!;
    }
  }

  Future<void> _loadEmployeeServices(String employeeId) async {
    final response = await _employeeService.getEmployeeServices(employeeId);
    if (response.isSuccess && response.data != null) {
      employeeServices.value = response.data!;
    }
  }

  /// Clear selected employee
  void clearSelection() {
    selectedEmployee.value = null;
    employeeSchedules.clear();
    employeeServices.clear();
  }

  /// Create a new employee
  Future<bool> createEmployee(Map<String, dynamic> data) async {
    isSaving.value = true;
    try {
      data['salonId'] = salonId;
      final response = await _employeeService.createEmployee(data);
      if (response.isSuccess && response.data != null) {
        employees.add(response.data!);
        Get.snackbar(
          'Success',
          'Employee created successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          response.error ?? 'Failed to create employee',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } finally {
      isSaving.value = false;
    }
  }

  /// Update an existing employee
  Future<bool> updateEmployee(String id, Map<String, dynamic> data) async {
    isSaving.value = true;
    try {
      final response = await _employeeService.updateEmployee(id, data);
      if (response.isSuccess && response.data != null) {
        final index = employees.indexWhere((e) => e.id == id);
        if (index != -1) {
          employees[index] = response.data!;
        }
        if (selectedEmployee.value?.id == id) {
          selectedEmployee.value = response.data;
        }
        Get.snackbar(
          'Success',
          'Employee updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          response.error ?? 'Failed to update employee',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } finally {
      isSaving.value = false;
    }
  }

  /// Delete an employee
  Future<bool> deleteEmployee(String id) async {
    isSaving.value = true;
    try {
      final response = await _employeeService.deleteEmployee(id);
      if (response.isSuccess) {
        employees.removeWhere((e) => e.id == id);
        if (selectedEmployee.value?.id == id) {
          clearSelection();
        }
        Get.snackbar(
          'Success',
          'Employee deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          response.error ?? 'Failed to delete employee',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } finally {
      isSaving.value = false;
    }
  }

  /// Start editing an employee
  void editEmployee(EmployeeModel employee) {
    editingEmployee.value = employee;
    isFormMode.value = true;
  }

  /// Start creating a new employee
  void createNewEmployee() {
    editingEmployee.value = null;
    isFormMode.value = true;
  }

  /// Cancel form mode
  void cancelForm() {
    editingEmployee.value = null;
    isFormMode.value = false;
  }

  /// Refresh data
  Future<void> refresh() => loadData();
}

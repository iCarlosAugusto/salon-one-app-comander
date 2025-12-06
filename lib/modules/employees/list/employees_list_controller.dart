import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/employee_model.dart';
import '../../../data/services/employee_service.dart';
import '../../../shared/routes/app_routes.dart';

/// Controller for employees list screen
class EmployeesListController extends GetxController {
  final _employeeService = Get.find<EmployeeService>();

  // Loading states
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Data
  final employees = <EmployeeModel>[].obs;

  // Filters
  final searchQuery = ''.obs;
  final showInactiveOnly = false.obs;

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
    loadEmployees();
  }

  /// Load employees list
  Future<void> loadEmployees() async {
    isLoading.value = true;
    hasError.value = false;

    try {
      final response = await _employeeService.getEmployees(salonId);
      if (response.isSuccess && response.data != null) {
        employees.value = response.data!;
      } else {
        throw Exception(response.error);
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh employees list
  Future<void> refresh() => loadEmployees();

  /// Navigate to employee detail
  void navigateToDetail(String id) {
    Get.toNamed(Routes.employeeDetailPath(id));
  }

  /// Navigate to create new employee
  void navigateToCreate() {
    Get.toNamed(Routes.employeeCreate);
  }

  /// Clear search filter
  void clearSearch() {
    searchQuery.value = '';
  }
}

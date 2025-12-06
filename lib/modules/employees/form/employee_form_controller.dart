import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/employee_model.dart';
import '../../../data/services/employee_service.dart';
import '../../../shared/routes/app_routes.dart';

/// Controller for employee form screen (create and edit)
class EmployeeFormController extends GetxController {
  final _employeeService = Get.find<EmployeeService>();

  // Route parameter - determines mode
  String? get employeeId => Get.parameters['id'];
  bool get isEditMode => employeeId != null;

  String get salonId => AppConstants.defaultSalonId;

  // Loading states
  final isLoading = false.obs;
  final isSaving = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Data for edit mode
  final employee = Rxn<EmployeeModel>();

  @override
  void onInit() {
    super.onInit();
    if (isEditMode) {
      loadEmployee();
    }
  }

  /// Load employee for edit mode
  Future<void> loadEmployee() async {
    if (employeeId == null) return;

    isLoading.value = true;
    hasError.value = false;

    try {
      final response = await _employeeService.getEmployeeById(employeeId!);
      if (response.isSuccess && response.data != null) {
        employee.value = response.data!;
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

  /// Save employee (create or update)
  Future<void> saveEmployee(Map<String, dynamic> data) async {
    isSaving.value = true;
    try {
      if (isEditMode) {
        await _updateEmployee(data);
      } else {
        await _createEmployee(data);
      }
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> _createEmployee(Map<String, dynamic> data) async {
    data['salonId'] = salonId;
    final response = await _employeeService.createEmployee(data);
    if (response.isSuccess && response.data != null) {
      Get.snackbar(
        'Success',
        'Employee created successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      _goBackToList();
    } else {
      Get.snackbar(
        'Error',
        response.error ?? 'Failed to create employee',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _updateEmployee(Map<String, dynamic> data) async {
    final response = await _employeeService.updateEmployee(employeeId!, data);
    if (response.isSuccess && response.data != null) {
      Get.snackbar(
        'Success',
        'Employee updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      _goBackToDetail();
    } else {
      Get.snackbar(
        'Error',
        response.error ?? 'Failed to update employee',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Cancel and go back
  void cancel() {
    if (isEditMode) {
      _goBackToDetail();
    } else {
      _goBackToList();
    }
  }

  void _goBackToList() {
    Get.offNamed(Routes.employees);
  }

  void _goBackToDetail() {
    if (employeeId != null) {
      Get.offNamed(Routes.employeeDetailPath(employeeId!));
    } else {
      _goBackToList();
    }
  }
}

import 'package:get/get.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/appointment_model.dart';
import '../../data/models/employee_model.dart';
import '../../data/models/service_model.dart';
import '../../data/services/appointment_service.dart';
import '../../data/services/employee_service.dart';
import '../../data/services/service_service.dart';

/// Controller for appointments management
class AppointmentsController extends GetxController {
  final _appointmentService = Get.find<AppointmentService>();
  final _employeeService = Get.find<EmployeeService>();
  final _serviceService = Get.find<ServiceService>();

  // Loading states
  final isLoading = true.obs;
  final isSaving = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Data
  final appointments = <AppointmentModel>[].obs;
  final employees = <EmployeeModel>[].obs;
  final services = <ServiceModel>[].obs;

  // Filters
  final selectedDate = Rxn<DateTime>();
  final selectedEmployeeId = Rxn<String>();
  final selectedStatus = Rxn<AppointmentStatus>();
  final searchQuery = ''.obs;

  // View mode
  final viewMode = AppointmentViewMode.list.obs;

  String get salonId => AppConstants.defaultSalonId;

  // Filtered appointments
  List<AppointmentModel> get filteredAppointments {
    var filtered = appointments.toList();

    // Filter by date
    if (selectedDate.value != null) {
      final dateStr = Formatters.formatDateForApi(selectedDate.value!);
      filtered = filtered
          .where((apt) => apt.appointmentDate == dateStr)
          .toList();
    }

    // Filter by employee
    if (selectedEmployeeId.value != null) {
      filtered = filtered
          .where((apt) => apt.employeeId == selectedEmployeeId.value)
          .toList();
    }

    // Filter by status
    if (selectedStatus.value != null) {
      filtered = filtered
          .where((apt) => apt.status == selectedStatus.value)
          .toList();
    }

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((apt) {
        return apt.clientName.toLowerCase().contains(query) ||
            apt.clientPhone.contains(query) ||
            (apt.clientEmail?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Sort by date and time
    filtered.sort((a, b) {
      final dateCompare = a.appointmentDate.compareTo(b.appointmentDate);
      if (dateCompare != 0) return dateCompare;
      return a.startTime.compareTo(b.startTime);
    });

    return filtered;
  }

  // Stats for header
  int get todayCount {
    final today = Formatters.formatDateForApi(DateTime.now());
    return appointments.where((apt) => apt.appointmentDate == today).length;
  }

  int get pendingCount {
    return appointments
        .where(
          (apt) =>
              apt.status == AppointmentStatus.pending ||
              apt.status == AppointmentStatus.confirmed,
        )
        .length;
  }

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
      await Future.wait([
        _loadAppointments(),
        _loadEmployees(),
        _loadServices(),
      ]);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadAppointments() async {
    final response = await _appointmentService.getAppointments(
      salonId: salonId,
    );
    if (response.isSuccess && response.data != null) {
      appointments.value = response.data!;
    } else if (!response.isSuccess) {
      throw Exception(response.error);
    }
  }

  Future<void> _loadEmployees() async {
    final response = await _employeeService.getEmployees(salonId);
    if (response.isSuccess && response.data != null) {
      employees.value = response.data!;
    }
  }

  Future<void> _loadServices() async {
    final response = await _serviceService.getServices(salonId);
    if (response.isSuccess && response.data != null) {
      services.value = response.data!;
    }
  }

  /// Get employee name by ID
  String getEmployeeName(String? employeeId) {
    if (employeeId == null) return 'Unassigned';
    final employee = employees.firstWhereOrNull((e) => e.id == employeeId);
    return employee?.fullName ?? 'Unknown';
  }

  /// Update appointment status
  Future<bool> updateStatus(
    String appointmentId,
    AppointmentStatus status,
  ) async {
    isSaving.value = true;
    try {
      final response = await _appointmentService.updateAppointmentStatus(
        appointmentId,
        status,
      );
      if (response.isSuccess) {
        // Update local list
        final index = appointments.indexWhere((apt) => apt.id == appointmentId);
        if (index != -1) {
          appointments[index] = appointments[index].copyWith(status: status);
        }
        Get.snackbar(
          'Success',
          'Appointment status updated',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          response.error ?? 'Failed to update status',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } finally {
      isSaving.value = false;
    }
  }

  /// Cancel an appointment
  Future<bool> cancelAppointment(String appointmentId, {String? reason}) async {
    isSaving.value = true;
    try {
      final response = await _appointmentService.cancelAppointment(
        appointmentId,
        reason: reason,
      );
      if (response.isSuccess) {
        // Update local list
        final index = appointments.indexWhere((apt) => apt.id == appointmentId);
        if (index != -1) {
          appointments[index] = appointments[index].copyWith(
            status: AppointmentStatus.cancelled,
            cancellationReason: reason,
          );
        }
        Get.snackbar(
          'Success',
          'Appointment cancelled',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          response.error ?? 'Failed to cancel appointment',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } finally {
      isSaving.value = false;
    }
  }

  /// Clear all filters
  void clearFilters() {
    selectedDate.value = null;
    selectedEmployeeId.value = null;
    selectedStatus.value = null;
    searchQuery.value = '';
  }

  /// Toggle view mode
  void toggleViewMode() {
    viewMode.value = viewMode.value == AppointmentViewMode.list
        ? AppointmentViewMode.calendar
        : AppointmentViewMode.list;
  }

  /// Refresh data
  Future<void> refresh() => loadData();
}

enum AppointmentViewMode { list, calendar }

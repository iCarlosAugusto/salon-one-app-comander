import 'package:flutter/foundation.dart';
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

  final selectedEmployeeId = Rxn<String>();
  final selectedStatus = Rxn<AppointmentStatus>();

  // View mode
  final viewMode = AppointmentViewMode.list.obs;

  // Calendar mode
  final calendarDate = DateTime.now().obs;

  String get salonId => AppConstants.defaultSalonId;

  // Filtered appointments
  List<AppointmentModel> get filteredAppointments {
    var filtered = appointments.toList();

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

    // Listen for calendar date changes and fetch appointments
    ever(calendarDate, (_) {
      if (viewMode.value == AppointmentViewMode.calendar) {
        _loadAppointmentsForDate(calendarDate.value);
      }
    });
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
    appointments.value = [];
    final response = await _appointmentService.getAppointments();
    if (response.isSuccess && response.data != null) {
      appointments.value = response.data!;
    } else if (!response.isSuccess) {
      throw Exception(response.error);
    }
  }

  /// Load appointments for a specific date (calendar mode)
  Future<void> _loadAppointmentsForDate(DateTime date) async {
    final dateStr = Formatters.formatDateForApi(date);
    isLoading.value = true;
    appointments.value = [];
    try {
      final response = await _appointmentService.getAppointments(date: dateStr);
      if (response.isSuccess && response.data != null) {
        appointments.value = response.data!;
      }
    } catch (e) {
      // Silently fail for background fetches
      debugPrint('Failed to load appointments for date: $e');
    } finally {
      isLoading.value = false;
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
    selectedEmployeeId.value = null;
    selectedStatus.value = null;
  }

  /// Toggle view mode
  void toggleViewMode() {
    viewMode.value = viewMode.value == AppointmentViewMode.list
        ? AppointmentViewMode.calendar
        : AppointmentViewMode.list;

    // Fetch appointments for current calendar date when switching to calendar mode
    if (viewMode.value == AppointmentViewMode.calendar) {
      _loadAppointmentsForDate(calendarDate.value);
    }
  }

  /// Get appointments for the current calendar date
  List<AppointmentModel> get appointmentsForCalendarDate {
    final dateStr = Formatters.formatDateForApi(calendarDate.value);
    var filtered = appointments
        .where((apt) => apt.appointmentDate == dateStr)
        .toList();

    // Apply employee filter if selected
    if (selectedEmployeeId.value != null) {
      filtered = filtered
          .where((apt) => apt.employeeId == selectedEmployeeId.value)
          .toList();
    }

    // Sort by start time
    filtered.sort((a, b) => a.startTime.compareTo(b.startTime));
    return filtered;
  }

  /// Navigate to today
  void goToToday() {
    calendarDate.value = DateTime.now();
  }

  /// Navigate to next day
  void goToNextDay() {
    calendarDate.value = calendarDate.value.add(const Duration(days: 1));
  }

  /// Navigate to previous day
  void goToPreviousDay() {
    calendarDate.value = calendarDate.value.subtract(const Duration(days: 1));
  }

  /// Set calendar date
  void setCalendarDate(DateTime date) {
    calendarDate.value = date;
  }

  /// Refresh data
  Future<void> refresh() => loadData();
}

enum AppointmentViewMode { list, calendar }

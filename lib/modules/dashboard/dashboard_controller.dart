import 'package:get/get.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/appointment_model.dart';
import '../../data/models/employee_model.dart';
import '../../data/models/service_model.dart';
import '../../data/services/appointment_service.dart';
import '../../data/services/employee_service.dart';
import '../../data/services/service_service.dart';
import '../../data/services/salon_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/models/salon_model.dart';
import '../../shared/routes/app_routes.dart';

/// Controller for the dashboard view
class DashboardController extends GetxController {
  final _salonService = Get.find<SalonService>();
  final _appointmentService = Get.find<AppointmentService>();
  final _employeeService = Get.find<EmployeeService>();
  final _serviceService = Get.find<ServiceService>();

  // Loading states
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Data
  final salon = Rxn<SalonModel>();
  final todayAppointments = <AppointmentModel>[].obs;
  final upcomingAppointments = <AppointmentModel>[].obs;
  final employees = <EmployeeModel>[].obs;
  final services = <ServiceModel>[].obs;

  // Stats
  final totalAppointmentsToday = 0.obs;
  final totalRevenue = 0.0.obs;
  final activeEmployees = 0.obs;
  final activeServices = 0.obs;
  final pendingAppointments = 0.obs;
  final completedToday = 0.obs;

  String get salonId => AppConstants.defaultSalonId;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  /// Load all dashboard data
  Future<void> loadDashboardData() async {
    isLoading.value = true;
    hasError.value = false;

    try {
      await Future.wait([
        _loadSalon(),
        _loadTodayAppointments(),
        _loadEmployees(),
        _loadServices(),
      ]);

      _calculateStats();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadSalon() async {
    final response = await _salonService.getSalonById(salonId);
    if (response.isSuccess && response.data != null) {
      salon.value = response.data;
    }
  }

  Future<void> _loadTodayAppointments() async {
    final today = DateTime.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final response = await _appointmentService.getAppointments(
      salonId: salonId,
      date: dateStr,
    );

    if (response.isSuccess && response.data != null) {
      todayAppointments.value = response.data!;
    }

    // Also load upcoming appointments (next 7 days)
    final allResponse = await _appointmentService.getAppointments(
      salonId: salonId,
    );
    if (allResponse.isSuccess && allResponse.data != null) {
      final now = DateTime.now();
      final weekFromNow = now.add(const Duration(days: 7));

      upcomingAppointments.value = allResponse.data!
          .where((apt) {
            final aptDate = DateTime.parse(apt.appointmentDate);
            return aptDate.isAfter(now) && aptDate.isBefore(weekFromNow);
          })
          .take(5)
          .toList();
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

  void _calculateStats() {
    // Today's stats
    totalAppointmentsToday.value = todayAppointments.length;

    completedToday.value = todayAppointments
        .where((apt) => apt.status == AppointmentStatus.completed)
        .length;

    pendingAppointments.value = todayAppointments
        .where(
          (apt) =>
              apt.status == AppointmentStatus.pending ||
              apt.status == AppointmentStatus.confirmed,
        )
        .length;

    // Calculate today's revenue from completed appointments
    totalRevenue.value = todayAppointments
        .where((apt) => apt.status == AppointmentStatus.completed)
        .fold(0.0, (sum, apt) => sum + apt.totalPrice);

    // Active counts
    activeEmployees.value = employees.where((e) => e.isActive).length;
    activeServices.value = services.where((s) => s.isActive).length;
  }

  /// Refresh dashboard data
  Future<void> refresh() => loadDashboardData();

  /// Sign out the current user
  Future<void> logout() async {
    try {
      await Get.find<AuthService>().signOut();
      Get.offAllNamed(Routes.login);
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign out: $e');
    }
  }
}

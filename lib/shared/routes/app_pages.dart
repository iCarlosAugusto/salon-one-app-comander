import 'package:get/get.dart';
import 'app_routes.dart';
import '../../modules/dashboard/dashboard_view.dart';
import '../../modules/dashboard/dashboard_binding.dart';
import '../../modules/appointments/appointments_view.dart';
import '../../modules/appointments/appointments_binding.dart';
import '../../modules/services/services_view.dart';
import '../../modules/services/services_binding.dart';
import '../../modules/employees/employees_view.dart';
import '../../modules/employees/employees_binding.dart';
import '../../modules/settings/settings_view.dart';
import '../../modules/settings/settings_binding.dart';

/// App pages configuration for GetX routing
class AppPages {
  AppPages._();

  static const initial = Routes.dashboard;

  static final routes = [
    // Dashboard
    GetPage(
      name: Routes.home,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: Routes.dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),

    // Appointments
    GetPage(
      name: Routes.appointments,
      page: () => const AppointmentsView(),
      binding: AppointmentsBinding(),
    ),
    GetPage(
      name: Routes.appointmentForm,
      page: () => const AppointmentsView(),
      binding: AppointmentsBinding(),
    ),

    // Services
    GetPage(
      name: Routes.services,
      page: () => const ServicesView(),
      binding: ServicesBinding(),
    ),
    GetPage(
      name: Routes.serviceForm,
      page: () => const ServicesView(),
      binding: ServicesBinding(),
    ),

    // Employees
    GetPage(
      name: Routes.employees,
      page: () => const EmployeesView(),
      binding: EmployeesBinding(),
    ),
    GetPage(
      name: Routes.employeeForm,
      page: () => const EmployeesView(),
      binding: EmployeesBinding(),
    ),

    // Settings
    GetPage(
      name: Routes.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: Routes.salonProfile,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: Routes.bookingSettings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
  ];
}

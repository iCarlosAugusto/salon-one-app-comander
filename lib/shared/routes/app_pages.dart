import 'package:get/get.dart';
import 'package:salon_one_comander/modules/appointments/pages/appoitmentForm/appoitment_binding.dart';
import 'package:salon_one_comander/modules/appointments/pages/appoitmentForm/appoitment_form_view.dart';
import 'package:salon_one_comander/modules/appointments/pages/serviceSelection/service_selection_view.dart';
import 'package:salon_one_comander/modules/appointments/pages/serviceSelection/service_selection_binding.dart';
import 'package:salon_one_comander/modules/settings/settings_list/settings_list.dart';
import 'package:salon_one_comander/modules/settings/settings_list/settings_list_binding.dart';
import 'package:salon_one_comander/modules/settings/profile/profile_settings_view.dart';
import 'package:salon_one_comander/modules/settings/profile/profile_settings_binding.dart';
import 'app_routes.dart';
import '../middlewares/auth_middleware.dart';
import '../../modules/auth/login/login_view.dart';
import '../../modules/auth/login/login_binding.dart';
import '../../modules/dashboard/dashboard_view.dart';
import '../../modules/dashboard/dashboard_binding.dart';
import '../../modules/appointments/appointments_view.dart';
import '../../modules/appointments/appointments_binding.dart';
import '../../modules/services/services_view.dart';
import '../../modules/services/services_binding.dart';
import '../../modules/employees/list/employees_list_view.dart';
import '../../modules/employees/list/employees_list_binding.dart';
import '../../modules/employees/detail/employee_detail_view.dart';
import '../../modules/employees/detail/employee_detail_binding.dart';
import '../../modules/employees/form/employee_form_view.dart';
import '../../modules/employees/form/employee_form_binding.dart';
import '../../modules/settings/settings_view.dart';
import '../../modules/settings/settings_binding.dart';

/// App pages configuration for GetX routing
class AppPages {
  AppPages._();

  static const initial = Routes.login;

  static final routes = [
    // Auth (guest only)
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
      middlewares: [GuestMiddleware()],
    ),

    // Dashboard (protected)
    GetPage(
      name: Routes.home,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
      middlewares: [AuthMiddleware()],
    ),

    // Appointments
    GetPage(
      name: Routes.appointments,
      page: () => const AppointmentsView(),
      binding: AppointmentsBinding(),
    ),
    GetPage(
      name: Routes.appointmentForm,
      page: () => const AppoitmentFormView(),
      binding: AppoitmentFormBinding(),
    ),
    GetPage(
      name: Routes.serviceSelection,
      page: () => const ServiceSelectionView(),
      binding: ServiceSelectionBinding(),
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

    // Employees - Refactored with separate screens
    GetPage(
      name: Routes.employees,
      page: () => const EmployeesListView(),
      binding: EmployeesListBinding(),
    ),
    GetPage(
      name: Routes.employeeDetail,
      page: () => const EmployeeDetailView(),
      binding: EmployeeDetailBinding(),
    ),
    GetPage(
      name: Routes.employeeCreate,
      page: () => const EmployeeFormView(),
      binding: EmployeeFormBinding(),
    ),
    GetPage(
      name: Routes.employeeEdit,
      page: () => const EmployeeFormView(),
      binding: EmployeeFormBinding(),
    ),

    // Settings
    GetPage(
      name: Routes.settings,
      page: () => const SettingsList(),
      binding: SettingsListBinding(),
    ),
    GetPage(
      name: Routes.profileSettings,
      page: () => const ProfileSettingsView(),
      binding: ProfileSettingsBinding(),
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

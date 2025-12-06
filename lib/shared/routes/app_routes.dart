/// Route names for navigation
abstract class Routes {
  Routes._();

  // Main routes
  static const home = '/';
  static const dashboard = '/dashboard';

  // Appointments
  static const appointments = '/appointments';
  static const appointmentDetail = '/appointments/:id';
  static const appointmentForm = '/appointments/form';
  static const appointmentEdit = '/appointments/:id/edit';

  // Services
  static const services = '/services';
  static const serviceForm = '/services/form';
  static const serviceEdit = '/services/:id/edit';

  // Employees
  static const employees = '/employees';
  static const employeeDetail = '/employees/:id';
  static const employeeCreate = '/employees/create';
  static const employeeEdit = '/employees/:id/edit';
  static const employeeSchedule = '/employees/:id/schedule';

  // Settings
  static const settings = '/settings';
  static const salonProfile = '/settings/profile';
  static const bookingSettings = '/settings/booking';

  // Helper methods for dynamic routes
  static String employeeDetailPath(String id) => '/employees/$id';
  static String employeeEditPath(String id) => '/employees/$id/edit';
  static String appointmentDetailPath(String id) => '/appointments/$id';
  static String appointmentEditPath(String id) => '/appointments/$id/edit';
  static String serviceEditPath(String id) => '/services/$id/edit';
}

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
  static const employeeForm = '/employees/form';
  static const employeeEdit = '/employees/:id/edit';
  static const employeeSchedule = '/employees/:id/schedule';

  // Settings
  static const settings = '/settings';
  static const salonProfile = '/settings/profile';
  static const bookingSettings = '/settings/booking';
}

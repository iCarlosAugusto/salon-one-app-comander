/// API endpoint constants
class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - Configure this based on your environment
  // TODO: Replace with your actual API base URL
  static const String baseUrl = 'http://localhost:3001';

  // Auth endpoints
  static const String authMe = '/auth/me';

  // Salon endpoints
  static const String salons = '/salons';
  static String salonById(String id) => '/salons/$id';
  static String salonBySlug(String slug) => '/salons/slug/$slug';

  // Employee endpoints
  static const String employees = '/employees';
  static String employeeById(String id) => '/employees/$id';
  static String employeesBySalon(String salonId) =>
      '/employees?salonId=$salonId';
  static String employeeServices(String employeeId) =>
      '/employees/$employeeId/services';
  static String employeeSchedules(String employeeId) =>
      '/employees/$employeeId/schedules';

  // Service endpoints
  static const String services = '/services';
  static String serviceById(String id) => '/services/$id';
  static String servicesBySalon(String salonId) => '/services?salonId=$salonId';
  static String activeServicesBySalon(String salonId) =>
      '/salons/$salonId/services/active';

  // Appointment endpoints
  static const String appointments = '/appointments';
  static String appointmentById(String id) => '/appointments/$id';
  static String appointmentsBySalon(String salonId) =>
      '/appointments?salonId=$salonId';
  static String appointmentStatus(String id) => '/appointments/$id/status';
  static String cancelAppointment(String id) => '/appointments/$id/cancel';

  // Availability endpoints
  static String availableSlots({
    required String employeeIds,
    required String serviceIds,
    required String date,
  }) =>
      '/availability/slots?employeeIds=$employeeIds&serviceIds=$serviceIds&date=$date';

  static String checkAvailability({
    required String employeeId,
    required String serviceId,
    required String date,
    required String time,
  }) =>
      '/availability/check?employeeId=$employeeId&serviceId=$serviceId&date=$date&time=$time';
}

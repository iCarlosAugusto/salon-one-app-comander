/// Data Transfer Object for creating an appointment
///
/// This class encapsulates all the required and optional data needed
/// to create a new appointment through the API.
class CreateAppointmentDto {
  /// The salon ID where the appointment will be created
  final String salonId;

  /// List of services with their associated employee IDs
  final List<AppointmentServiceItem> services;

  /// The date of the appointment in YYYY-MM-DD format
  final String appointmentDate;

  /// The start time in HH:MM format (24-hour)
  final String startTime;

  /// The name of the client
  final String clientName;

  /// The phone number of the client
  final String clientPhone;

  /// Optional email of the client
  final String? clientEmail;

  /// Optional notes for the appointment
  final String? notes;

  CreateAppointmentDto({
    required this.salonId,
    required this.services,
    required this.appointmentDate,
    required this.startTime,
    required this.clientName,
    required this.clientPhone,
    this.clientEmail,
    this.notes,
  });

  /// Converts the DTO to a Map for API requests
  Map<String, dynamic> toJson() {
    return {
      'salonId': salonId,
      'services': services.map((s) => s.toJson()).toList(),
      'appointmentDate': appointmentDate,
      'startTime': startTime,
      'clientName': clientName,
      'clientPhone': clientPhone,
      if (clientEmail != null) 'clientEmail': clientEmail,
      if (notes != null) 'notes': notes,
    };
  }

  @override
  String toString() {
    return 'CreateAppointmentDto('
        'salonId: $salonId, '
        'services: $services, '
        'appointmentDate: $appointmentDate, '
        'startTime: $startTime, '
        'clientName: $clientName, '
        'clientPhone: $clientPhone, '
        'clientEmail: $clientEmail, '
        'notes: $notes)';
  }
}

/// Represents a service item in an appointment with its assigned employee
class AppointmentServiceItem {
  /// The service ID
  final String serviceId;

  /// The employee ID who will perform the service
  final String employeeId;

  AppointmentServiceItem({required this.serviceId, required this.employeeId});

  Map<String, dynamic> toJson() {
    return {'serviceId': serviceId, 'employeeId': employeeId};
  }

  @override
  String toString() {
    return 'AppointmentServiceItem(serviceId: $serviceId, employeeId: $employeeId)';
  }
}

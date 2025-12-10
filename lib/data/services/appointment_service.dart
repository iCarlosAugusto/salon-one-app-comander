import 'package:get/get.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/appointment_model.dart';
import 'api_client.dart';

/// Service for appointment-related API operations
class AppointmentService extends GetxService {
  final ApiClient _client = Get.find<ApiClient>();

  /// Get all appointments for a salon
  Future<ApiResponse<List<AppointmentModel>>> getAppointments({
    String? employeeId,
    String? date,
  }) async {
    var endpoint = ApiEndpoints.appointments;

    final queryParams = <String>[];
    if (employeeId != null) {
      queryParams.add('employeeIds=$employeeId');
    }
    if (date != null) {
      queryParams.add('date=$date');
    }
    if (queryParams.isNotEmpty) {
      endpoint += '?${queryParams.join('&')}';
    }

    return _client.getRequest<List<AppointmentModel>>(
      endpoint,
      decoder: (data) {
        if (data is List) {
          return data
              .map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );
  }

  /// Get appointment by ID
  Future<ApiResponse<AppointmentModel>> getAppointmentById(String id) async {
    return _client.getRequest<AppointmentModel>(
      ApiEndpoints.appointmentById(id),
      decoder: (data) =>
          AppointmentModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Create appointment
  Future<ApiResponse<AppointmentModel>> createAppointment(
    Map<String, dynamic> data,
  ) async {
    return _client.postRequest<AppointmentModel>(
      ApiEndpoints.appointments,
      body: data,
      decoder: (data) =>
          AppointmentModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Update appointment
  Future<ApiResponse<AppointmentModel>> updateAppointment(
    String id,
    Map<String, dynamic> data,
  ) async {
    return _client.putRequest<AppointmentModel>(
      ApiEndpoints.appointmentById(id),
      body: data,
      decoder: (data) =>
          AppointmentModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Update appointment status
  Future<ApiResponse<AppointmentModel>> updateAppointmentStatus(
    String id,
    AppointmentStatus status,
  ) async {
    return _client.patchRequest<AppointmentModel>(
      ApiEndpoints.appointmentStatus(id),
      body: {'status': status.value},
      decoder: (data) =>
          AppointmentModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Cancel appointment
  Future<ApiResponse<AppointmentModel>> cancelAppointment(
    String id, {
    String? reason,
  }) async {
    return _client.postRequest<AppointmentModel>(
      ApiEndpoints.cancelAppointment(id),
      body: reason != null ? {'reason': reason} : null,
      decoder: (data) =>
          AppointmentModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Get available time slots
  Future<ApiResponse<List<Map<String, dynamic>>>> getAvailableSlots({
    required String employeeIds,
    required String serviceIds,
    required String date,
  }) async {
    return _client.getRequest<List<Map<String, dynamic>>>(
      ApiEndpoints.availableSlots(
        employeeIds: employeeIds,
        serviceIds: serviceIds,
        date: date,
      ),
      decoder: (data) {
        if (data is List) {
          return data.map((e) => e as Map<String, dynamic>).toList();
        }
        return [];
      },
    );
  }

  /// Check availability for a specific slot
  Future<ApiResponse<Map<String, dynamic>>> checkAvailability({
    required String employeeId,
    required String serviceId,
    required String date,
    required String time,
  }) async {
    return _client.getRequest<Map<String, dynamic>>(
      ApiEndpoints.checkAvailability(
        employeeId: employeeId,
        serviceId: serviceId,
        date: date,
        time: time,
      ),
      decoder: (data) => data as Map<String, dynamic>,
    );
  }
}

import 'package:get/get.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/employee_model.dart';
import '../models/schedule_model.dart';
import '../models/service_model.dart';
import 'api_client.dart';

/// Service for employee-related API operations
class EmployeeService extends GetxService {
  final ApiClient _client = Get.find<ApiClient>();

  /// Get all employees for a salon
  Future<ApiResponse<List<EmployeeModel>>> getEmployees(String salonId) async {
    return _client.getRequest<List<EmployeeModel>>(
      ApiEndpoints.employeesBySalon(salonId),
      decoder: (data) {
        if (data is List) {
          return data
              .map((e) => EmployeeModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );
  }

  /// Get employee by ID
  Future<ApiResponse<EmployeeModel>> getEmployeeById(String id) async {
    return _client.getRequest<EmployeeModel>(
      ApiEndpoints.employeeById(id),
      decoder: (data) => EmployeeModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Create employee
  Future<ApiResponse<EmployeeModel>> createEmployee(
    Map<String, dynamic> data,
  ) async {
    return _client.postRequest<EmployeeModel>(
      ApiEndpoints.employees,
      body: data,
      decoder: (data) => EmployeeModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Update employee
  Future<ApiResponse<EmployeeModel>> updateEmployee(
    String id,
    Map<String, dynamic> data,
  ) async {
    return _client.putRequest<EmployeeModel>(
      ApiEndpoints.employeeById(id),
      body: data,
      decoder: (data) => EmployeeModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Delete employee
  Future<ApiResponse<void>> deleteEmployee(String id) async {
    return _client.deleteRequest<void>(ApiEndpoints.employeeById(id));
  }

  /// Get employee services
  Future<ApiResponse<List<ServiceModel>>> getEmployeeServices(
    String employeeId,
  ) async {
    return _client.getRequest<List<ServiceModel>>(
      ApiEndpoints.employeeServices(employeeId),
      decoder: (data) {
        if (data is List) {
          return data
              .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );
  }

  /// Get employee schedules
  Future<ApiResponse<List<ScheduleModel>>> getEmployeeSchedules(
    String employeeId,
  ) async {
    return _client.getRequest<List<ScheduleModel>>(
      ApiEndpoints.employeeSchedules(employeeId),
      decoder: (data) {
        if (data is List) {
          return data
              .map((e) => ScheduleModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );
  }

  /// Update employee schedule
  Future<ApiResponse<ScheduleModel>> updateEmployeeSchedule(
    String employeeId,
    String scheduleId,
    Map<String, dynamic> data,
  ) async {
    return _client.putRequest<ScheduleModel>(
      '${ApiEndpoints.employeeSchedules(employeeId)}/$scheduleId',
      body: data,
      decoder: (data) => ScheduleModel.fromJson(data as Map<String, dynamic>),
    );
  }
}

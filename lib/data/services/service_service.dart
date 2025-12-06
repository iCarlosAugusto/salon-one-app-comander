import 'package:get/get.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/service_model.dart';
import 'api_client.dart';

/// Service for service catalog API operations
class ServiceService extends GetxService {
  final ApiClient _client = Get.find<ApiClient>();

  /// Get all services for a salon
  Future<ApiResponse<List<ServiceModel>>> getServices(String salonId) async {
    return _client.getRequest<List<ServiceModel>>(
      ApiEndpoints.servicesBySalon(salonId),
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

  /// Get active services for a salon
  Future<ApiResponse<List<ServiceModel>>> getActiveServices(
    String salonId,
  ) async {
    return _client.getRequest<List<ServiceModel>>(
      ApiEndpoints.activeServicesBySalon(salonId),
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

  /// Get service by ID
  Future<ApiResponse<ServiceModel>> getServiceById(String id) async {
    return _client.getRequest<ServiceModel>(
      ApiEndpoints.serviceById(id),
      decoder: (data) => ServiceModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Create service
  Future<ApiResponse<ServiceModel>> createService(
    Map<String, dynamic> data,
  ) async {
    return _client.postRequest<ServiceModel>(
      ApiEndpoints.services,
      body: data,
      decoder: (data) => ServiceModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Update service
  Future<ApiResponse<ServiceModel>> updateService(
    String id,
    Map<String, dynamic> data,
  ) async {
    return _client.putRequest<ServiceModel>(
      ApiEndpoints.serviceById(id),
      body: data,
      decoder: (data) => ServiceModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Delete service
  Future<ApiResponse<void>> deleteService(String id) async {
    return _client.deleteRequest<void>(ApiEndpoints.serviceById(id));
  }

  /// Toggle service active status
  Future<ApiResponse<ServiceModel>> toggleServiceStatus(
    String id,
    bool isActive,
  ) async {
    return _client.patchRequest<ServiceModel>(
      ApiEndpoints.serviceById(id),
      body: {'isActive': isActive},
      decoder: (data) => ServiceModel.fromJson(data as Map<String, dynamic>),
    );
  }
}

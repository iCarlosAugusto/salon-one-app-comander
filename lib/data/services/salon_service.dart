import 'package:get/get.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/salon_model.dart';
import 'api_client.dart';

/// Service for salon-related API operations
class SalonService extends GetxService {
  final ApiClient _client = Get.find<ApiClient>();

  /// Get all salons
  Future<ApiResponse<List<SalonModel>>> getSalons() async {
    return _client.getRequest<List<SalonModel>>(
      ApiEndpoints.salons,
      decoder: (data) {
        if (data is List) {
          return data
              .map((e) => SalonModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );
  }

  /// Get salon by ID
  Future<ApiResponse<SalonModel>> getSalonById(String id) async {
    return _client.getRequest<SalonModel>(
      ApiEndpoints.salonById(id),
      decoder: (data) => SalonModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Get salon by slug
  Future<ApiResponse<SalonModel>> getSalonBySlug(String slug) async {
    return _client.getRequest<SalonModel>(
      ApiEndpoints.salonBySlug(slug),
      decoder: (data) => SalonModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Update salon
  Future<ApiResponse<SalonModel>> updateSalon(
    String id,
    Map<String, dynamic> data,
  ) async {
    return _client.putRequest<SalonModel>(
      ApiEndpoints.salonById(id),
      body: data,
      decoder: (data) => SalonModel.fromJson(data as Map<String, dynamic>),
    );
  }
}

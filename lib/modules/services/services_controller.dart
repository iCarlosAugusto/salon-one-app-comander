import 'package:get/get.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/service_model.dart';
import '../../data/services/service_service.dart';

/// Controller for services management
class ServicesController extends GetxController {
  final _serviceService = Get.find<ServiceService>();

  // Loading states
  final isLoading = true.obs;
  final isSaving = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Data
  final services = <ServiceModel>[].obs;

  // Filters
  final showInactiveOnly = false.obs;
  final searchQuery = ''.obs;

  // Form state
  final editingService = Rxn<ServiceModel>();
  final isFormMode = false.obs;

  String get salonId => AppConstants.defaultSalonId;

  // Filtered services
  List<ServiceModel> get filteredServices {
    var filtered = services.toList();

    if (showInactiveOnly.value) {
      filtered = filtered.where((s) => !s.isActive).toList();
    }

    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((s) {
        return s.name.toLowerCase().contains(query) ||
            (s.description?.toLowerCase().contains(query) ?? false) ||
            (s.category?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Sort by name
    filtered.sort((a, b) => a.name.compareTo(b.name));

    return filtered;
  }

  // Stats
  int get activeCount => services.where((s) => s.isActive).length;
  int get inactiveCount => services.where((s) => !s.isActive).length;

  @override
  void onInit() {
    super.onInit();
    loadServices();
  }

  /// Load all services
  Future<void> loadServices() async {
    isLoading.value = true;
    hasError.value = false;

    try {
      final response = await _serviceService.getServices(salonId);
      if (response.isSuccess && response.data != null) {
        services.value = response.data!;
      } else {
        throw Exception(response.error);
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Create a new service
  Future<bool> createService(Map<String, dynamic> data) async {
    isSaving.value = true;
    try {
      data['salonId'] = salonId;
      final response = await _serviceService.createService(data);
      if (response.isSuccess && response.data != null) {
        services.add(response.data!);
        Get.snackbar(
          'Success',
          'Service created successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          response.error ?? 'Failed to create service',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } finally {
      isSaving.value = false;
    }
  }

  /// Update an existing service
  Future<bool> updateService(String id, Map<String, dynamic> data) async {
    isSaving.value = true;
    try {
      final response = await _serviceService.updateService(id, data);
      if (response.isSuccess && response.data != null) {
        final index = services.indexWhere((s) => s.id == id);
        if (index != -1) {
          services[index] = response.data!;
        }
        Get.snackbar(
          'Success',
          'Service updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          response.error ?? 'Failed to update service',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } finally {
      isSaving.value = false;
    }
  }

  /// Delete a service
  Future<bool> deleteService(String id) async {
    isSaving.value = true;
    try {
      final response = await _serviceService.deleteService(id);
      if (response.statusCode == 204) {
        services.removeWhere((s) => s.id == id);
        Get.snackbar(
          'Success',
          'Service deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          response.error ?? 'Failed to delete service',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } finally {
      isSaving.value = false;
    }
  }

  /// Toggle service active status
  Future<bool> toggleServiceStatus(ServiceModel service) async {
    isSaving.value = true;
    try {
      final response = await _serviceService.toggleServiceStatus(
        service.id,
        !service.isActive,
      );
      if (response.isSuccess && response.data != null) {
        final index = services.indexWhere((s) => s.id == service.id);
        if (index != -1) {
          services[index] = response.data!;
        }
        Get.snackbar(
          'Success',
          service.isActive ? 'Service deactivated' : 'Service activated',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          response.error ?? 'Failed to update status',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } finally {
      isSaving.value = false;
    }
  }

  /// Start editing a service
  void editService(ServiceModel service) {
    editingService.value = service;
    isFormMode.value = true;
  }

  /// Start creating a new service
  void createNewService() {
    editingService.value = null;
    isFormMode.value = true;
  }

  /// Cancel form mode
  void cancelForm() {
    editingService.value = null;
    isFormMode.value = false;
  }

  /// Refresh services
  Future<void> refresh() => loadServices();
}

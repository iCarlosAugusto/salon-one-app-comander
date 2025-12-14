import 'package:get/get.dart';
import '../../../../data/models/service_model.dart';
import '../../../../data/services/service_service.dart';
import '../../../../data/services/session_service.dart';
import '../../../../core/constants/app_constants.dart';

/// Controller for service selection screen
class ServiceSelectionController extends GetxController {
  final _serviceService = Get.find<ServiceService>();
  final _sessionService = Get.find<SessionService>();

  // Loading state
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Search
  final searchQuery = ''.obs;

  // Services data
  final availableServices = <ServiceModel>[].obs;
  final selectedServiceIds = <String>{}.obs;

  // Computed: filtered services based on search
  List<ServiceModel> get filteredServices {
    if (searchQuery.value.isEmpty) {
      return availableServices;
    }
    final query = searchQuery.value.toLowerCase();
    return availableServices
        .where((s) => s.name.toLowerCase().contains(query))
        .toList();
  }

  // Computed: selected services
  List<ServiceModel> get selectedServices {
    return availableServices
        .where((s) => selectedServiceIds.contains(s.id))
        .toList();
  }

  // Computed: total price of selected services
  double get totalPrice {
    return selectedServices.fold(0, (sum, s) => sum + s.price);
  }

  // Computed: total duration of selected services
  int get totalDuration {
    return selectedServices.fold(0, (sum, s) => sum + s.duration);
  }

  @override
  void onInit() {
    super.onInit();

    // Get initial selected services from arguments
    final args = Get.arguments as Map<String, dynamic>?;
    final initialSelectedIds =
        args?['selectedServiceIds'] as List<String>? ?? [];
    selectedServiceIds.addAll(initialSelectedIds);

    loadServices();
  }

  /// Load services for the logged-in barber
  Future<void> loadServices() async {
    isLoading.value = true;
    hasError.value = false;

    try {
      final userData = await _sessionService.getUserData();
      final salonId = userData?.salonId ?? AppConstants.defaultSalonId;

      final response = await _serviceService.getServices(salonId);

      if (response.isSuccess && response.data != null) {
        // Only show active services
        availableServices.value = response.data!
            .where((s) => s.isActive)
            .toList();
      } else {
        hasError.value = true;
        errorMessage.value = response.error ?? 'Failed to load services';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggle service selection
  void toggleService(String serviceId) {
    if (selectedServiceIds.contains(serviceId)) {
      selectedServiceIds.remove(serviceId);
    } else {
      selectedServiceIds.add(serviceId);
    }
  }

  /// Check if a service is selected
  bool isSelected(String serviceId) {
    return selectedServiceIds.contains(serviceId);
  }

  /// Update search query
  void updateSearch(String query) {
    searchQuery.value = query;
  }

  /// Confirm selection and return to previous screen
  void confirmSelection() {
    Get.back(result: selectedServices);
  }
}

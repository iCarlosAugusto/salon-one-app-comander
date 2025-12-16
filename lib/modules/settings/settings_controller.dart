import 'package:get/get.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/salon_model.dart';
import '../../data/services/salon_service.dart';

/// Controller for salon settings management
class SettingsController extends GetxController {
  final _salonService = Get.find<SalonService>();

  // Loading states
  final isLoading = true.obs;
  final isSaving = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Data
  final salon = Rxn<SalonModel>();

  // Current section
  final currentSection = SettingsSection.profile.obs;

  String get salonId => AppConstants.defaultSalonId;

  @override
  void onInit() {
    super.onInit();
    loadSalon();
  }

  /// Load salon data
  Future<void> loadSalon() async {
    isLoading.value = true;
    hasError.value = false;

    try {
      final response = await _salonService.getSalonById(salonId);
      if (response.isSuccess && response.data != null) {
        salon.value = response.data;
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

  /// Update salon profile
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    isSaving.value = true;
    try {
      final response = await _salonService.updateSalon(salonId, data);
      if (response.isSuccess && response.data != null) {
        salon.value = response.data;
        Get.snackbar(
          'Success',
          'Profile updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          response.error ?? 'Failed to update profile',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } finally {
      isSaving.value = false;
    }
  }

  /// Update booking settings
  Future<bool> updateBookingSettings(Map<String, dynamic> data) async {
    isSaving.value = true;
    try {
      final response = await _salonService.updateSalon(salonId, data);
      if (response.isSuccess && response.data != null) {
        salon.value = response.data;
        Get.snackbar(
          'Success',
          'Settings updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          response.error ?? 'Failed to update settings',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } finally {
      isSaving.value = false;
    }
  }

  /// Navigate to a settings section
  void goToSection(SettingsSection section) {
    currentSection.value = section;
  }

  /// Go back to main settings
  void goBack() {
    currentSection.value = SettingsSection.profile;
  }

  /// Refresh data
  @override
  Future<void> refresh() => loadSalon();
}

enum SettingsSection { profile, booking }

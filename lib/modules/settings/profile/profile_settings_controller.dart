import 'package:get/get.dart';
import '../../../data/models/auth_user.dart';
import '../../../data/services/session_service.dart';

/// Controller for profile settings screen
///
/// Handles loading and updating user profile data
class ProfileSettingsController extends GetxController {
  final _sessionService = Get.find<SessionService>();

  // State
  final isLoading = true.obs;
  final isSaving = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // User data
  final currentUser = Rxn<AuthUser>();

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  /// Load current user data
  Future<void> loadUserData() async {
    isLoading.value = true;
    hasError.value = false;

    try {
      final user = await _sessionService.getUserData();
      if (user != null) {
        currentUser.value = user;
      } else {
        throw Exception('User data not found');
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Update user profile
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    isSaving.value = true;

    try {
      // Update local session data
      // TODO: Add backend API call to persist changes when available
      final updatedUser = currentUser.value?.copyWith(
        displayName: data['displayName'] as String?,
        phone: data['phone'] as String?,
      );

      if (updatedUser != null) {
        await _sessionService.saveUserData(updatedUser);
        currentUser.value = updatedUser;

        Get.snackbar(
          'Success',
          'Profile updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Refresh data
  @override
  Future<void> refresh() => loadUserData();
}

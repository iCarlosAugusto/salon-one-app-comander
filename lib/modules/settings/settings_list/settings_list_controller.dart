import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/auth_user.dart';
import '../../../data/services/session_service.dart';

/// Controller for the settings list screen
///
/// Handles:
/// - Loading user role for role-based visibility
/// - Support contact action
class SettingsListController extends GetxController {
  final _sessionService = Get.find<SessionService>();

  // State
  final isLoading = true.obs;
  final currentUser = Rxn<AuthUser>();

  /// Check if current user is an admin
  bool get isAdmin => currentUser.value?.role == UserRole.admin;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  /// Load current user data for role checking
  Future<void> _loadUserData() async {
    isLoading.value = true;
    try {
      currentUser.value = await _sessionService.getUserData();
    } finally {
      isLoading.value = false;
    }
  }

  /// Launch support email or external link
  Future<void> launchSupport() async {
    // TODO: Replace with actual support email
    final uri = Uri.parse(
      'mailto:support@salonone.com?subject=Support Request',
    );

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        Get.snackbar(
          'Error',
          'Could not open email client',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to open support: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Refresh user data
  @override
  Future<void> refresh() => _loadUserData();
}

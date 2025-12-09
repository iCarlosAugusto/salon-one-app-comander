import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../shared/routes/app_routes.dart';

/// Controller for the login page
class LoginController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // UI state
  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxnString errorMessage = RxnString(null);

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  /// Clear error message
  void clearError() {
    errorMessage.value = null;
  }

  /// Validate email format
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Validate password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Handle sign in
  Future<void> signIn() async {
    clearError();

    // Validate form
    if (formKey.currentState?.validate() != true) {
      return;
    }

    isLoading.value = true;

    try {
      await _authService.signIn(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      // Clear form on success
      emailController.clear();
      passwordController.clear();

      // Navigate to dashboard
      Get.offAllNamed(Routes.dashboard);
    } catch (e) {
      // Show error from auth service or generic message
      errorMessage.value =
          _authService.errorMessage.value ?? 'An error occurred during sign in';
    } finally {
      isLoading.value = false;
    }
  }
}

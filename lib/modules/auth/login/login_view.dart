import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/constants/app_colors.dart';
import 'login_controller.dart';

/// Login page with email/password authentication
class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo and title
                  _buildHeader(theme),
                  const SizedBox(height: 48),

                  // Login form
                  _buildLoginForm(context, theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ShadThemeData theme) {
    return Column(
      children: [
        // App icon/logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.content_cut, size: 40, color: Colors.white),
        ),
        const SizedBox(height: 24),

        // Title
        Text(
          'Salon One',
          style: theme.textTheme.h2.copyWith(
            color: AppColors.foreground,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // Subtitle
        Text(
          'Commander',
          style: theme.textTheme.muted.copyWith(
            color: AppColors.mutedForeground,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context, ShadThemeData theme) {
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Welcome text
          Text(
            'Welcome back',
            style: theme.textTheme.h3.copyWith(color: AppColors.foreground),
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in to manage your salon',
            style: theme.textTheme.muted.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 32),

          // Error message
          Obx(() {
            final error = controller.errorMessage.value;
            if (error == null) return const SizedBox.shrink();

            return Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: AppColors.error, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      error,
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                  GestureDetector(
                    onTap: controller.clearError,
                    child: Icon(Icons.close, color: AppColors.error, size: 18),
                  ),
                ],
              ),
            );
          }),

          // Email field
          _buildTextField(
            controller: controller.emailController,
            label: 'Email',
            hint: 'Enter your email',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: controller.validateEmail,
            theme: theme,
          ),
          const SizedBox(height: 16),

          // Password field
          Obx(
            () => _buildTextField(
              controller: controller.passwordController,
              label: 'Password',
              hint: 'Enter your password',
              obscureText: controller.obscurePassword.value,
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  controller.obscurePassword.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.mutedForeground,
                ),
                onPressed: controller.togglePasswordVisibility,
              ),
              validator: controller.validatePassword,
              theme: theme,
            ),
          ),
          const SizedBox(height: 32),

          // Sign in button
          Obx(
            () => ShadButton(
              onPressed: controller.isLoading.value ? null : controller.signIn,
              child: controller.isLoading.value
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryForeground,
                        ),
                      ),
                    )
                  : const Text('Sign In'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    required String? Function(String?) validator,
    required ShadThemeData theme,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.small.copyWith(
            color: AppColors.foreground,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          style: TextStyle(color: AppColors.foreground),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.mutedForeground),
            filled: true,
            fillColor: AppColors.card,
            prefixIcon: Icon(prefixIcon, color: AppColors.mutedForeground),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.error, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}

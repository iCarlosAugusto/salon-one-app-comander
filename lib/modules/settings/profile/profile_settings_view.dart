import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_text_theme.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/layouts/admin_layout.dart';
import '../../../shared/routes/app_routes.dart';
import '../../../shared/widgets/page_components.dart';
import '../../../shared/widgets/text_field_widget.dart';
import 'profile_settings_controller.dart';

/// Profile settings screen for editing user personal information
///
/// Allows users to edit:
/// - Display name
/// - Email (read-only, linked to auth)
/// - Phone number
class ProfileSettingsView extends GetView<ProfileSettingsController> {
  const ProfileSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: Routes.settings,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingState(message: 'Loading profile...');
        }

        if (controller.hasError.value) {
          return ErrorState(
            message: controller.errorMessage.value,
            onRetry: controller.refresh,
          );
        }

        return _ProfileForm(controller: controller);
      }),
    );
  }
}

class _ProfileForm extends StatefulWidget {
  const _ProfileForm({required this.controller});

  final ProfileSettingsController controller;

  @override
  State<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<_ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final user = widget.controller.currentUser.value;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.controller.updateProfile({
        'displayName': _nameController.text.trim().isEmpty
            ? null
            : _nameController.text.trim(),
        'phone': _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: Responsive.padding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button and title
          Row(
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: AppConstants.spacingSm),
              Text('Profile Settings', style: context.appTextTheme.pageTitle),
            ],
          ),
          const SizedBox(height: AppConstants.spacingXs),
          Padding(
            padding: const EdgeInsets.only(left: 48),
            child: Text(
              'Update your personal information',
              style: context.appTextTheme.cardSubtitle,
            ),
          ),
          const SizedBox(height: AppConstants.spacingLg),

          // Form
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Form(
                key: _formKey,
                child: ShadCard(
                  padding: const EdgeInsets.all(AppConstants.spacingLg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Personal Information',
                        style: context.appTextTheme.sectionTitle,
                      ),
                      const SizedBox(height: AppConstants.spacingLg),

                      // Display Name
                      TextFieldWidget(
                        label: 'Display Name',
                        controller: _nameController,
                        placeholder: 'Your display name',
                      ),
                      const SizedBox(height: AppConstants.spacingMd),

                      // Email (read-only)
                      TextFieldWidget(
                        label: 'Email',
                        controller: _emailController,
                        placeholder: 'your@email.com',
                        readOnly: true,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: AppConstants.spacingXs,
                        ),
                        child: Text(
                          'Email is linked to your login and cannot be changed here',
                          style: context.appTextTheme.helper,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingMd),

                      // Phone
                      TextFieldWidgetVariants.phone(
                        label: 'Phone Number',
                        controller: _phoneController,
                        placeholder: '(00) 00000-0000',
                      ),
                      const SizedBox(height: AppConstants.spacingLg),

                      // Save button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ShadButton.outline(
                            onPressed: () => Get.back(),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: AppConstants.spacingSm),
                          Obx(
                            () => ShadButton(
                              onPressed: widget.controller.isSaving.value
                                  ? null
                                  : _handleSave,
                              child: widget.controller.isSaving.value
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Save Changes'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

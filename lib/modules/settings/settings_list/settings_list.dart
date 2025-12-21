import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_text_theme.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/layouts/admin_layout.dart';
import '../../../shared/routes/app_routes.dart';
import 'settings_list_controller.dart';

/// Settings list screen displaying navigation options
///
/// Shows:
/// - Profile Settings (all users)
/// - Barbershop Settings (admin only)
/// - Help / Support (all users)
class SettingsList extends GetView<SettingsListController> {
  const SettingsList({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: Routes.settings,
      child: SingleChildScrollView(
        padding: Responsive.padding(context),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page header
                Text('Settings', style: context.appTextTheme.pageTitle),
                const SizedBox(height: AppConstants.spacingXs),
                Text(
                  'Manage your account and preferences',
                  style: context.appTextTheme.cardSubtitle,
                ),
                const SizedBox(height: AppConstants.spacingXl),

                // Account section
                ListTile(
                  title: const Text(
                    'Account',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  leading: Icon(Icons.person_outline),
                  subtitle: const Text('Your personal information'),
                  onTap: () => Get.toNamed(Routes.profileSettings),
                ),

                // Business section (admin only)
                Obx(() {
                  if (controller.isLoading.value) {
                    return const SizedBox.shrink();
                  }

                  if (!controller.isAdmin) {
                    return const SizedBox.shrink();
                  }

                  return ListTile(
                    title: const Text(
                      'Business',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    leading: Icon(Icons.store_outlined),
                    subtitle: const Text('Business profile and information'),
                    onTap: () => Get.toNamed(Routes.salonProfile),
                  );
                }),

                // Support section
                ListTile(
                  title: const Text(
                    'Support',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  leading: Icon(Icons.help_outline),
                  subtitle: const Text('Contact our team'),
                  onTap: controller.launchSupport,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

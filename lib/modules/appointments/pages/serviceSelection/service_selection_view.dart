import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/formatters.dart';
import 'service_selection_controller.dart';

/// Service selection screen for appointment creation
class ServiceSelectionView extends GetView<ServiceSelectionController> {
  const ServiceSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Select Services'),
        backgroundColor: theme.colorScheme.background,
        foregroundColor: theme.colorScheme.foreground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 800 : double.infinity,
                ),
                child: TextField(
                  onChanged: controller.updateSearch,
                  decoration: InputDecoration(
                    hintText: 'Search services...',
                    prefixIcon: Icon(
                      Icons.search,
                      size: 18,
                      color: theme.colorScheme.mutedForeground,
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusSm,
                      ),
                      borderSide: BorderSide(color: theme.colorScheme.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusSm,
                      ),
                      borderSide: BorderSide(color: theme.colorScheme.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusSm,
                      ),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingMd,
                      vertical: AppConstants.spacingSm,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Services list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.hasError.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: theme.colorScheme.destructive,
                      ),
                      const SizedBox(height: AppConstants.spacingMd),
                      Text(
                        controller.errorMessage.value,
                        style: TextStyle(color: theme.colorScheme.foreground),
                      ),
                      const SizedBox(height: AppConstants.spacingMd),
                      ShadButton(
                        onPressed: controller.loadServices,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final services = controller.filteredServices;

              if (services.isEmpty) {
                return Center(
                  child: Text(
                    'No services found',
                    style: TextStyle(color: theme.colorScheme.mutedForeground),
                  ),
                );
              }

              return Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isDesktop ? 800 : double.infinity,
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingMd,
                    ),
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final service = services[index];
                      return Obx(
                        () => ListTile(
                          leading: Checkbox(
                            value: controller.isSelected(service.id),
                            onChanged: (value) {
                              controller.toggleService(service.id);
                            },
                          ),
                          onTap: () => controller.toggleService(service.id),
                          selected: controller.isSelected(service.id),
                          title: Text(service.name),
                          subtitle: Text(
                            "${service.duration} min - R\$ ${service.price}",
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }),
          ),

          // Bottom bar with summary and confirm button
          Obx(() => _buildBottomBar(context)),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final theme = ShadTheme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 600;
    final selectedCount = controller.selectedServiceIds.length;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        border: Border(top: BorderSide(color: theme.colorScheme.border)),
      ),
      child: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 800 : double.infinity,
            ),
            child: Row(
              children: [
                // Summary
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$selectedCount service${selectedCount != 1 ? 's' : ''} selected',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.foreground,
                        ),
                      ),
                      if (selectedCount > 0)
                        Text(
                          '${controller.totalDuration} min • ${Formatters.formatCurrency(controller.totalPrice)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.mutedForeground,
                          ),
                        ),
                    ],
                  ),
                ),

                // Confirm button
                ShadButton(
                  onPressed: selectedCount > 0
                      ? controller.confirmSelection
                      : null,
                  child: const Text('Confirm'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

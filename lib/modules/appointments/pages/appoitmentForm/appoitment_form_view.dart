import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_one_comander/shared/widgets/text_field_widget.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import 'appoitment_form_controller.dart';

class AppoitmentFormView extends GetView<AppoitmentFormController> {
  const AppoitmentFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final dateSelected = Get.arguments['dateSelected'] as DateTime;
    final theme = ShadTheme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 600;
    final dateFormatted = dateSelected.toString().split(' ')[0];

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text('Agendamento para o dia $dateFormatted'),
        backgroundColor: theme.colorScheme.background,
        foregroundColor: theme.colorScheme.foreground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 500 : double.infinity,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(
                isDesktop ? AppConstants.spacingXl : AppConstants.spacingMd,
              ),
              child: Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    if (isDesktop) ...[
                      const SizedBox(height: AppConstants.spacingXs),
                      Text(
                        'Fill in the client details and select a time',
                        style: TextStyle(
                          color: theme.colorScheme.mutedForeground,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingXl),
                    ],
                    TextFieldWidget(
                      controller: controller.customerNameController,
                      isRequired: true,
                      label: 'Customer Name',
                      errorText: controller.customerNameError.value,
                    ),
                    const SizedBox(height: AppConstants.spacingMd),

                    // Customer Phone Field
                    TextFieldWidgetVariants.phone(
                      isRequired: true,
                      controller: controller.customerPhoneController,
                      label: 'Customer Phone',
                      errorText: controller.customerPhoneError.value,
                    ),
                    const SizedBox(height: AppConstants.spacingMd),

                    // Services Selection
                    const SizedBox(height: AppConstants.spacingXs),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.card,
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusMd,
                        ),
                        border: Border.all(
                          color: controller.servicesError.value != null
                              ? theme.colorScheme.destructive
                              : theme.colorScheme.border,
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.spa),
                        title: Text('Services'),
                        subtitle: Text(
                          '${controller.selectedServices.length} service${controller.selectedServices.length != 1 ? 's' : ''} selected',
                        ),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () =>
                            controller.openServiceSelection(dateSelected),
                      ),
                    ),
                    if (controller.servicesError.value != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        controller.servicesError.value!,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.destructive,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppConstants.spacingMd),

                    // Start Time Field
                    const SizedBox(height: AppConstants.spacingXs),
                    _buildTimeSelector(context),
                    if (controller.startTimeError.value != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        controller.startTimeError.value!,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.destructive,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppConstants.spacingXl),

                    // Submit Button
                    ShadButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.submitForm,
                      size: ShadButtonSize.lg,
                      child: controller.isLoading.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Book Appointment'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSelector(BuildContext context) {
    final theme = ShadTheme.of(context);
    final times = controller.availableTimes;

    return Wrap(
      spacing: AppConstants.spacingSm,
      runSpacing: AppConstants.spacingSm,
      children: times.map((time) {
        final isSelected = controller.selectedTime.value == time;

        return InkWell(
          onTap: () => controller.selectTime(time),
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingMd,
              vertical: AppConstants.spacingSm,
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : theme.colorScheme.card,
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : theme.colorScheme.border,
              ),
            ),
            child: Text(
              time,
              style: TextStyle(
                color: isSelected ? Colors.white : theme.colorScheme.foreground,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

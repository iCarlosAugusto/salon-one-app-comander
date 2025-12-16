import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_one_comander/shared/widgets/text_field_widget.dart';
import 'package:salon_one_comander/shared/widgets/responsive_sheet.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/formatters.dart';
import 'appoitment_form_controller.dart';

class AppoitmentFormView extends GetView<AppoitmentFormController> {
  const AppoitmentFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final dateSelected = Get.arguments['dateSelected'] as DateTime;
    final theme = ShadTheme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 600;
    final formattedDate = DateFormat(
      "d 'de' MMMM 'de' y",
      'pt_BR',
    ).format(dateSelected);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.background,
        foregroundColor: theme.colorScheme.foreground,
        elevation: 0,
      ),
      body: SafeArea(
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

                  Text(
                    "Agendamento para o dia \n $formattedDate",
                    style: context.textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
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
                      trailing: controller.isLoadingTimeSlots.value
                          ? const CircularProgressIndicator.adaptive()
                          : Icon(Icons.arrow_forward_ios),
                      onTap: () => controller.isLoadingTimeSlots.value
                          ? null
                          : controller.openServiceSelection(dateSelected),
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
                  _buildTimeSelector(context, dateSelected),
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
                        : () => controller.submitForm(dateSelected),
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
    );
  }

  Widget _buildTimeSelector(BuildContext context, DateTime dateSelected) {
    final theme = ShadTheme.of(context);
    final times = controller.availableTimes;

    return Wrap(
      spacing: AppConstants.spacingSm,
      runSpacing: AppConstants.spacingSm,
      children: times.map((time) {
        final isSelected = controller.selectedTime.value == time;

        return InkWell(
          onTap: () {
            controller.selectTime(time);
            _showBookingConfirmation(context, dateSelected, time);
          },
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

  void _showBookingConfirmation(
    BuildContext context,
    DateTime dateSelected,
    String selectedTime,
  ) {
    final theme = ShadTheme.of(context);
    final formattedDate = Formatters.formatDateFull(dateSelected);
    final totalDuration = controller.selectedServices.fold<int>(
      0,
      (sum, s) => sum + s.duration,
    );
    final totalPrice = controller.selectedServices.fold<double>(
      0,
      (sum, s) => sum + s.price,
    );

    ResponsiveSheet.show(
      context: context,
      showCloseButton: true,
      title: "Confirmar Agendamento",
      subtitle: "Revise os detalhes do agendamento",
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Appointment Card
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            decoration: BoxDecoration(
              color: theme.colorScheme.card,
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              border: Border.all(
                color: theme.colorScheme.border.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              children: [
                // Date and Time Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.foreground,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$selectedTime • $totalDuration min',
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.colorScheme.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingMd),
                Divider(color: theme.colorScheme.border.withValues(alpha: 0.5)),
                const SizedBox(height: AppConstants.spacingMd),

                // Client Info
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 20,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.customerNameController.text,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.foreground,
                            ),
                          ),
                          if (controller
                              .customerPhoneController
                              .text
                              .isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              controller.customerPhoneController.text,
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.colorScheme.mutedForeground,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),

          // Services List
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            decoration: BoxDecoration(
              color: theme.colorScheme.card,
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              border: Border.all(
                color: theme.colorScheme.border.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Serviços',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingSm),
                ...controller.selectedServices.map(
                  (service) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  service.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.colorScheme.foreground,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'R\$ ${service.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.foreground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spacingSm),
                Divider(color: theme.colorScheme.border.withValues(alpha: 0.5)),
                const SizedBox(height: AppConstants.spacingSm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.foreground,
                      ),
                    ),
                    Text(
                      'R\$ ${totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacingXl),

          // Action Buttons
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Obx(
                  () => ShadButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () async {
                            await controller.submitForm(dateSelected);
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check, size: 18),
                              SizedBox(width: 8),
                              Text('Confirmar'),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

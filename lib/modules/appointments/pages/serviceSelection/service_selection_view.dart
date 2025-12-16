import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_one_comander/shared/widgets/generic_list_view.dart';
import 'package:salon_one_comander/shared/widgets/text_field_widget.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
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
                child: TextFieldWidget(
                  onChanged: controller.updateSearch,
                  placeholder: 'Procure pelo serviço',
                ),
              ),
            ),
          ),
          // Services list
          Expanded(
            child: Obx(() {
              return Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isDesktop ? 800 : double.infinity,
                  ),
                  child: GenericListView(
                    isLoading: controller.isLoading.value,
                    items: controller.availableServices,
                    emptyTitle: "Nenhum serviço vinculado a você",
                    emptyMessage:
                        "Peça para o gerente da barbearia vincular os serviços que deseja.",
                    hasError: controller.hasError.value,
                    onRetry: controller.loadServices,
                    onRefresh: controller.loadServices,
                    itemBuilder: (context, item, index) {
                      return Obx(
                        () => ListTile(
                          onTap: () => controller.toggleService(item.id),
                          leading: Checkbox.adaptive(
                            value: controller.isSelected(item.id),
                            onChanged: (value) {
                              controller.toggleService(item.id);
                            },
                          ),
                          title: Text(item.name),
                          subtitle: Text(
                            "${item.duration} min - R\$ ${item.price}",
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
            child: ListTile(
              title: Text(
                '$selectedCount serviços${selectedCount != 1 ? 's' : ''}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.foreground,
                ),
              ),
              subtitle: Text(
                '${controller.totalDuration} min • ${Formatters.formatCurrency(controller.totalPrice)}',
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
              trailing: ShadButton(
                onPressed: selectedCount > 0
                    ? controller.confirmSelection
                    : null,
                child: const Text('Confirm'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

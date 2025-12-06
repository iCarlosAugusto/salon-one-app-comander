import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/formatters.dart';
import '../../shared/layouts/admin_layout.dart';
import '../../shared/routes/app_routes.dart';
import '../../shared/widgets/page_components.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../data/models/service_model.dart';
import 'services_controller.dart';

/// Services list view
class ServicesView extends GetView<ServicesController> {
  const ServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: Routes.services,
      child: Obx(() {
        // Show form when in form mode
        if (controller.isFormMode.value) {
          return _ServiceFormView(
            service: controller.editingService.value,
            onSave: (data) async {
              bool success;
              if (controller.editingService.value != null) {
                success = await controller.updateService(
                  controller.editingService.value!.id,
                  data,
                );
              } else {
                success = await controller.createService(data);
              }
              if (success) {
                controller.cancelForm();
              }
            },
            onCancel: controller.cancelForm,
            isSaving: controller.isSaving.value,
          );
        }

        return Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const LoadingState(message: 'Loading services...');
                }

                if (controller.hasError.value) {
                  return ErrorState(
                    message: controller.errorMessage.value,
                    onRetry: controller.refresh,
                  );
                }

                final services = controller.filteredServices;

                if (services.isEmpty) {
                  return EmptyState(
                    icon: Icons.spa,
                    title: 'No services found',
                    message: controller.services.isEmpty
                        ? 'Add your first service to get started'
                        : 'Try adjusting your search',
                    action: controller.services.isEmpty
                        ? controller.createNewService
                        : () => controller.searchQuery.value = '',
                    actionLabel: controller.services.isEmpty
                        ? 'Add Service'
                        : 'Clear Search',
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.refresh,
                  color: AppColors.primary,
                  child: _buildServicesGrid(context, services),
                );
              }),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        border: Border(bottom: BorderSide(color: theme.colorScheme.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Services',
                    style: TextStyle(
                      color: theme.colorScheme.foreground,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXs),
                  Obx(
                    () => Text(
                      '${controller.activeCount} active • ${controller.inactiveCount} inactive',
                      style: TextStyle(
                        color: theme.colorScheme.mutedForeground,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              ShadButton(
                onPressed: controller.createNewService,
                size: ShadButtonSize.sm,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 18),
                    SizedBox(width: 4),
                    Text('Add Service'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMd),
          SizedBox(
            width: Responsive.isDesktop(context) ? 300 : double.infinity,
            child: ShadInput(
              placeholder: const Text('Search services...'),
              // prefix: const Padding(
              //   padding: EdgeInsets.only(left: 8),
              //   child: Icon(Icons.search, size: 18),
              // ),
              onChanged: (value) => controller.searchQuery.value = value,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesGrid(BuildContext context, List<ServiceModel> services) {
    return SingleChildScrollView(
      padding: Responsive.padding(context),
      child: ResponsiveGrid(
        mobileColumns: 1,
        tabletColumns: 2,
        desktopColumns: 3,
        children: services
            .map(
              (service) => _ServiceCard(
                service: service,
                onEdit: () => controller.editService(service),
                onToggleStatus: () => controller.toggleServiceStatus(service),
                onDelete: () => _showDeleteDialog(context, service),
              ),
            )
            .toList(),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ServiceModel service) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete Service',
      message:
          'Are you sure you want to delete "${service.name}"? This action cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed == true) {
      controller.deleteService(service.id);
    }
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.service,
    required this.onEdit,
    required this.onToggleStatus,
    required this.onDelete,
  });

  final ServiceModel service;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return ShadCard(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: service.isActive
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : theme.colorScheme.muted,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                ),
                child: Icon(
                  Icons.spa,
                  color: service.isActive
                      ? AppColors.primary
                      : theme.colorScheme.mutedForeground,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            service.name,
                            style: TextStyle(
                              color: theme.colorScheme.foreground,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (!service.isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.muted,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Inactive',
                              style: TextStyle(
                                color: theme.colorScheme.mutedForeground,
                                fontSize: 11,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (service.description != null) ...[
                      const SizedBox(height: AppConstants.spacingXs),
                      Text(
                        service.description!,
                        style: TextStyle(
                          color: theme.colorScheme.mutedForeground,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMd),
          Row(
            children: [
              Icon(
                Icons.attach_money,
                size: 16,
                color: theme.colorScheme.mutedForeground,
              ),
              const SizedBox(width: 4),
              Text(
                Formatters.formatCurrency(service.price),
                style: TextStyle(
                  color: theme.colorScheme.foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Icon(
                Icons.schedule,
                size: 16,
                color: theme.colorScheme.mutedForeground,
              ),
              const SizedBox(width: 4),
              Text(
                Formatters.formatDuration(service.duration),
                style: TextStyle(
                  color: theme.colorScheme.mutedForeground,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMd),
          const Divider(height: 1),
          const SizedBox(height: AppConstants.spacingSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ShadButton.ghost(
                onPressed: onToggleStatus,
                size: ShadButtonSize.sm,
                child: Text(service.isActive ? 'Deactivate' : 'Activate'),
              ),
              ShadButton.ghost(
                onPressed: onEdit,
                size: ShadButtonSize.sm,
                child: const Text('Edit'),
              ),
              ShadButton.ghost(
                onPressed: onDelete,
                size: ShadButtonSize.sm,
                child: Text('Delete', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ServiceFormView extends StatefulWidget {
  const _ServiceFormView({
    required this.service,
    required this.onSave,
    required this.onCancel,
    required this.isSaving,
  });

  final ServiceModel? service;
  final Function(Map<String, dynamic>) onSave;
  final VoidCallback onCancel;
  final bool isSaving;

  @override
  State<_ServiceFormView> createState() => _ServiceFormViewState();
}

class _ServiceFormViewState extends State<_ServiceFormView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _durationController;
  late final TextEditingController _categoryController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.service?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.service?.description ?? '',
    );
    _priceController = TextEditingController(
      text: widget.service?.price.toStringAsFixed(2) ?? '',
    );
    _durationController = TextEditingController(
      text: widget.service?.duration.toString() ?? '',
    );
    _categoryController = TextEditingController(
      text: widget.service?.category ?? '',
    );
    _isActive = widget.service?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSave({
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        'price': double.tryParse(_priceController.text) ?? 0,
        'duration': int.tryParse(_durationController.text) ?? 30,
        'category': _categoryController.text.trim().isEmpty
            ? null
            : _categoryController.text.trim(),
        'isActive': _isActive,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final isEdit = widget.service != null;

    return SingleChildScrollView(
      padding: Responsive.padding(context),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ShadCard(
            padding: const EdgeInsets.all(AppConstants.spacingLg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: widget.onCancel,
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const SizedBox(width: AppConstants.spacingSm),
                      Text(
                        isEdit ? 'Edit Service' : 'New Service',
                        style: TextStyle(
                          color: theme.colorScheme.foreground,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingLg),
                  Text(
                    'Service Name *',
                    style: TextStyle(
                      color: theme.colorScheme.foreground,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXs),
                  ShadInput(
                    controller: _nameController,
                    placeholder: const Text('e.g., Haircut'),
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  Text(
                    'Description',
                    style: TextStyle(
                      color: theme.colorScheme.foreground,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXs),
                  ShadInput(
                    controller: _descriptionController,
                    placeholder: const Text('Optional description'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price *',
                              style: TextStyle(
                                color: theme.colorScheme.foreground,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: AppConstants.spacingXs),
                            ShadInput(
                              controller: _priceController,
                              placeholder: const Text('0.00'),

                              // prefix: const Padding(
                              //   padding: EdgeInsets.only(left: 8),
                              //   child: Text('R\$'),
                              // ),
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Duration (min) *',
                              style: TextStyle(
                                color: theme.colorScheme.foreground,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: AppConstants.spacingXs),
                            ShadInput(
                              controller: _durationController,
                              placeholder: const Text('30'),
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  Text(
                    'Category',
                    style: TextStyle(
                      color: theme.colorScheme.foreground,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXs),
                  ShadInput(
                    controller: _categoryController,
                    placeholder: const Text('e.g., Haircuts, Styling'),
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  Row(
                    children: [
                      ShadSwitch(
                        value: _isActive,
                        onChanged: (value) => setState(() => _isActive = value),
                      ),
                      const SizedBox(width: AppConstants.spacingSm),
                      Text(
                        'Active',
                        style: TextStyle(color: theme.colorScheme.foreground),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingLg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ShadButton.outline(
                        onPressed: widget.isSaving ? null : widget.onCancel,
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: AppConstants.spacingSm),
                      ShadButton(
                        onPressed: widget.isSaving ? null : _handleSave,
                        child: widget.isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(isEdit ? 'Save Changes' : 'Create Service'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/appointment_model.dart';
import 'appointment_details_controller.dart';

class AppointmentDetailsView extends GetView<AppointmentDetailsController> {
  const AppointmentDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          'domingo, 21 dez',
          style: context.textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
      ),
      body: Obx(() {
        final apt = controller.appointment.value;
        if (apt == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Client info card
                    _buildClientCard(context, apt),
                    const SizedBox(height: 16),

                    // Date/Time card
                    _buildDateTimeCard(context),
                    const SizedBox(height: 24),

                    // Services section
                    _buildServicesSection(context),
                    const SizedBox(height: 24),

                    // Add service button
                    _buildAddServiceButton(context),
                  ],
                ),
              ),
            ),

            // Bottom bar with total and checkout
            _buildBottomBar(context),
          ],
        );
      }),
    );
  }

  /// Client info card with name, email, actions
  Widget _buildClientCard(BuildContext context, AppointmentModel apt) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: const Color(0xFF6366F1),
          child: Text(
            apt.clientName.isNotEmpty ? apt.clientName[0].toUpperCase() : '?',
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        title: Text(apt.clientName),
        subtitle: Text(apt.clientEmail ?? apt.clientPhone),
      ),
    );
  }

  /// Date and time info card
  Widget _buildDateTimeCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Date and time row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    controller.formattedDate,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    controller.startTime,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Services section
  Widget _buildServicesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Serviços',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),

        Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.appointmentServices.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Nenhum serviço adicionado',
                style: TextStyle(color: Colors.white54),
              ),
            );
          }

          return Column(
            children: controller.appointmentServices.map((service) {
              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: _getGradientColor(service.id.hashCode),
                      width: 3,
                    ),
                  ),
                ),
                child: ListTile(
                  title: Text(service.name),
                  subtitle: Text(
                    '${service.formattedStartTime} · ${service.formattedEndTime}',
                  ),
                  trailing: Text('R\$ ${service.price.toStringAsFixed(0)}'),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  /// Add service button
  Widget _buildAddServiceButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: controller.addService,
      icon: const Icon(Icons.add_circle_outline, size: 20),
      label: const Text('Adicionar serviço'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white70,
        side: const BorderSide(color: Colors.white24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  /// Bottom bar with total and checkout button
  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Total row
          Obx(() {
            final apt = controller.appointment.value;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'R\$ ${apt?.totalPrice.toStringAsFixed(0) ?? '0'}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 16),

          // Checkout button row
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: controller.checkout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Checkout',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Get gradient color for service item border
  Color _getGradientColor(int index) {
    final colors = [
      const Color(0xFF06B6D4),
      const Color(0xFF8B5CF6),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFF10B981),
    ];
    return colors[index.abs() % colors.length];
  }
}

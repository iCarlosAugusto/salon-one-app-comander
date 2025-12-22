import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:salon_one_comander/data/models/service_model.dart';
import 'package:salon_one_comander/shared/routes/app_routes.dart';
import '../../../../data/models/appointment_model.dart';
import '../../../../data/models/appointment_service_item.dart';
import '../../../../data/services/appointment_service.dart';

/// Controller for appointment details page
class AppointmentDetailsController extends GetxController {
  final _appointmentService = Get.find<AppointmentService>();

  // Loading states
  final isLoading = false.obs;
  final isSaving = false.obs;

  // Data
  final appointment = Rxn<AppointmentModel>();
  final appointmentServices = <AppointmentServiceItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  /// Load appointment from arguments and fetch services
  void _loadInitialData() {
    final args = Get.arguments;
    if (args != null && args['appointment'] != null) {
      appointment.value = args['appointment'] as AppointmentModel;
      _loadAppointmentServices();
    }
  }

  /// Load services for this appointment from API
  Future<void> _loadAppointmentServices() async {
    final apt = appointment.value;
    if (apt == null) return;

    isLoading.value = true;
    try {
      final response = await _appointmentService.getAppointmentServices(apt.id);
      if (response.isSuccess && response.data != null) {
        appointmentServices.value = response.data!;
        debugPrint(
          'Loaded ${appointmentServices.length} services for appointment',
        );
      } else {
        debugPrint('Failed to load services: ${response.error}');
      }
    } catch (e) {
      debugPrint('Error loading appointment services: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Get formatted date for display (e.g., "domingo 21 dez")
  String get formattedDate {
    final apt = appointment.value;
    if (apt == null) return '';

    final date = apt.date;
    final weekdays = [
      'domingo',
      'segunda',
      'terça',
      'quarta',
      'quinta',
      'sexta',
      'sábado',
    ];
    final months = [
      'jan',
      'fev',
      'mar',
      'abr',
      'mai',
      'jun',
      'jul',
      'ago',
      'set',
      'out',
      'nov',
      'dez',
    ];

    return '${weekdays[date.weekday % 7]} ${date.day} ${months[date.month - 1]}';
  }

  /// Get start time for display
  String get startTime {
    final apt = appointment.value;
    if (apt == null) return '';
    return apt.startTime.substring(0, 5); // HH:MM
  }

  /// Get formatted duration
  String get formattedDuration {
    final apt = appointment.value;
    if (apt == null) return '';

    final minutes = apt.totalDuration;
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remaining = minutes % 60;
      if (remaining > 0) {
        return '${hours}h ${remaining}min';
      }
      return '${hours}h';
    }
    return '${minutes}min';
  }

  /// Update appointment status
  Future<void> updateStatus(AppointmentStatus newStatus) async {
    final apt = appointment.value;
    if (apt == null) return;

    isSaving.value = true;
    try {
      final response = await _appointmentService.updateAppointmentStatus(
        apt.id,
        newStatus,
      );
      if (response.isSuccess) {
        appointment.value = apt.copyWith(status: newStatus);
        Get.snackbar('Sucesso', 'Status atualizado');
      } else {
        Get.snackbar('Erro', response.error ?? 'Falha ao atualizar');
      }
    } finally {
      isSaving.value = false;
    }
  }

  /// Cancel appointment
  Future<void> cancelAppointment({String? reason}) async {
    final apt = appointment.value;
    if (apt == null) return;

    isSaving.value = true;
    try {
      final response = await _appointmentService.cancelAppointment(
        apt.id,
        reason: reason,
      );
      if (response.isSuccess) {
        appointment.value = apt.copyWith(
          status: AppointmentStatus.cancelled,
          cancellationReason: reason,
        );
        Get.snackbar('Sucesso', 'Agendamento cancelado');
      } else {
        Get.snackbar('Erro', response.error ?? 'Falha ao cancelar');
      }
    } finally {
      isSaving.value = false;
    }
  }

  /// Send email to client
  void sendEmail() {
    final apt = appointment.value;
    if (apt?.clientEmail == null) {
      Get.snackbar('Aviso', 'Cliente não possui email cadastrado');
      return;
    }
    // TODO: Implement email functionality
    Get.snackbar('Info', 'Funcionalidade em desenvolvimento');
  }

  /// Navigate to add service
  Future<void> addService() async {
    final result = await Get.toNamed(
      Routes.serviceSelection,
      arguments: {
        'selectedServiceIds': appointmentServices.map((s) => s.id).toList(),
      },
    );
    if (result != null && result is List<ServiceModel>) {
      for (var service in result) {
        appointmentServices.add(
          AppointmentServiceItem(
            id: service.id,
            name: service.name,
            price: service.price,
            duration: service.duration,
            startTime: "00:00",
            endTime: "00:00",
            employee: null,
          ),
        );
      }
    }
  }

  /// Checkout appointment
  void checkout() {
    Get.toNamed(Routes.discount, arguments: {'appointment': appointment.value});
  }
}

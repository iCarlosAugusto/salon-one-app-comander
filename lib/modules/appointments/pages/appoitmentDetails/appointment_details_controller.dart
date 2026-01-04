import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:salon_one_comander/data/models/service_model.dart';
import 'package:salon_one_comander/data/services/checkout_service.dart';
import 'package:salon_one_comander/shared/routes/app_routes.dart';
import '../../../../data/models/appointment_model.dart';
import '../../../../data/models/appointment_service_item.dart';
import '../../../../data/services/appointment_service.dart';

/// Controller for appointment details page
class AppointmentDetailsController extends GetxController {
  final _appointmentService = Get.find<AppointmentService>();
  final _checkoutService = Get.find<CheckoutService>();

  // Loading states
  final isLoading = false.obs;
  final isSaving = false.obs;

  // Local appointment data (before checkout starts)
  final _appointment = Rxn<AppointmentModel>();
  final _services = <AppointmentServiceItem>[].obs;
  final _newServicesAdded = <AppointmentServiceItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  /// Load appointment from arguments and fetch services
  void _loadInitialData() {
    final args = Get.arguments;
    if (args != null && args['appointment'] != null) {
      _appointment.value = args['appointment'] as AppointmentModel;
      _loadAppointmentServices();
    }
  }

  /// Load services for this appointment from API
  Future<void> _loadAppointmentServices() async {
    final apt = _appointment.value;
    if (apt == null) return;

    isLoading.value = true;
    try {
      final response = await _appointmentService.getAppointmentServices(apt.id);
      if (response.isSuccess && response.data != null) {
        _services.addAll(response.data!);
        debugPrint('Loaded ${_services.length} services for appointment');
      } else {
        debugPrint('Failed to load services: ${response.error}');
      }
    } catch (e) {
      debugPrint('Error loading appointment services: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Get appointment model
  AppointmentModel? get appointment => _appointment.value;

  /// Get all services (original + new)
  List<AppointmentServiceItem> get allServices => [
    ..._services,
    ..._newServicesAdded,
  ];

  /// Get total price of all services
  double get totalPriceServices {
    return allServices.fold(0.0, (sum, service) => sum + service.price);
  }

  /// Get formatted date for display (e.g., "domingo 21 dez")
  String get formattedDate {
    final apt = _appointment.value;
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
    final apt = _appointment.value;
    if (apt == null) return '';
    return apt.startTime.substring(0, 5); // HH:MM
  }

  /// Get formatted duration
  String get formattedDuration {
    final apt = _appointment.value;
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

  /// Navigate to add service
  Future<void> addService() async {
    final result = await Get.toNamed(
      Routes.serviceSelection,
      arguments: {
        'selectedServiceIds': _newServicesAdded.map((s) => s.id).toList(),
      },
    );
    if (result != null && result is List<ServiceModel>) {
      _newServicesAdded.value = result
          .map(
            (e) => AppointmentServiceItem(
              id: e.id,
              name: e.name,
              price: e.price,
              duration: e.duration,
              startTime: "00:00",
              endTime: "00:00",
              employee: null,
            ),
          )
          .toList();
    }
  }

  /// Start checkout flow - initializes CheckoutService and navigates to discount
  void checkout() {
    final apt = _appointment.value;
    if (apt == null) return;

    // Initialize checkout in the global service
    _checkoutService.startCheckout(appointment: apt, services: allServices);

    // Navigate to discount page (no arguments needed)
    Get.toNamed(Routes.discount);
  }
}

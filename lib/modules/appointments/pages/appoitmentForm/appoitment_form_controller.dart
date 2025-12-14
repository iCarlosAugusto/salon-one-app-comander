import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:salon_one_comander/data/models/create_appointment_dto.dart';
import 'package:salon_one_comander/data/services/appointment_service.dart';
import 'package:salon_one_comander/data/services/session_service.dart';
import '../../../../data/models/service_model.dart';
import '../../../../shared/routes/app_routes.dart';

class AppoitmentFormController extends GetxController {
  //Get current user logged in
  final sessionService = Get.find<SessionService>();

  //Services
  final appointmentService = Get.find<AppointmentService>();

  // Text controllers
  final customerNameController = TextEditingController();
  final customerPhoneController = TextEditingController();

  // Form state
  final selectedTime = Rxn<String>();
  final isLoading = false.obs;

  // Selected services
  final selectedServices = <ServiceModel>[].obs;

  // Validation errors
  final customerNameError = Rxn<String>();
  final customerPhoneError = Rxn<String>();
  final startTimeError = Rxn<String>();
  final servicesError = Rxn<String>();

  // Computed: total price
  double get totalPrice => selectedServices.fold(0, (sum, s) => sum + s.price);

  // Computed: total duration
  int get totalDuration =>
      selectedServices.fold(0, (sum, s) => sum + s.duration);

  // Available time slots
  final availableTimes = <String>[].obs;

  @override
  void onClose() {
    customerNameController.dispose();
    customerPhoneController.dispose();
    super.onClose();
  }

  void selectTime(String time) {
    selectedTime.value = time;
    startTimeError.value = null;
  }

  /// Open service selection screen
  Future<void> openServiceSelection(DateTime date) async {
    final result = await Get.toNamed(
      Routes.serviceSelection,
      arguments: {
        'selectedServiceIds': selectedServices.map((s) => s.id).toList(),
      },
    );

    if (result != null && result is List<ServiceModel>) {
      selectedServices.value = result;
      servicesError.value = null;
      fetchTimeSlots(date);
    }
  }

  Future<void> fetchTimeSlots(DateTime date) async {
    final userSession = await sessionService.getUserData();
    final dateFormatted = DateFormat('yyyy-MM-dd').format(date);

    final serviceIds = selectedServices.map((s) => s.id).toList();

    final result = await appointmentService.getEmployeeAvailableSlots(
      employeeIds: [userSession!.id],
      serviceIds: serviceIds,
      date: dateFormatted,
    );

    if (result.data != null && result.data!.isNotEmpty) {
      final employee = result.data!.first;
      availableTimes.value = employee.availableSlots;
    }
  }

  bool validate() {
    bool isValid = true;

    // Validate customer name
    if (customerNameController.text.trim().isEmpty) {
      customerNameError.value = 'Customer name is required';
      isValid = false;
    } else {
      customerNameError.value = null;
    }

    // Validate phone
    if (customerPhoneController.text.trim().isEmpty) {
      customerPhoneError.value = 'Phone number is required';
      isValid = false;
    } else {
      customerPhoneError.value = null;
    }

    // Validate services
    if (selectedServices.isEmpty) {
      servicesError.value = 'Please select at least one service';
      isValid = false;
    } else {
      servicesError.value = null;
    }

    // Validate time
    if (selectedTime.value == null) {
      startTimeError.value = 'Please select a time';
      isValid = false;
    } else {
      startTimeError.value = null;
    }

    return isValid;
  }

  Future<void> submitForm(DateTime dateSelected) async {
    if (!validate()) return;

    isLoading.value = true;

    try {
      final userSession = await sessionService.getUserData();

      // Create the appointment DTO
      final appointmentDto = CreateAppointmentDto(
        salonId: userSession!.salonId,
        services: selectedServices
            .map(
              (s) => AppointmentServiceItem(
                serviceId: s.id,
                employeeId: userSession.id,
              ),
            )
            .toList(),
        appointmentDate: DateFormat('yyyy-MM-dd').format(dateSelected),
        startTime: selectedTime.value!,
        clientName: customerNameController.text.trim(),
        clientPhone: customerPhoneController.text.trim(),
      );

      debugPrint('Submitting appointment: ${appointmentDto.toJson()}');

      // Call the API to create the appointment
      final result = await appointmentService.createAppointment(
        appointmentDto.toJson(),
      );

      if (result.data != null) {
        Get.back(result: true);
        Get.snackbar(
          'Success',
          'Appointment created successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        throw Exception(result.error ?? 'Failed to create appointment');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

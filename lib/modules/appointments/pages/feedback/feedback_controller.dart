import 'package:get/get.dart';
import 'package:salon_one_comander/data/models/appointment_model.dart';
import 'package:salon_one_comander/data/models/payment_entry_model.dart';
import 'package:salon_one_comander/data/services/checkout_service.dart';
import 'package:salon_one_comander/shared/routes/app_routes.dart';

class FeedbackController extends GetxController {
  final _checkoutService = Get.find<CheckoutService>();

  /// Get appointment model from checkout service
  AppointmentModel? get appointmentModel => _checkoutService.appointment;

  /// Get all payments from checkout service
  List<PaymentEntryModel> get payments => _checkoutService.payments;

  /// Total amount paid
  double get totalPaid => _checkoutService.paidAmount;

  /// Navigate back to appointments and clear checkout
  void goToAppointments() {
    _checkoutService.clear();
    Get.offAllNamed(Routes.appointments);
  }

  /// Start a new appointment and clear checkout
  void startNewAppointment() {
    _checkoutService.clear();
    Get.offAllNamed(Routes.appointmentForm);
  }
}

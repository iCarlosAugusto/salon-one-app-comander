import 'package:get/get.dart';
import 'package:salon_one_comander/data/models/appointment_model.dart';
import 'package:salon_one_comander/data/models/payment_entry_model.dart';
import 'package:salon_one_comander/shared/routes/app_routes.dart';

class FeedbackController extends GetxController {
  late AppointmentModel appointmentModel;
  late List<PaymentEntryModel> payments;

  @override
  void onInit() {
    super.onInit();
    appointmentModel = Get.arguments['appointment'];
    payments = List<PaymentEntryModel>.from(Get.arguments['payments'] ?? []);
  }

  double get totalPaid {
    return payments.fold(0.0, (sum, entry) => sum + entry.amount);
  }

  /// Navigate back to appointments
  void goToAppointments() {
    Get.offAllNamed(Routes.appointments);
  }

  /// Start a new appointment
  void startNewAppointment() {
    Get.offAllNamed(Routes.appointmentForm);
  }
}

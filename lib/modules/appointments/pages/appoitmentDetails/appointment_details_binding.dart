import 'package:get/get.dart';
import 'appointment_details_controller.dart';

/// Binding for appointment details page
class AppointmentDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AppointmentDetailsController());
  }
}

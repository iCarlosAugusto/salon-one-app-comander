import 'package:get/get.dart';
import 'appoitment_form_controller.dart';

/// Binding for the appointments module
class AppoitmentFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AppoitmentFormController());
  }
}

import 'package:get/get.dart';
import 'payment_type_controller.dart';

/// Binding for the payment type module
class PaymentTypeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PaymentTypeController());
  }
}

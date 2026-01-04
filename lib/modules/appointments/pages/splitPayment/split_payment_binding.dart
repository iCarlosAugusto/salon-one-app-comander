import 'package:get/get.dart';
import 'split_payment_controller.dart';

/// Binding for the split payment module
class SplitPaymentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SplitPaymentController());
  }
}

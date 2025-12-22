import 'package:get/get.dart';
import 'discount_controller.dart';

/// Binding for the appointments module
class DiscountBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DiscountController());
  }
}

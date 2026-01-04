import 'package:get/get.dart';
import 'feedback_controller.dart';

/// Binding for the feedback module
class FeedbackBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FeedbackController());
  }
}

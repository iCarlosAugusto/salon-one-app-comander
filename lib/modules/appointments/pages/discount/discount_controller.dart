import 'package:get/get_core/src/get_main.dart' show Get;
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:salon_one_comander/data/models/appointment_model.dart';

class DiscountController extends GetxController {
  final discounts = [0, 10, 15, 20, 35, 50];
  var selectedDiscount = 0.obs;

  late AppointmentModel appointmentModel;

  @override
  void onInit() {
    super.onInit();
    appointmentModel = Get.arguments['appointment'];
  }

  void handleSelectedDiscount(int discount) {
    selectedDiscount.value = discount;
  }
}

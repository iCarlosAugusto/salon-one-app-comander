import 'package:get/get.dart';
import 'package:salon_one_comander/data/services/checkout_service.dart';

class DiscountController extends GetxController {
  final _checkoutService = Get.find<CheckoutService>();

  final discounts = [0, 10, 15, 20, 35, 50];
  var selectedDiscount = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    // Load current discount from checkout service
    selectedDiscount.value = _checkoutService.discount;
  }

  /// Get total price from checkout service
  double get totalPrice => _checkoutService.totalPrice;

  /// Get total price without discount (for display)
  double get totalPriceWithoutDiscount {
    final checkout = _checkoutService.checkout.value;
    if (checkout == null) return 0;
    return [
      ...checkout.services,
      ...checkout.newServicesAdded,
    ].fold(0.0, (sum, service) => sum + service.price);
  }

  /// Handle discount selection
  void handleSelectedDiscount(double discount) {
    selectedDiscount.value = discount;
    _checkoutService.setDiscount(discount);
  }
}

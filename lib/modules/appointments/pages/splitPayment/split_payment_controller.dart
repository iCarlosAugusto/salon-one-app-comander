import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_one_comander/data/models/payment_entry_model.dart';
import 'package:salon_one_comander/data/services/appointment_service.dart';
import 'package:salon_one_comander/data/services/checkout_service.dart';
import 'package:salon_one_comander/shared/routes/app_routes.dart';

class SplitPaymentController extends GetxController {
  final _checkoutService = Get.find<CheckoutService>();
  final _appointmentService = Get.find<AppointmentService>();
  final isLoading = false.obs;

  /// Get total price after discount
  double get finalPrice => _checkoutService.totalPrice;

  /// Get discount percentage
  int get selectedDiscount => _checkoutService.discount.toInt();

  /// Get all payments
  List<PaymentEntryModel> get payments => _checkoutService.payments;

  /// Amount already paid
  double get paidAmount => _checkoutService.paidAmount;

  /// Remaining amount to pay
  double get remainingAmount => _checkoutService.remainingAmount;

  /// Check if fully paid
  bool get isFullyPaid => _checkoutService.isFullyPaid;

  /// Remove a payment entry by index
  void removePayment(int index) {
    _checkoutService.removePayment(index);
  }

  /// Save as partial payment
  void saveAsPartial() {
    _checkoutService.clear();
    Get.snackbar('Salvo', 'Pagamento parcial salvo');
    Get.offAllNamed(Routes.appointments);
  }

  /// Complete payment if fully paid - calls checkout API
  Future<void> completePayment() async {
    if (!isFullyPaid) {
      Get.snackbar(
        'Atenção',
        'Ainda há valor pendente para pagamento',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;

    try {
      final paymentsJson = payments.map((p) => p.toApiJson()).toList();
      print('Checkout payments: $paymentsJson');

      // TODO: Implement API call
      // final response = await _appointmentService.checkoutAppointment(
      //   _checkoutService.appointment!.id,
      //   payments: paymentsJson,
      // );

      // Navigate to feedback page
      Get.offNamedUntil(
        Routes.paymentFeedback,
        (route) => route.settings.name == Routes.appointments,
      );
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao processar pagamento: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

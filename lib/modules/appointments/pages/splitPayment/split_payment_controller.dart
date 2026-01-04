import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_one_comander/data/models/appoinment_checkout_model.dart';
import 'package:salon_one_comander/data/models/payment_entry_model.dart';
import 'package:salon_one_comander/data/services/appointment_service.dart';
import 'package:salon_one_comander/shared/routes/app_routes.dart';

class SplitPaymentController extends GetxController {
  late AppoimentCheckoutModel appointmentCheckout;
  late int selectedDiscount;
  late double finalPrice;

  final AppointmentService _appointmentService = Get.find<AppointmentService>();
  final isLoading = false.obs;

  /// List of payment entries
  final payments = <PaymentEntryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    appointmentCheckout = Get.arguments['appointmentCheckout'];
    selectedDiscount = appointmentCheckout.discount.toInt();
    finalPrice = appointmentCheckout.totalPriceServicesDiscount;

    payments.value = List<PaymentEntryModel>.from(appointmentCheckout.payments);
  }

  /// Amount already paid
  double get paidAmount {
    return payments.fold(0.0, (sum, entry) => sum + entry.amount);
  }

  /// Remaining amount to pay
  double get remainingAmount {
    return finalPrice - paidAmount;
  }

  /// Remove a payment entry by index
  void removePayment(int index) {
    if (index >= 0 && index < payments.length) {
      payments.removeAt(index);
    }
  }

  /// Save as partial payment
  void saveAsPartial() {
    Get.snackbar('Salvo', 'Pagamento parcial salvo');
    // Navigate back to appointment details or home
    Get.offAllNamed(Routes.appointments);
  }

  /// Complete payment if fully paid - calls checkout API
  Future<void> completePayment() async {
    if (remainingAmount > 0) {
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

      // final response = await _appointmentService.checkoutAppointment(
      //   appointmentModel.id,
      //   payments: paymentsJson,
      // );

      // if (response.isSuccess && response.data != null) {
      //   // Navigate to feedback page with updated appointment
      //   Get.offNamedUntil(
      //     Routes.paymentFeedback,
      //     (route) => route.settings.name == Routes.appointments,
      //     arguments: {
      //       'appointment': response.data,
      //       'payments': payments.toList(),
      //     },
      //   );
      // } else {
      //   Get.snackbar(
      //     'Erro',
      //     response.error ?? 'Erro ao processar pagamento',
      //     snackPosition: SnackPosition.BOTTOM,
      //     backgroundColor: Colors.red,
      //     colorText: Colors.white,
      //   );
      // }
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

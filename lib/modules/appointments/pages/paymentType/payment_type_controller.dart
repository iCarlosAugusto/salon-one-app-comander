import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_one_comander/data/models/appoinment_checkout_model.dart';
import 'package:salon_one_comander/data/models/payment_entry_model.dart';
import 'package:salon_one_comander/data/services/appointment_service.dart';
import 'package:salon_one_comander/shared/routes/app_routes.dart';

class PaymentTypeController extends GetxController {
  late AppoimentCheckoutModel appointmentCheckout;

  final AppointmentService _appointmentService = Get.find<AppointmentService>();
  final isLoading = false.obs;

  /// List of payment entries (for split payments)
  final payments = <PaymentEntryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    appointmentCheckout = Get.arguments['appointmentCheckout'];
    appointmentCheckout.payments = [];

    payments.value = List<PaymentEntryModel>.from(appointmentCheckout.payments);
  }

  /// Total price after discount
  double get finalPrice {
    return appointmentCheckout.totalPriceServicesDiscount;
  }

  /// Amount already paid
  double get paidAmount {
    return payments.fold(0.0, (sum, entry) => sum + entry.amount);
  }

  /// Remaining amount to pay
  double get remainingAmount {
    return finalPrice - paidAmount;
  }

  /// Add a payment entry
  Future<void> addPayment(PaymentType type, double amount) async {
    payments.add(PaymentEntryModel(type: type, amount: amount));

    // Check if fully paid
    if (remainingAmount <= 0) {
      // Call checkout API and navigate to feedback page
      await _checkout();
    } else {
      appointmentCheckout.addPayment(
        PaymentEntryModel(type: type, amount: amount),
      );

      // Navigate to split payment page
      Get.toNamed(
        Routes.splitPayment,
        arguments: {
          'appointmentCheckout': appointmentCheckout,
          'payments': payments.toList(),
          'finalPrice': finalPrice,
        },
      );
    }
  }

  /// Checkout the appointment via API
  Future<void> _checkout() async {
    // isLoading.value = true;

    // try {
    //   final paymentsJson = payments.map((p) => p.toApiJson()).toList();
    //   print(paymentsJson);
    //   final response = await _appointmentService.checkoutAppointment(
    //     appointmentModel.id,
    //     payments: paymentsJson,
    //     services: appoimentCheckout.value?.services,
    //   );

    //   if (response.isSuccess && response.data != null) {
    //     // Navigate to feedback page with updated appointment
    //     Get.offNamedUntil(
    //       Routes.paymentFeedback,
    //       (route) => route.settings.name == Routes.appointments,
    //       arguments: {
    //         'appointment': response.data,
    //         'payments': payments.toList(),
    //       },
    //     );
    //   } else {
    //     Get.snackbar(
    //       'Erro',
    //       response.error ?? 'Erro ao processar pagamento',
    //       snackPosition: SnackPosition.BOTTOM,
    //       backgroundColor: Colors.red,
    //       colorText: Colors.white,
    //     );
    //   }
    // } catch (e) {
    //   Get.snackbar(
    //     'Erro',
    //     'Erro ao processar pagamento: $e',
    //     snackPosition: SnackPosition.BOTTOM,
    //     backgroundColor: Colors.red,
    //     colorText: Colors.white,
    //   );
    // } finally {
    //   isLoading.value = false;
    // }
  }

  /// Remove a payment entry by index
  void removePayment(int index) {
    if (index >= 0 && index < payments.length) {
      payments.removeAt(index);
    }
  }

  /// Show dialog to enter payment amount
  Future<void> showPaymentAmountDialog(
    BuildContext context,
    PaymentType type,
  ) async {
    final textController = TextEditingController(
      text: remainingAmount.toStringAsFixed(2),
    );

    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getPaymentTypeName(type)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Valor a pagar: R\$ ${remainingAmount.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: textController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Valor',
                prefixText: 'R\$ ',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(
                textController.text.replaceAll(',', '.'),
              );
              if (amount != null && amount > 0) {
                Navigator.pop(context, amount);
              }
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (result != null) {
      await addPayment(type, result);
    }
  }

  String _getPaymentTypeName(PaymentType type) {
    switch (type) {
      case PaymentType.dinheiro:
        return 'Dinheiro';
      case PaymentType.credito:
        return 'Crédito';
      case PaymentType.debito:
        return 'Débito';
    }
  }

  void saveAsNotPaid() {
    Get.snackbar('Salvo', 'Agendamento salvo como não pago');
    Get.back();
  }
}

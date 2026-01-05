import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_one_comander/data/models/payment_entry_model.dart';
import 'package:salon_one_comander/data/services/appointment_service.dart';
import 'package:salon_one_comander/data/services/checkout_service.dart';
import 'package:salon_one_comander/shared/routes/app_routes.dart';

class PaymentTypeController extends GetxController {
  final _checkoutService = Get.find<CheckoutService>();
  final _appointmentService = Get.find<AppointmentService>();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Clear any existing payments when entering payment type screen
    // Defer to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkoutService.clearPayments();
    });
  }

  /// Total price after discount
  double get finalPrice => _checkoutService.totalPrice;

  /// Amount already paid
  double get paidAmount => _checkoutService.paidAmount;

  /// Remaining amount to pay
  double get remainingAmount => _checkoutService.remainingAmount;

  /// Get all payments
  List<PaymentEntryModel> get payments => _checkoutService.payments;

  /// Add a payment entry
  Future<void> addPayment(PaymentType type, double amount) async {
    _checkoutService.addPayment(PaymentEntryModel(type: type, amount: amount));

    // Check if fully paid
    if (_checkoutService.isFullyPaid) {
      // Call checkout API and navigate to feedback page
      await _checkout();
    } else {
      // Navigate to split payment page (no arguments needed)
      Get.toNamed(Routes.splitPayment);
    }
  }

  /// Checkout the appointment via API
  Future<void> _checkout() async {
    isLoading.value = true;

    try {
      final appointmentId = _checkoutService.appointment?.id;
      if (appointmentId == null) {
        throw Exception('Appointment not found');
      }

      // Format payments for API
      final paymentsJson = payments.map((p) => p.toApiJson()).toList();

      // Format extra services for API (using current employee's ID as fallback)
      // TODO: Get current employee ID from session/auth service
      final currentEmployeeId = _checkoutService.appointment?.employeeId ?? '';
      final extraServicesJson = _checkoutService.getExtraServicesJson(
        currentEmployeeId,
      );

      print('Checkout - appointmentId: $appointmentId');
      print('Checkout - payments: $paymentsJson');
      print('Checkout - extraServices: $extraServicesJson');

      // Call checkout API
      await _appointmentService.checkoutAppointment(
        appointmentId: appointmentId,
        payments: paymentsJson,
        extraServices: extraServicesJson.isNotEmpty ? extraServicesJson : null,
      );

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

  /// Remove a payment entry by index
  void removePayment(int index) {
    _checkoutService.removePayment(index);
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
    _checkoutService.clear();
    Get.snackbar('Salvo', 'Agendamento salvo como não pago');
    Get.back();
  }
}

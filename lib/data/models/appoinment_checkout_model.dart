import 'package:salon_one_comander/data/models/appointment_model.dart';
import 'package:salon_one_comander/data/models/appointment_service_item.dart';
import 'package:salon_one_comander/data/models/payment_entry_model.dart';

class AppoimentCheckoutModel {
  final AppointmentModel appointmentModel;
  List<PaymentEntryModel> payments;
  double _discount;
  final List<AppointmentServiceItem> services;
  List<AppointmentServiceItem> newServicesAdded;

  AppoimentCheckoutModel({
    required this.appointmentModel,
    required this.services,
    double discount = 0,
    List<PaymentEntryModel>? payments,
    List<AppointmentServiceItem>? newServicesAdded,
  }) : _discount = discount,
       payments = payments ?? [],
       newServicesAdded = newServicesAdded ?? [];

  double get totalPricePayments {
    if (payments.isEmpty) return 0;
    return payments.fold(0, (sum, entry) => sum + entry.amount);
  }

  /// Add a payment entry. If a payment with the same type exists, merge the amounts.
  void addPayment(PaymentEntryModel payment) {
    final existingIndex = payments.indexWhere((p) => p.type == payment.type);

    if (existingIndex != -1) {
      // Merge with existing payment of same type
      final existing = payments[existingIndex];
      payments[existingIndex] = PaymentEntryModel(
        type: payment.type,
        amount: existing.amount + payment.amount,
      );
    } else {
      // Add new payment type
      payments.add(payment);
    }
  }

  void removePaymentByIndex(int index) {
    payments.removeAt(index);
  }

  double get discount => _discount;

  set discount(double value) {
    _discount = value;
  }

  double get totalPriceServices {
    if (services.isEmpty && newServicesAdded.isEmpty) return 0;
    return [
          ...services,
          ...newServicesAdded,
        ].fold(0.0, (sum, service) => sum + service.price) *
        (1 - discount / 100);
  }

  double get totalPriceServicesDiscount {
    if (services.isEmpty && newServicesAdded.isEmpty) return 0;
    final subtotal = [
      ...services,
      ...newServicesAdded,
    ].fold(0.0, (sum, service) => sum + service.price);
    print(
      'DEBUG: subtotal=$subtotal, discount=$_discount, result=${subtotal * (1 - _discount / 100)}',
    );
    return subtotal * (1 - _discount / 100);
  }

  double get totalPriceNewServices {
    if (newServicesAdded.isEmpty) return 0;
    return newServicesAdded.fold(0, (sum, service) => sum + service.price);
  }
}

import 'package:salon_one_comander/data/models/appointment_model.dart';
import 'package:salon_one_comander/data/models/appointment_service_item.dart';
import 'package:salon_one_comander/data/models/payment_entry_model.dart';

class AppoimentCheckoutModel {
  final AppointmentModel appointmentModel;
  final List<PaymentEntryModel> payments;
  double _discount;
  final List<AppointmentServiceItem> services;
  List<AppointmentServiceItem> newServicesAdded;

  AppoimentCheckoutModel({
    required this.appointmentModel,
    required this.services,
    double discount = 0,
    this.payments = const [],
    this.newServicesAdded = const [],
  }) : _discount = discount;

  double get totalPricePayments {
    if (payments.isEmpty) return 0;
    return payments.fold(0, (sum, entry) => sum + entry.amount);
  }

  addPayment(PaymentEntryModel payment) {
    payments.add(payment);
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

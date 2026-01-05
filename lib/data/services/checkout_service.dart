import 'package:get/get.dart';
import 'package:salon_one_comander/data/models/appoinment_checkout_model.dart';
import 'package:salon_one_comander/data/models/appointment_model.dart';
import 'package:salon_one_comander/data/models/appointment_service_item.dart';
import 'package:salon_one_comander/data/models/payment_entry_model.dart';

/// Global service to manage checkout state across all checkout-related screens.
/// This provides a single source of truth for the checkout flow.
class CheckoutService extends GetxService {
  /// The current checkout model being processed
  final checkout = Rxn<AppoimentCheckoutModel>();

  /// Whether checkout is in progress
  bool get isCheckoutActive => checkout.value != null;

  /// Start a new checkout flow with the given appointment and services
  void startCheckout({
    required AppointmentModel appointment,
    required List<AppointmentServiceItem> services,
  }) {
    checkout.value = AppoimentCheckoutModel(
      appointmentModel: appointment,
      services: services,
    );
  }

  /// Set discount percentage
  void setDiscount(double discount) {
    checkout.value?.discount = discount;
    checkout.refresh();
  }

  /// Get current discount
  double get discount => checkout.value?.discount ?? 0;

  /// Add a payment (merges with existing if same type)
  void addPayment(PaymentEntryModel payment) {
    checkout.value?.addPayment(payment);
    checkout.refresh();
  }

  /// Remove payment by index
  void removePayment(int index) {
    checkout.value?.removePaymentByIndex(index);
    checkout.refresh();
  }

  /// Clear all payments
  void clearPayments() {
    checkout.value?.payments = [];
    checkout.refresh();
  }

  /// Get all payments
  List<PaymentEntryModel> get payments => checkout.value?.payments ?? [];

  /// Get total price after discount
  double get totalPrice => checkout.value?.totalPriceServicesDiscount ?? 0;

  /// Get paid amount
  double get paidAmount => checkout.value?.totalPricePayments ?? 0;

  /// Get remaining amount
  double get remainingAmount => totalPrice - paidAmount;

  /// Check if fully paid
  bool get isFullyPaid => remainingAmount <= 0;

  /// Get appointment model
  AppointmentModel? get appointment => checkout.value?.appointmentModel;

  /// Add a new service
  void addService(AppointmentServiceItem service) {
    checkout.value?.newServicesAdded.add(service);
    checkout.refresh();
  }

  /// Get new services added (not from original appointment)
  List<AppointmentServiceItem> get newServicesAdded =>
      checkout.value?.newServicesAdded ?? [];

  /// Get extra services formatted for API
  /// Format: [{serviceId: "...", employeeId: "..."}]
  List<Map<String, dynamic>> getExtraServicesJson(String currentEmployeeId) {
    return newServicesAdded.map((service) {
      return {
        'serviceId': service.id,
        'employeeId': service.employee?.id ?? currentEmployeeId,
      };
    }).toList();
  }

  /// Clear checkout and reset state
  void clear() {
    checkout.value = null;
  }
}

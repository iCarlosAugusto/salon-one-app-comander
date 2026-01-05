import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

enum PaymentType { dinheiro, credito, debito }

class PaymentEntryModel {
  final PaymentType type;
  final double amount;

  PaymentEntryModel({required this.type, required this.amount});

  String get typeName {
    switch (type) {
      case PaymentType.dinheiro:
        return 'Dinheiro';
      case PaymentType.credito:
        return 'Crédito';
      case PaymentType.debito:
        return 'Débito';
    }
  }

  /// Get API method name (CASH, CREDIT_CARD, DEBIT_CARD)
  String get apiMethod {
    switch (type) {
      case PaymentType.dinheiro:
        return 'CASH';
      case PaymentType.credito:
        return 'CREDIT_CARD';
      case PaymentType.debito:
        return 'DEBIT_CARD';
    }
  }

  IconData get icon {
    switch (type) {
      case PaymentType.dinheiro:
        return Icons.payments_outlined;
      case PaymentType.credito:
        return Icons.credit_card;
      case PaymentType.debito:
        return Icons.credit_card_outlined;
    }
  }

  /// Convert to API format
  Map<String, dynamic> toApiJson() {
    return {'method': apiMethod, 'amount': amount};
  }
}

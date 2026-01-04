import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_one_comander/data/models/payment_entry_model.dart';
import 'payment_type_controller.dart';

class PaymentTypeView extends GetView<PaymentTypeController> {
  const PaymentTypeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Selecione o pagamento"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Get.back(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _buildPaymentOption(
              context,
              PaymentType.dinheiro,
              Icons.payments_outlined,
              'Dinheiro',
            ),
            _buildPaymentOption(
              context,
              PaymentType.credito,
              Icons.credit_card,
              'Crédito',
            ),
            _buildPaymentOption(
              context,
              PaymentType.debito,
              Icons.credit_card_outlined,
              'Débito',
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('A pagar', style: TextStyle(fontSize: 16)),
                  Obx(
                    () => Text(
                      'R\$ ${controller.remainingAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        if (value == 'not_paid') {
                          controller.saveAsNotPaid();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'not_paid',
                          child: Text('Salvar como não pago'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: controller.saveAsNotPaid,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Salvar — não pago',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
    BuildContext context,
    PaymentType type,
    IconData icon,
    String label,
  ) {
    return Obx(() {
      final isSelected = controller.payments.any((p) => p.type == type);
      return InkWell(
        onTap: () => controller.showPaymentAmountDialog(context, type),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? Colors.green : Colors.grey.shade600,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isSelected
                ? Colors.green.withOpacity(0.1)
                : Colors.transparent,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: isSelected ? Colors.green : Colors.grey.shade400,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.green : Colors.grey.shade300,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_one_comander/data/models/payment_entry_model.dart';
import 'payment_type_controller.dart';

class PaymentTypeView extends GetView<PaymentTypeController> {
  const PaymentTypeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Forma de pagamento"),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Price summary
              _buildPriceSummary(context, theme),
              const SizedBox(height: 24),

              // Section title
              Text(
                'Selecione a forma de pagamento',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              // Payment options grid
              Obx(() {
                final payments = controller.payments.toList();
                return _buildPaymentGrid(context, theme, payments);
              }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context, theme),
    );
  }

  /// Price summary showing remaining amount
  Widget _buildPriceSummary(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Obx(() {
        final totalPrice = controller.finalPrice;
        final remainingAmount = controller.remainingAmount;
        final paidAmount = controller.paidAmount;
        final hasPaid = paidAmount > 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Valor restante',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (hasPaid)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'R\$ ${paidAmount.toStringAsFixed(2)} pago',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'R\$ ${remainingAmount.toStringAsFixed(2)}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'de R\$ ${totalPrice.toStringAsFixed(2)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  /// Payment options grid
  Widget _buildPaymentGrid(
    BuildContext context,
    ThemeData theme,
    List<PaymentEntryModel> payments,
  ) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.0,
      children: [
        _buildPaymentOption(
          context,
          theme,
          type: PaymentType.dinheiro,
          icon: Icons.payments_outlined,
          label: 'Dinheiro',
          isSelected: payments.any((p) => p.type == PaymentType.dinheiro),
        ),
        _buildPaymentOption(
          context,
          theme,
          type: PaymentType.credito,
          icon: Icons.credit_card,
          label: 'Crédito',
          isSelected: payments.any((p) => p.type == PaymentType.credito),
        ),
        _buildPaymentOption(
          context,
          theme,
          type: PaymentType.debito,
          icon: Icons.credit_card_outlined,
          label: 'Débito',
          isSelected: payments.any((p) => p.type == PaymentType.debito),
        ),
      ],
    );
  }

  /// Individual payment option item
  Widget _buildPaymentOption(
    BuildContext context,
    ThemeData theme, {
    required PaymentType type,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return Material(
      color: isSelected
          ? theme.colorScheme.primary
          : theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => controller.showPaymentAmountDialog(context, type),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bottom navigation bar
  Widget _buildBottomBar(BuildContext context, ThemeData theme) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1)),
          ),
        ),
        child: Row(
          children: [
            // More options button
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_horiz,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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

            // Main action button
            Expanded(
              child: OutlinedButton(
                onPressed: controller.saveAsNotPaid,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Salvar — não pago',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

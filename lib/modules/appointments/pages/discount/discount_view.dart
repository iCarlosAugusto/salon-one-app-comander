import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_one_comander/modules/appointments/pages/discount/discount_controller.dart';
import 'package:salon_one_comander/shared/routes/app_routes.dart';

class DiscountView extends GetView<DiscountController> {
  const DiscountView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Desconto"),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Price summary card
              _buildPriceSummary(context, theme),
              const SizedBox(height: 24),

              // Section title
              Text(
                'Selecione o desconto',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              // Discount grid
              Expanded(
                child: Obx(() {
                  // Access observable directly in Obx scope
                  final selectedValue = controller.selectedDiscount.value;
                  return _buildDiscountGrid(context, theme, selectedValue);
                }),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context, theme),
    );
  }

  /// Price summary card showing original and discounted price
  Widget _buildPriceSummary(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Obx(() {
        final totalPrice =
            controller.appoimentCheckout.value?.totalPriceServices ?? 0;
        final discount = controller.selectedDiscount.value;
        final discountedPrice = totalPrice * (1 - discount / 100);
        final hasDiscount = discount > 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Valor a pagar',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Discounted price (main)
                Text(
                  'R\$ ${discountedPrice.toStringAsFixed(2)}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 12),
                // Original price (crossed out)
                if (hasDiscount)
                  Text(
                    'R\$ ${totalPrice.toStringAsFixed(2)}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
              ],
            ),
            if (hasDiscount) ...[
              const SizedBox(height: 8),
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
                  '${discount.toInt()}% de desconto',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        );
      }),
    );
  }

  /// Discount selection grid
  Widget _buildDiscountGrid(
    BuildContext context,
    ThemeData theme,
    double selectedValue,
  ) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: controller.discounts.length,
      itemBuilder: (context, index) {
        final discount = controller.discounts[index];
        final isSelected = discount == selectedValue;

        return _buildDiscountItem(
          context,
          theme,
          discount: discount,
          isSelected: isSelected,
          onTap: () => controller.handleSelectedDiscount(discount.toDouble()),
        );
      },
    );
  }

  /// Individual discount option item
  Widget _buildDiscountItem(
    BuildContext context,
    ThemeData theme, {
    required int discount,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected
          ? theme.colorScheme.primary
          : theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
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
              Text(
                discount == 0 ? '0%' : '$discount%',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                ),
              ),
              if (discount == 0)
                Text(
                  'Sem desconto',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.onPrimary.withOpacity(0.8)
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bottom navigation bar with confirm button
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
        child: FilledButton(
          onPressed: () {
            Get.toNamed(
              Routes.paymentType,
              arguments: {
                "appointmentCheckout": controller.appoimentCheckout.value,
              },
            );
          },
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Confirmar',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

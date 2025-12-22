import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_one_comander/modules/appointments/pages/discount/discount_controller.dart';

class DiscountView extends GetView<DiscountController> {
  const DiscountView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Desconto")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("A pagar"),
                Obx(
                  () => Text(
                    "${controller.appointmentModel.totalPrice * (1 - controller.selectedDiscount.value / 100)}",
                  ),
                ),
              ],
            ),
            Obx(
              () => Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  children: List.generate(controller.discounts.length, (index) {
                    bool isSelectedDiscount =
                        controller.discounts[index] ==
                        controller.selectedDiscount.value;
                    return Container(
                      margin: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelectedDiscount ? Colors.blue : Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: InkWell(
                        onTap: () {
                          controller.handleSelectedDiscount(
                            controller.discounts[index],
                          );
                        },
                        child: Center(
                          child: Text(
                            controller.discounts[index] == 0
                                ? 'Sem desconto'
                                : '${controller.discounts[index]}%',
                            style: TextTheme.of(context).headlineSmall
                                ?.copyWith(
                                  color: isSelectedDiscount
                                      ? Colors.blue
                                      : Colors.black,
                                ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: ElevatedButton(
          onPressed: () {
            Get.back();
          },
          child: Text("Confirmar"),
        ),
      ),
    );
  }
}

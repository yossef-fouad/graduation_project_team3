import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';
import '../controllers/order_controller.dart';
import '../controllers/menu_controller.dart';

class SubmitOrderBar extends StatelessWidget {
  final OrderController orderC;
  final MenuController menuC;

  const SubmitOrderBar({super.key, required this.orderC, required this.menuC});

  void _showSubmitDialog(BuildContext context) {
    if (orderC.cart.isEmpty) {
      orderC.submitOrder('');
      return;
    }
    final nameCtl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm the order'),
        content: TextField(
          controller: nameCtl,
          decoration: const InputDecoration(
            labelText: 'اسم الزبون / رقم الطاولة (اختياري)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('cancellation')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await orderC.submitOrder(nameCtl.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Send to the chef'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5, spreadRadius: 1)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total:', style: TextStyle(color: Colors.grey.shade700)),
              Text('${orderC.total.toStringAsFixed(2)} \$',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: orderC.cart.isEmpty ? null : () => _showSubmitDialog(context),
            icon: const Icon(Icons.send),
            label: Obx(() => Text('Submit the request(${orderC.itemCount})')),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          )
        ],
      ),
    ));
  }
}

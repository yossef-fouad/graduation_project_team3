import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:order_pad/models/order_model.dart';
import 'package:order_pad/screens/04_order_history/order_history_service.dart';
import 'package:order_pad/screens/06_feedback/feedback_screen.dart';
import 'package:order_pad/widgets/colors.dart';

class OrderHistoryController extends GetxController {
  final OrderHistoryService _service = OrderHistoryService();
  final orders = <Order>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  void fetchOrders() async {
    try {
      isLoading.value = true;
      orders.value = await _service.getCompletedOrders();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load order history: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void rateOrder(String orderId) async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      final meals = await _service.getOrderMeals(orderId);
      Get.back(); // Close loading dialog
      
      Get.to(
        () => FeedbackScreen(
          orderId: orderId,
          meals: meals,
        ),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuart,
      );
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar('Error', 'Failed to load order details: $e');
    }
  }
}

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrderHistoryController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.orders.isEmpty) {
          return const Center(child: Text('No completed orders found.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final order = controller.orders[index];
            final isDone = order.status == 'Completed';
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  'Order #${order.id.substring(0, 8)}...', // Shorten ID
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('Date: ${order.createdAt.toString().split('.')[0]}'),
                    Text('Total: \$${order.totalAmount.toStringAsFixed(2)}'),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDone ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        order.status.toUpperCase(),
                        style: TextStyle(
                          color: isDone ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                trailing: isDone
                    ? ElevatedButton(
                        onPressed: () => controller.rateOrder(order.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Rate'),
                      )
                    : null,
              ),
            );
          },
        );
      }),
    );
  }
}

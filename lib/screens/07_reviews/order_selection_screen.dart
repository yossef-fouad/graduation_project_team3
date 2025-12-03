import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:order_pad/models/order_model.dart';
import 'package:order_pad/screens/04_order_history/order_history_service.dart';
import 'package:order_pad/screens/07_reviews/order_reviews_screen.dart';
import 'package:order_pad/widgets/colors.dart';
import 'package:skeletonizer/skeletonizer.dart';

class OrderSelectionController extends GetxController {
  final OrderHistoryService _service = OrderHistoryService();
  final orders = <Order>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCompletedOrders();
  }

  void fetchCompletedOrders() async {
    try {
      isLoading.value = true;
      orders.value = await _service.getCompletedOrders();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load orders: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

class OrderSelectionScreen extends StatelessWidget {
  const OrderSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrderSelectionController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Order to View Reviews'),
        centerTitle: true,
      ),
      body: Obx(() {
        final isLoading = controller.isLoading.value && controller.orders.isEmpty;
        final list = isLoading
            ? List.generate(
                6,
                (i) => Order(
                  id: 'dummy_$i',
                  customerPhone: '0000000000',
                  createdAt: DateTime.now(),
                  totalAmount: 0.0,
                  status: 'Completed',
                ),
              )
            : controller.orders;

        if (!isLoading && controller.orders.isEmpty) {
          return const Center(child: Text('No completed orders found.'));
        }

        return Skeletonizer(
          enabled: isLoading,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = list[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    'Order #${order.id.substring(0, 8)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Date: ${order.createdAt.toString().split('.')[0]}'),
                      Text('Total: \$${order.totalAmount.toStringAsFixed(2)}'),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    if (!isLoading) {
                      Get.to(() => OrderReviewsScreen(orderId: order.id));
                    }
                  },
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

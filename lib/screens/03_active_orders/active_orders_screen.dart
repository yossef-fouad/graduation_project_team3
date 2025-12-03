import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:order_pad/screens/03_active_orders/active_orders_controller.dart';
import 'package:order_pad/screens/03_active_orders/active_orders_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:order_pad/screens/role_selection_screen.dart';

class ActiveOrdersScreen extends StatelessWidget {
  ActiveOrdersScreen({super.key});

  final ActiveOrdersController controller = Get.put(ActiveOrdersController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Orders'),
        actions: [
          IconButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('user_role');
              Get.offAll(() => const RoleSelectionScreen());
            },
            icon: const Icon(Icons.logout, color: Colors.red),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.orders.isEmpty) {
          return const Center(
            child: Text(
              'No active orders',
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: controller.orders.length,
            itemBuilder: (context, index) {
              final chefOrder = controller.orders[index];
              return OrderCard(
                chefOrder: chefOrder,
                onDone: () => controller.completeOrder(chefOrder.order.id),
                onCancel: () => controller.cancelOrder(chefOrder.order.id),
              );
            },
          ),
        );
      }),
    );
  }
}

class OrderCard extends StatelessWidget {
  final ChefOrder chefOrder;
  final VoidCallback onDone;
  final VoidCallback onCancel;

  const OrderCard({
    super.key,
    required this.chefOrder,
    required this.onDone,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedTime = DateFormat('hh:mm a').format(chefOrder.order.createdAt);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${chefOrder.order.id.substring(0, 4)}', // Short ID
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  formattedTime,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          
          // Items List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: chefOrder.items.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final item = chefOrder.items[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${item.item.quantity}x',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.mealName,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Footer / Action
          Padding(
            padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                        side: BorderSide(color: theme.colorScheme.error),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: const Icon(Icons.close),
                      label: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onDone,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ),

        ],
      ),
    );
  }
}

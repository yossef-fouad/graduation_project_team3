import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';
import '../controllers/menu_controller.dart';
import '../controllers/order_controller.dart';
import '../widgets/meal_image.dart';
import '../widgets/submit_order_bar.dart';
import '../widgets/category_filter.dart';
import 'menu_management_screen.dart';
import 'chef_orders_screen.dart';

class CustomerMenuScreen extends StatelessWidget {
  const CustomerMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final menuC = Get.put(MenuController());
    final orderC = Get.put(OrderController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu and Orders', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.manage_accounts),
            onPressed: () => Get.to(() => const MenuManagementScreen()),
            tooltip: 'Menu management',
          ),
          IconButton(
            icon: const Icon(Icons.dashboard),
            onPressed: () => Get.to(() => const ChefOrdersScreen()),
            tooltip: 'Chef control panel',
          ),
        ],
      ),
      body: Obx(() {
        if (menuC.loading.value && menuC.meals.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CategoryFilter(c: menuC, isFilteringCustomerView: true),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: menuC.meals.length,
                itemBuilder: (context, index) {
                  final meal = menuC.meals[index];
                  if (!meal.isAvailable) return const SizedBox.shrink();

                  final quantity = orderC.cart[meal.id] ?? 0;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: MealImage(url: meal.imageUrl),
                      title: Text(meal.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(meal.description ?? 'There is no description'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${meal.price.toStringAsFixed(2)} \$',
                              style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 20),
                                  onPressed: quantity > 0 ? () => orderC.removeFromCart(meal) : null,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                Obx(() => Text(
                                  '${orderC.cart[meal.id] ?? 0}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                )),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 20),
                                  onPressed: () => orderC.addToCart(meal),
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SubmitOrderBar(orderC: orderC, menuC: menuC),
          ],
        );
      }),
    );
  }
}

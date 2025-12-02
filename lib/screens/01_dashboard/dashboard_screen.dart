import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:order_pad/screens/01_dashboard/dashboard_controller.dart';
import 'package:order_pad/screens/02_new_order/home_page.dart';
import 'package:order_pad/screens/03_active_orders/active_orders_screen.dart';
import 'package:order_pad/screens/04_order_history/order_history_screen.dart';
import 'package:order_pad/widgets/colors.dart';

import '../05_menu_management/menu_management_screen.dart';
import '../06_feedback/feedback_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(DashboardController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: AppColors.primary,
              ),
              child: const Text(
                'Order Pad',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Get.back(); // Close drawer
                // Already on dashboard
              },
            ),
            ListTile(
              leading: const Icon(Icons.restaurant_menu),
              title: const Text('Active Orders (Chef)'),
              onTap: () {
                Get.back();
                Get.to(() => ActiveOrdersScreen());
              },
            ),
             ListTile(
              leading: const Icon(Icons.add_shopping_cart),
              title: const Text('New Order'),
              onTap: () {
                Get.back();
                // Navigate to New Order
                 Get.toNamed('/new_order'); // Assuming route or just use class
              },
            ),
             ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Order History'),
              onTap: () {
                Get.back();
                // Navigate to History
              },
            ),
             ListTile(
              leading: const Icon(Icons.menu_book),
              title: const Text('Menu Management'),
              onTap: () {
                Get.to(MenuManagementScreen());
                 // Navigate to Menu Management
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => c.fetchTopSellingMeals(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Top Selling Meals',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: Obx(() {
                  if (c.categories.isEmpty) return const SizedBox();
                  // Access selectedCategoryId to register dependency for Obx
                  return ListView.separated(
                    key: ValueKey(c.selectedCategoryId.value),
                    scrollDirection: Axis.horizontal,
                    itemCount: c.categories.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      if (i == 0) {
                        final isSelected = c.selectedCategoryId.value == null;
                        return ChoiceChip(
                          label: const Text('All'),
                          selected: isSelected,
                          onSelected: (_) => c.selectCategory(null),
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                        );
                      }
                      final category = c.categories[i - 1];
                      final isSelected = c.selectedCategoryId.value == category.id;
                      return ChoiceChip(
                        label: Text(category.name),
                        selected: isSelected,
                        onSelected: (_) => c.selectCategory(category.id),
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                      );
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  if (c.isLoading.value && c.topSellingMeals.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (c.topSellingMeals.isEmpty) {
                    return const Center(
                      child: Text(
                        'No sales data available yet.',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    );
                  }
                  
                  return NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (!c.isMoreLoading.value &&
                          c.hasMore &&
                          scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                        c.loadMore();
                      }
                      return false;
                    },
                    child: ListView.separated(
                      itemCount: c.topSellingMeals.length + (c.isMoreLoading.value ? 1 : 0),
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        if (i == c.topSellingMeals.length) {
                          return const Center(child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ));
                        }
                        final item = c.topSellingMeals[i];
                        
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                                image: item.meal.imageUrl != null && item.meal.imageUrl!.isNotEmpty
                                    ? DecorationImage(image: NetworkImage(item.meal.imageUrl!), fit: BoxFit.cover)
                                    : null,
                              ),
                              child: item.meal.imageUrl == null || item.meal.imageUrl!.isEmpty
                                  ? const Icon(Icons.fastfood, color: Colors.grey)
                                  : null,
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.meal.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (item.categoryName != null)
                                  Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      item.categoryName!,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            subtitle: Text(
                              '\$${item.meal.price.toStringAsFixed(2)}',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${item.count}',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                const Text(
                                  'Sold',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:order_pad/main.dart';
import 'package:order_pad/models/meal_item.dart';
import 'package:order_pad/models/order_model.dart';

class ChefOrder {
  final Order order;
  final List<ChefOrderItem> items;

  ChefOrder({required this.order, required this.items});
}

class ChefOrderItem {
  final OrderItem item;
  final String mealName;

  ChefOrderItem({required this.item, required this.mealName});
}

class ActiveOrdersService {
  Future<List<ChefOrder>> getPendingOrders() async {
    // 1. Fetch pending orders
    final ordersRes = await cloud
        .from('orders')
        .select()
        .eq('status', 'Pending')
        .order('created_at', ascending: true);
    
    final orders = (ordersRes as List).map((e) => Order.fromMap(e)).toList();

    if (orders.isEmpty) return [];

    final orderIds = orders.map((e) => e.id).toList();

    // 2. Fetch order items for these orders
    final itemsRes = await cloud
        .from('order_items')
        .select()
        .filter('order_id', 'in', orderIds);
    
    final allItems = (itemsRes as List).map((e) => OrderItem.fromMap(e)).toList();

    if (allItems.isEmpty) {
       return orders.map((o) => ChefOrder(order: o, items: [])).toList();
    }

    final mealIds = allItems.map((e) => e.mealId).toSet().toList();

    // 3. Fetch meal details to get names
    final mealsRes = await cloud
        .from('meals')
        .select()
        .filter('id', 'in', mealIds);
    
    final meals = (mealsRes as List).map((e) => MealItem.fromMap(e)).toList();
    final mealMap = {for (var m in meals) m.id: m};

    // 4. Assemble ChefOrders
    final List<ChefOrder> result = [];
    for (var order in orders) {
      final orderItems = allItems.where((i) => i.orderId == order.id).toList();
      final chefItems = orderItems.map((i) {
        final meal = mealMap[i.mealId];
        return ChefOrderItem(
          item: i,
          mealName: meal?.name ?? 'Unknown Meal',
        );
      }).toList();
      result.add(ChefOrder(order: order, items: chefItems));
    }

    return result;
  }

  Future<void> markOrderAsDone(String orderId) async {
    await cloud.from('orders').update({'status': 'Completed'}).eq('id', orderId);
  }

  Future<void> cancelOrder(String orderId) async {
    await cloud.from('orders').update({'status': 'Cancelled'}).eq('id', orderId);
  }
}

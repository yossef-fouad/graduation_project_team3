import 'package:order_pad/main.dart';
import 'package:order_pad/models/meal_item.dart';
import 'package:order_pad/models/order_model.dart';

class TopSellingMeal {
  final MealItem meal;
  final int count;

  TopSellingMeal({required this.meal, required this.count});
}

class DashboardService {
  Future<List<TopSellingMeal>> getTopSellingMeals() async {
    // 1. Fetch all order items
    // Note: In a real production app with millions of rows, this should be an RPC or View.
    // For now, we fetch client-side.
    final res = await cloud.from('order_items').select();
    final items = (res as List).map((e) => OrderItem.fromMap(e)).toList();

    // 2. Aggregate quantities by mealId
    final Map<String, int> counts = {};
    for (var item in items) {
      counts[item.mealId] = (counts[item.mealId] ?? 0) + item.quantity;
    }

    if (counts.isEmpty) return [];

    // 3. Sort by count descending and take top 5
    final sortedKeys = counts.keys.toList()
      ..sort((a, b) => counts[b]!.compareTo(counts[a]!));
    
    final topIds = sortedKeys.take(5).toList();

    // 4. Fetch meal details for these IDs
    final mealsRes = await cloud.from('meals').select().filter('id', 'in', topIds);
    final meals = (mealsRes as List).map((e) => MealItem.fromMap(e)).toList();

    // 5. Combine into result
    final List<TopSellingMeal> result = [];
    for (var id in topIds) {
      final meal = meals.firstWhere((m) => m.id == id, orElse: () => MealItem(
        id: id, 
        name: 'Unknown Meal', 
        price: 0, 
        categoryId: '', 
        isAvailable: false
      ));
      result.add(TopSellingMeal(meal: meal, count: counts[id]!));
    }

    return result;
  }
}

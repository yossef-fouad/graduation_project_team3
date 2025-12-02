import 'package:order_pad/models/meal_item.dart';
import 'package:order_pad/models/order_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderHistoryService {
  final _client = Supabase.instance.client;

  Future<List<Order>> getCompletedOrders() async {
    final res = await _client
        .from('orders')
        .select()
        .filter('status', 'in', ['Completed', 'Cancelled'])
        .order('created_at', ascending: false);
    
    return (res as List).map((e) => Order.fromMap(e)).toList();
  }

  Future<List<MealItem>> getOrderMeals(String orderId) async {
    // Fetch order items and join with meals, and then join with meal_ingredients and ingredients
    final res = await _client
        .from('order_items')
        .select('*, meals(*, meal_ingredients(*, ingredients(*)))')
        .eq('order_id', orderId);

    return (res as List).map((e) {
      final mealData = Map<String, dynamic>.from(e['meals']);
      
      // Extract ingredients from the nested structure
      if (mealData['meal_ingredients'] != null) {
        final mealIngredients = mealData['meal_ingredients'] as List;
        final ingredientNames = mealIngredients.map((mi) {
          final ingredient = mi['ingredients'];
          return ingredient['name'] as String;
        }).toList();
        mealData['ingredients'] = ingredientNames;
      }
      
      return MealItem.fromMap(mealData);
    }).toList();
  }
}

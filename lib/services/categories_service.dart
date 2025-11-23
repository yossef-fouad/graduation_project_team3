import 'package:order_pad/main.dart';
import 'package:order_pad/models/category.dart';
import 'package:order_pad/models/meal_item.dart';

class CategoriesService {
  /// Fetch all categories from the database
  static Future<List<Category>> fetchCategories() async {
    try {
      final response = await cloud
          .from('categories')
          .select()
          .order('name', ascending: true);

      return (response as List).map((json) => Category.fromMap(json)).toList();
    } catch (e) {
      print('Error fetching categories: $e');
      rethrow;
    }
  }

  /// Fetch all meals for a specific category
  static Future<List<MealItem>> fetchMealsByCategory(String categoryId) async {
    try {
      final response = await cloud
          .from('meals')
          .select()
          .eq('category_id', categoryId)
          .eq('is_available', true)
          .order('name', ascending: true);

      return (response as List).map((json) => MealItem.fromMap(json)).toList();
    } catch (e) {
      print('Error fetching meals: $e');
      rethrow;
    }
  }

  /// Fetch all available meals
  static Future<List<MealItem>> fetchAllMeals() async {
    try {
      final response = await cloud
          .from('meals')
          .select()
          .eq('is_available', true)
          .order('name', ascending: true);

      return (response as List).map((json) => MealItem.fromMap(json)).toList();
    } catch (e) {
      print('Error fetching all meals: $e');
      rethrow;
    }
  }
}

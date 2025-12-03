import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:order_pad/main.dart';
import 'package:order_pad/models/category.dart';
import 'package:order_pad/models/meal_item.dart';
import 'package:order_pad/models/ingredient.dart';
import 'package:order_pad/models/meal_ingredient.dart';


class MenuManagementService {
  // Categories
  // DATA SOURCE: Fetches all categories from the 'categories' table in Supabase.
  Future<List<Category>> getCategories() async {
    final res = await cloud.from('categories').select().order('name');
    return (res as List).map((e) => Category.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<void> addCategory(String name) async {
    await cloud.from('categories').insert({'name': name});
  }

  Future<void> updateCategory(String id, String name) async {
    await cloud.from('categories').update({'name': name}).eq('id', id);
  }

  Future<void> deleteCategory(String id) async {
    await cloud.from('categories').delete().eq('id', id);
  }

  // Meals
  // DATA SOURCE: Fetches meals from the 'meals' table in Supabase. Supports pagination and filtering by category.
  Future<List<MealItem>> getMeals({
    required int offset,
    required int limit,
    String? categoryId,
  }) async {
    final from = offset;
    final to = offset + limit - 1;
    final base = cloud.from('meals').select();
    final filtered = categoryId != null && categoryId.isNotEmpty
        ? base.eq('category_id', categoryId)
        : base;
    final res = await filtered.order('name').range(from, to);
    return (res as List).map((e) => MealItem.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<String> addMeal({
    required String name,
    required double price,
    String? description,
    String? imageUrl,
    String? categoryId,
  }) async {
    final res = await cloud.from('meals').insert({
      'name': name,
      'price': price,
      'description': description,
      'image_url': imageUrl,
      'category_id': categoryId,
      'is_available': true,
    }).select().single();
    return res['id'] as String;
  }

  Future<void> updateMeal(String id, Map<String, dynamic> updates) async {
    if (updates.isEmpty) return;
    await cloud.from('meals').update(updates).eq('id', id);
  }

  Future<void> deleteMeal(String id) async {
    await cloud.from('meals').delete().eq('id', id);
  }

  // Ingredients
  Future<List<Ingredient>> getIngredients() async {
    final res = await cloud.from('ingredients').select().order('name');
    return (res as List).map((e) => Ingredient.fromMap(e)).toList();
  }

  Future<void> addIngredient(String name, double stock, String unit) async {
    await cloud.from('ingredients').insert({
      'name': name,
      'stock_level': stock,
      'unit': unit,
    });
  }

  Future<void> updateIngredient(String id, String name, double stock, String unit) async {
    await cloud.from('ingredients').update({
      'name': name,
      'stock_level': stock,
      'unit': unit,
    }).eq('id', id);
  }

  Future<void> deleteIngredient(String id) async {
    await cloud.from('ingredients').delete().eq('id', id);
  }

  // Meal Ingredients
  Future<List<MealIngredient>> getMealIngredients(String mealId) async {
    final res = await cloud
        .from('meal_ingredients')
        .select('*, ingredients(*)')
        .eq('meal_id', mealId);
    return (res as List).map((e) => MealIngredient.fromMap(e)).toList();
  }

  Future<void> updateMealIngredients(String mealId, List<String> ingredientIds) async {
    await cloud.from('meal_ingredients').delete().eq('meal_id', mealId);
    if (ingredientIds.isNotEmpty) {
      await cloud.from('meal_ingredients').insert(
        ingredientIds.map((id) => {
          'meal_id': mealId,
          'ingredient_id': id,
          'quantity_used': 1.0, // Default quantity
        }).toList(),
      );
    }
  }

  // Ratings
  Future<Map<String, Map<String, num>>> getMealRatings() async {
    final res = await cloud.from('reviews').select('meal_id, rating');
    
    final ratings = <String, List<int>>{};
    for (var r in res) {
      final mealId = r['meal_id'] as String;
      final rating = (r['rating'] as num).toInt();
      if (!ratings.containsKey(mealId)) {
        ratings[mealId] = [];
      }
      ratings[mealId]!.add(rating);
    }

    final result = <String, Map<String, num>>{};
    ratings.forEach((mealId, list) {
      final avg = list.reduce((a, b) => a + b) / list.length;
      result[mealId] = {
        'average': avg,
        'count': list.length,
      };
    });
    
    return result;
  }
  // Image Upload
  Future<String?> uploadImage(File file) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split(Platform.pathSeparator).last}';
      await cloud.storage.from('images').upload(
            fileName,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );
      
      // Get public URL
      final publicUrl = cloud.storage.from('images').getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}


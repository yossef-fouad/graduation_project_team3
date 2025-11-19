// import 'package:get/get.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../Category Model.dart';
// import '../../Meal Item Model.dart';
//
//
// final SupabaseClient cloud = Supabase.instance.client;
//
// class MenuController extends GetxController {
//   final RxList<Category> categories = <Category>[].obs;
//   final RxList<MealItem> meals = <MealItem>[].obs;
//   final RxBool loading = false.obs;
//   final RxString selectedCategoryId = ''.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchCategories();
//     fetchMeals();
//   }
//
//   Future<void> fetchCategories() async {
//     loading.value = true;
//     try {
//       final res = await cloud.from('categories').select().order('name');
//       categories.assignAll(
//         (res as List).map((e) => Category.fromMap(e as Map<String, dynamic>)).toList(),
//       );
//     } catch (e) {
//       print('Error fetching categories: $e');
//     } finally {
//       loading.value = false;
//     }
//   }
//
//   Future<void> fetchMeals() async {
//     loading.value = true;
//     try {
//       var query = cloud.from('meals').select().order('name');
//       if (selectedCategoryId.value.isNotEmpty) {
//         // query = query.eq('category_id', selectedCategoryId.value);
//       }
//       final res = await query;
//       meals.assignAll(
//         (res as List).map((e) => MealItem.fromMap(e as Map<String, dynamic>)).toList(),
//       );
//     } catch (e) {
//       print('Error fetching meals: $e');
//     } finally {
//       loading.value = false;
//     }
//   }
//
//   Future<void> addCategory(String name) async {
//     if (name.isEmpty) return;
//     try {
//       await cloud.from('categories').insert({'name': name});
//       await fetchCategories();
//     } catch (e) {
//       print('Error adding category: $e');
//     }
//   }
//
//   Future<void> updateCategory(String id, String name) async {
//     if (name.isEmpty) return;
//     try {
//       await cloud.from('categories').update({'name': name}).eq('id', id);
//       await fetchCategories();
//     } catch (e) {
//       print('Error updating category: $e');
//     }
//   }
//
//   Future<void> deleteCategory(String id) async {
//     try {
//       await cloud.from('categories').delete().eq('id', id);
//       if (selectedCategoryId.value == id) selectedCategoryId.value = '';
//       await fetchCategories();
//       await fetchMeals();
//     } catch (e) {
//       print('Error deleting category: $e');
//     }
//   }
//
//   Future<void> addMeal({
//     required String name,
//     required double price,
//     String? description,
//     String? imageUrl,
//     String? categoryId,
//   }) async {
//     if (name.isEmpty || price <= 0) return;
//     try {
//       await cloud.from('meals').insert({
//         'name': name,
//         'price': price,
//         'description': description,
//         'image_url': imageUrl,
//         'category_id': categoryId,
//         'is_available': true,
//       });
//       await fetchMeals();
//     } catch (e) {
//       print('Error adding meal: $e');
//     }
//   }
//
//   Future<void> updateMeal(
//       MealItem meal, {
//         String? name,
//         double? price,
//         String? description,
//         String? imageUrl,
//         String? categoryId,
//         bool? isAvailable,
//       }) async {
//     final update = <String, dynamic>{};
//     if (name != null) update['name'] = name;
//     if (price != null) update['price'] = price;
//     if (description != null) update['description'] = description;
//     if (imageUrl != null) update['image_url'] = imageUrl;
//     if (categoryId != null) update['category_id'] = categoryId;
//     if (isAvailable != null) update['is_available'] = isAvailable;
//     if (update.isEmpty) return;
//
//     try {
//       await cloud.from('meals').update(update).eq('id', meal.id);
//       await fetchMeals();
//     } catch (e) {
//       print('Error updating meal: $e');
//     }
//   }
//
//   Future<void> deleteMeal(String id) async {
//     try {
//       await cloud.from('meals').delete().eq('id', id);
//       await fetchMeals();
//     } catch (e) {
//       print('Error deleting meal: $e');
//     }
//   }
//
//   void setCategoryFilter(String? id) {
//     selectedCategoryId.value = id ?? '';
//     fetchMeals();
//   }
// }

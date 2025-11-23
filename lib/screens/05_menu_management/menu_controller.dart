import 'package:get/get.dart';
import 'package:order_pad/models/category.dart';
import 'package:order_pad/models/meal_item.dart';
import 'package:order_pad/models/ingredient.dart';
import 'package:order_pad/models/meal_ingredient.dart';
import 'package:order_pad/screens/05_menu_management/menu_management_service.dart';

class MenuManagementController extends GetxController {
  final _service = MenuManagementService();

  final categories = <Category>[].obs;
  final meals = <MealItem>[].obs;
  final ingredients = <Ingredient>[].obs;
  
  final categoriesLoading = true.obs;
  final mealsLoading = true.obs;
  final ingredientsLoading = true.obs;
  
  final savingCategory = false.obs;
  final savingMeal = false.obs;
  final savingIngredient = false.obs;
  
  final deletingCategoryId = ''.obs;
  final deletingMealId = ''.obs;
  final deletingIngredientId = ''.obs;
  
  final updatingMealId = ''.obs;
  final loadingMore = false.obs;
  final hasMore = true.obs;
  
  final selectedCategoryId = ''.obs;
  int mealOffset = 0;
  static const pageSize = 20;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchMeals();
    fetchIngredients();
  }

  Future<void> fetchIngredients() async {
    ingredientsLoading.value = true;
    try {
      final list = await _service.getIngredients();
      ingredients.assignAll(list);
    } finally {
      ingredientsLoading.value = false;
    }
  }

  Future<void> fetchCategories() async {
    categoriesLoading.value = true;
    try {
      final list = await _service.getCategories();
      categories.assignAll(list);
    } finally {
      categoriesLoading.value = false;
    }
  }

  Future<void> fetchMeals({bool reset = false}) async {
    mealsLoading.value = true;
    if (reset) {
      mealOffset = 0;
      meals.clear();
      hasMore.value = true;
    }
    try {
      final list = await _service.getMeals(
        offset: mealOffset,
        limit: pageSize,
        categoryId: selectedCategoryId.value,
      );
      meals.addAll(list);
      mealOffset += list.length;
      hasMore.value = list.length == pageSize;
    } finally {
      mealsLoading.value = false;
    }
  }

  Future<void> loadMoreMeals() async {
    if (!hasMore.value || loadingMore.value) return;
    loadingMore.value = true;
    try {
      final list = await _service.getMeals(
        offset: mealOffset,
        limit: pageSize,
        categoryId: selectedCategoryId.value,
      );
      meals.addAll(list);
      mealOffset += list.length;
      hasMore.value = list.length == pageSize;
    } finally {
      loadingMore.value = false;
    }
  }

  Future<void> addCategory(String name) async {
    if (name.isEmpty) return;
    savingCategory.value = true;
    try {
      await _service.addCategory(name);
      await fetchCategories();
    } finally {
      savingCategory.value = false;
    }
  }

  Future<void> updateCategory(String id, String name) async {
    savingCategory.value = true;
    try {
      await _service.updateCategory(id, name);
      await fetchCategories();
    } finally {
      savingCategory.value = false;
    }
  }

  Future<void> deleteCategory(String id) async {
    deletingCategoryId.value = id;
    try {
      await _service.deleteCategory(id);
      if (selectedCategoryId.value == id) selectedCategoryId.value = '';
      await fetchCategories();
      await fetchMeals(reset: true);
    } finally {
      deletingCategoryId.value = '';
    }
  }

  Future<void> addIngredient(String name, double stock, String unit) async {
    savingIngredient.value = true;
    try {
      await _service.addIngredient(name, stock, unit);
      await fetchIngredients();
    } finally {
      savingIngredient.value = false;
    }
  }

  Future<void> updateIngredient(String id, String name, double stock, String unit) async {
    savingIngredient.value = true;
    try {
      await _service.updateIngredient(id, name, stock, unit);
      await fetchIngredients();
    } finally {
      savingIngredient.value = false;
    }
  }

  Future<void> deleteIngredient(String id) async {
    deletingIngredientId.value = id;
    try {
      await _service.deleteIngredient(id);
      await fetchIngredients();
    } finally {
      deletingIngredientId.value = '';
    }
  }

  Future<List<MealIngredient>> fetchMealIngredients(String mealId) async {
    return await _service.getMealIngredients(mealId);
  }

  Future<void> addMeal({
    required String name,
    required double price,
    String? description,
    String? imageUrl,
    String? categoryId,
    List<String> ingredientIds = const [],
  }) async {
    savingMeal.value = true;
    try {
      final mealId = await _service.addMeal(
        name: name,
        price: price,
        description: description,
        imageUrl: imageUrl,
        categoryId: categoryId,
      );

      if (ingredientIds.isNotEmpty) {
        await _service.updateMealIngredients(mealId, ingredientIds);
      }
      await fetchMeals(reset: true);
    } finally {
      savingMeal.value = false;
    }
  }

  Future<void> updateMeal(
    MealItem meal, {
    String? name,
    double? price,
    String? description,
    String? imageUrl,
    String? categoryId,
    bool? isAvailable,
    List<String>? ingredientIds,
    bool refresh = true,
  }) async {
    final update = <String, dynamic>{};
    if (name != null) update['name'] = name;
    if (price != null) update['price'] = price;
    if (description != null) update['description'] = description;
    if (imageUrl != null) update['image_url'] = imageUrl;
    if (categoryId != null) update['category_id'] = categoryId;
    if (isAvailable != null) update['is_available'] = isAvailable;
    
    if (ingredientIds != null) refresh = true;

    if (update.isEmpty && ingredientIds == null) return;
    
    final trackInline = !refresh;
    if (trackInline) updatingMealId.value = meal.id;
    try {
      if (update.isNotEmpty) {
        await _service.updateMeal(meal.id, update);
      }

      if (ingredientIds != null) {
        await _service.updateMealIngredients(meal.id, ingredientIds);
      }

      if (refresh) {
        await fetchMeals(reset: true);
      } else {
        final idx = meals.indexWhere((x) => x.id == meal.id);
        if (idx != -1) {
          meals[idx] = meals[idx].copyWith(
            name: name,
            price: price,
            description: description,
            imageUrl: imageUrl,
            categoryId: categoryId,
            isAvailable: isAvailable,
          );
        }
      }
    } finally {
      if (trackInline) updatingMealId.value = '';
    }
  }

  Future<void> deleteMeal(String id) async {
    deletingMealId.value = id;
    try {
      await _service.deleteMeal(id);
      await fetchMeals(reset: true);
    } finally {
      deletingMealId.value = '';
    }
  }

  void setCategoryFilter(String? id) {
    selectedCategoryId.value = id ?? '';
    fetchMeals(reset: true);
  }
}

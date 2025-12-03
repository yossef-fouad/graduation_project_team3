import 'package:get/get.dart';
import 'package:order_pad/models/meal_item.dart';
import 'package:order_pad/services/categories_service.dart';

class CategoryMealsController extends GetxController {
  var isLoading = true.obs;
  var meals = <MealItem>[].obs;
  var error = ''.obs;

  final String categoryId;

  CategoryMealsController(this.categoryId);

  @override
  void onInit() {
    super.onInit();
    fetchMeals();
  }

  void fetchMeals() async {
    try {
      isLoading(true);
      error('');
      var fetchedMeals = await CategoriesService.fetchMealsByCategory(
        categoryId,
      );
      meals.assignAll(fetchedMeals);
    } catch (e) {
      error(e.toString());
    } finally {
      isLoading(false);
    }
  }
}

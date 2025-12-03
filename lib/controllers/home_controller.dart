import 'package:get/get.dart';
import 'package:order_pad/models/category.dart';
import 'package:order_pad/services/categories_service.dart';

class HomeController extends GetxController {
  var isLoading = true.obs;
  var categories = <Category>[].obs;
  var error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  void fetchCategories() async {
    try {
      isLoading(true);
      error('');
      var fetchedCategories = await CategoriesService.fetchCategories();
      categories.assignAll(fetchedCategories);
    } catch (e) {
      error(e.toString());
    } finally {
      isLoading(false);
    }
  }
}

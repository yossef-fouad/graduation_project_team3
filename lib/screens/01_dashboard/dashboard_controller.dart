import 'package:get/get.dart';
import 'package:order_pad/models/category.dart';
import 'package:order_pad/screens/01_dashboard/dashboard_service.dart';

class DashboardController extends GetxController {
  final _service = DashboardService();
  
  final topSellingMeals = <TopSellingMeal>[].obs;
  final isLoading = true.obs;
  final isMoreLoading = false.obs;
  
  final totalSales = 0.0.obs;
  final totalRevenue = 0.0.obs;
  
  int _page = 0;
  final int _pageSize = 10;
  bool hasMore = true;
  
  final categories = <Category>[].obs;
  final selectedCategoryId = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchTopSellingMeals(refresh: true);
    fetchDashboardStats();
  }

  Future<void> fetchDashboardStats() async {
    try {
      final stats = await _service.getDashboardStats();
      totalSales.value = stats['totalSales'] ?? 0;
      totalRevenue.value = stats['totalRevenue'] ?? 0;
    } catch (e) {
      print('Error fetching dashboard stats: $e');
    }
  }

  Future<void> fetchCategories() async {
    try {
      final list = await _service.getCategories();
      categories.assignAll(list);
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  void selectCategory(String? id) {
    if (selectedCategoryId.value == id) return;
    selectedCategoryId.value = id;
    fetchTopSellingMeals(refresh: true);
  }

  Future<void> fetchTopSellingMeals({bool refresh = false}) async {
    if (refresh) {
      isLoading.value = true;
      _page = 0;
      hasMore = true;
      topSellingMeals.clear();
    } else {
      if (!hasMore || isMoreLoading.value) return;
      isMoreLoading.value = true;
    }

    try {
      final list = await _service.getTopSellingMeals(
        page: _page, 
        pageSize: _pageSize,
        categoryId: selectedCategoryId.value,
      );
      
      if (list.length < _pageSize) {
        hasMore = false;
      }

      if (refresh) {
        topSellingMeals.assignAll(list);
      } else {
        topSellingMeals.addAll(list);
      }
      
      _page++;
    } catch (e) {
      print('Error fetching top selling meals: $e');
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
  }

  void loadMore() => fetchTopSellingMeals(refresh: false);
}

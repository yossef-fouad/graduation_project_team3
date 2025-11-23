import 'package:get/get.dart';
import 'package:order_pad/screens/01_dashboard/dashboard_service.dart';

class DashboardController extends GetxController {
  final _service = DashboardService();
  
  final topSellingMeals = <TopSellingMeal>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTopSellingMeals();
  }

  Future<void> fetchTopSellingMeals() async {
    isLoading.value = true;
    try {
      final list = await _service.getTopSellingMeals();
      topSellingMeals.assignAll(list);
    } catch (e) {
      print('Error fetching top selling meals: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

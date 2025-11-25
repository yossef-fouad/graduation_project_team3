import 'package:get/get.dart';
import 'package:order_pad/screens/03_active_orders/active_orders_service.dart';

class ActiveOrdersController extends GetxController {
  final ActiveOrdersService _service = ActiveOrdersService();
  
  var orders = <ChefOrder>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    isLoading.value = true;
    try {
      final fetchedOrders = await _service.getPendingOrders();
      orders.assignAll(fetchedOrders);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load orders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> completeOrder(String orderId) async {
    try {
      await _service.markOrderAsDone(orderId);
      // Remove from local list to update UI immediately
      orders.removeWhere((o) => o.order.id == orderId);
      Get.snackbar('Success', 'Order marked as done');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update order: $e');
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      await _service.cancelOrder(orderId);
      orders.removeWhere((o) => o.order.id == orderId);
      Get.snackbar('Success', 'Order cancelled');
    } catch (e) {
      Get.snackbar('Error', 'Failed to cancel order: $e');
    }
  }
}

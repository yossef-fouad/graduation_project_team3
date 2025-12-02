import 'package:get/get.dart';
import 'package:order_pad/screens/03_active_orders/active_orders_service.dart';

class ActiveOrdersController extends GetxController {
  final ActiveOrdersService _service = ActiveOrdersService();
  
  var orders = <ChefOrder>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _setupStream();
  }

  void _setupStream() {
    isLoading.value = true;
    orders.bindStream(_service.getOrdersStream().map((event) {
      isLoading.value = false;
      return event;
    }));
  }

  // Kept for manual refresh if needed, though stream handles it.
  void fetchOrders() {
    // Re-binding stream or just ignoring. 
    // Since bindStream manages subscription, we might not need to do anything.
    // But if the user insists on a refresh button, we could just ensure stream is active.
  }

  Future<void> completeOrder(String orderId) async {
    try {
      await _service.markOrderAsDone(orderId);
      Get.snackbar('Success', 'Order marked as done');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update order: $e');
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      await _service.cancelOrder(orderId);
      Get.snackbar('Success', 'Order cancelled');
    } catch (e) {
      Get.snackbar('Error', 'Failed to cancel order: $e');
    }
  }
}

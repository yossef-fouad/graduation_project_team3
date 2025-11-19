import 'package:get/get.dart';
import 'package:flutter/material.dart' hide MenuController;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../Meal Item Model.dart';
import 'menu_controller.dart';

class OrderController extends GetxController {
  final MenuController menuController = Get.find<MenuController>();
  final RxMap<String, int> cart = <String, int>{}.obs;

  RxDouble get total => cart.keys.fold(0.0.obs, (sum, mealId) {
    final meal = menuController.meals.firstWhereOrNull((m) => m.id == mealId);
    if (meal == null) return sum;
    return (sum.value + (meal.price * cart[mealId]!)).obs;
  });

  RxInt get itemCount => cart.values.fold(0.obs, (count, quantity) => (count.value + quantity).obs);

  void addToCart(MealItem meal) {
    if (cart.containsKey(meal.id)) {
      cart[meal.id] = cart[meal.id]! + 1;
    } else {
      cart[meal.id] = 1;
    }
    cart.refresh();
  }

  void removeFromCart(MealItem meal) {
    if (cart.containsKey(meal.id)) {
      if (cart[meal.id]! > 1) {
        cart[meal.id] = cart[meal.id]! - 1;
      } else {
        cart.remove(meal.id);
      }
    }
    cart.refresh();
  }

  void clearCart() {
    cart.clear();
    cart.refresh();
  }

  Future<void> submitOrder(String customerName) async {
    if (cart.isEmpty) {
      Get.snackbar('السلة فارغة', 'الرجاء اختيار وجبة واحدة على الأقل لإرسال الطلب.',
          backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final List<Map<String, dynamic>> orderDetailsList = [];
    String detailsText = 'الطلبات:\n';

    for (var entry in cart.entries) {
      final meal = menuController.meals.firstWhereOrNull((m) => m.id == entry.key);
      if (meal != null) {
        orderDetailsList.add({
          'meal_id': meal.id,
          'name': meal.name,
          'quantity': entry.value,
          'price': meal.price,
        });
        detailsText += '  - ${entry.value}x ${meal.name} @ ${meal.price.toStringAsFixed(2)}\n';
      }
    }

    try {
      await cloud.from('orders').insert({
        'customer_name': customerName.isNotEmpty
            ? customerName
            : 'زبون رقم ${DateTime.now().millisecondsSinceEpoch % 10000}',
        'total': total.value,
        'status': 'جديد',
        'details': detailsText,
      });

      clearCart();
      Get.snackbar('تم إرسال الطلب', 'تم إرسال طلبك بنجاح إلى المطبخ.',
          backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('خطأ', 'فشل إرسال الطلب. تحقق من اتصالك أو جدول Supabase.',
          backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      print('Error submitting order: $e');
    }
  }
}

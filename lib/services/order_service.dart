import 'package:order_pad/main.dart';
import 'package:order_pad/models/meal_item.dart';

class OrderService {
  /// Submit an order to the database
  /// Returns the order ID on success
  static Future<String> submitOrder({
    required String customerPhone,
    required double totalPrice,
    required Map<MealItem, int> items,
  }) async {
    try {
      print('🔵 [OrderService] Starting order submission...');
      print('📱 Customer Phone: $customerPhone');
      print('💰 Total Price: \$${totalPrice.toStringAsFixed(2)}');
      print('📦 Number of items: ${items.length}');

      // Log each item
      items.forEach((meal, quantity) {
        print(
          '   - ${meal.name} (ID: ${meal.id}) x$quantity @ \$${meal.price}',
        );
      });

      // 1. INSERT PARENT ORDER
      print('🔵 [OrderService] Inserting order into database...');
      final orderResponse =
          await cloud
              .from('orders')
              .insert({
                'customer_phone': customerPhone,
                'total_price': totalPrice,
                // Removed 'status' - let database use default value
                'created_at': DateTime.now().toIso8601String(),
              })
              .select()
              .single();

      final newOrderId = orderResponse['id'] as String;
      print('✅ [OrderService] Order created with ID: $newOrderId');

      // 2. PREPARE CHILD ITEMS
      final List<Map<String, dynamic>> orderItemsData = [];

      items.forEach((meal, quantity) {
        orderItemsData.add({
          'order_id': newOrderId,
          'meal_id': meal.id,
          'quantity': quantity,
          'price_at_order': meal.price,
        });
      });

      // 3. INSERT CHILD ITEMS
      if (orderItemsData.isNotEmpty) {
        print(
          '🔵 [OrderService] Inserting ${orderItemsData.length} order items...',
        );
        await cloud.from('order_items').insert(orderItemsData);
        print('✅ [OrderService] Order items inserted successfully');
      }

      print(
        '✅ [OrderService] Order submitted successfully with ID: $newOrderId',
      );
      return newOrderId;
    } catch (e) {
      print('❌ [OrderService] Error submitting order: $e');
      print('❌ [OrderService] Error type: ${e.runtimeType}');
      rethrow;
    }
  }
}

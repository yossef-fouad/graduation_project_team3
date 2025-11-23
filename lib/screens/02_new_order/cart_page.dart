import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:order_pad/services/cart_controller.dart';
import 'package:order_pad/services/order_service.dart';
import 'package:order_pad/widgets/colors.dart';
import 'package:order_pad/widgets/customer_phone_bottom_sheet.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Cart',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: GetBuilder<CartController>(
        builder: (controller) {
          if (controller.cartMealsList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: Colors.grey.shade300,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Add items to get started',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Cart items list
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: controller.cartMealsList.length,
                  itemBuilder: (context, index) {
                    final meal = controller.cartMealsList[index];
                    final quantity = controller.getQuantity(meal.id);

                    return Container(
                      margin: EdgeInsets.only(bottom: 16),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.15),
                            spreadRadius: 1,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Product image
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: AppColors.tertiary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child:
                                  meal.imageUrl != null &&
                                          meal.imageUrl!.isNotEmpty
                                      ? CachedNetworkImage(
                                        imageUrl: meal.imageUrl!,
                                        fit: BoxFit.cover,
                                        placeholder:
                                            (context, url) => Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                        errorWidget:
                                            (context, url, error) => Icon(
                                              Icons.restaurant,
                                              color: AppColors.primary
                                                  .withOpacity(0.3),
                                              size: 32,
                                            ),
                                      )
                                      : Icon(
                                        Icons.restaurant,
                                        color: AppColors.primary.withOpacity(
                                          0.3,
                                        ),
                                        size: 32,
                                      ),
                            ),
                          ),
                          SizedBox(width: 12),

                          // Product details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  meal.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '\$${meal.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Quantity controls
                          Row(
                            children: [
                              // Decrease button
                              GestureDetector(
                                onTap:
                                    () => controller.updateQuantity(
                                      meal.id,
                                      quantity - 1,
                                    ),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.remove, size: 18),
                                ),
                              ),
                              SizedBox(width: 12),

                              // Quantity
                              Text(
                                quantity.toString(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 12),

                              // Increase button
                              GestureDetector(
                                onTap:
                                    () => controller.updateQuantity(
                                      meal.id,
                                      quantity + 1,
                                    ),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom section with total and submit button
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${controller.totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    // Submit Order button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          print('🟢 [CartPage] Submit Order button pressed');
                          print(
                            '🟢 [CartPage] Total items: ${controller.totalItems}',
                          );
                          print(
                            '🟢 [CartPage] Total amount: \$${controller.totalAmount.toStringAsFixed(2)}',
                          );

                          await showCustomerPhoneBottomSheet(
                            context: context,
                            onSubmit: (phoneNumber) async {
                              try {
                                print(
                                  '🟢 [CartPage] Phone number entered: $phoneNumber',
                                );
                                print('🟢 [CartPage] Preparing cart items...');

                                final cartItems = controller.getCartItemsMap();
                                print(
                                  '🟢 [CartPage] Cart items prepared: ${cartItems.length} items',
                                );

                                // Submit order
                                print(
                                  '🟢 [CartPage] Calling OrderService.submitOrder...',
                                );
                                final orderId = await OrderService.submitOrder(
                                  customerPhone: phoneNumber,
                                  totalPrice: controller.totalAmount,
                                  items: cartItems,
                                );

                                print(
                                  '🟢 [CartPage] Order submitted successfully! Order ID: $orderId',
                                );

                                // Close bottom sheet
                                Navigator.of(context).pop();

                                // Clear cart
                                print('🟢 [CartPage] Clearing cart...');
                                controller.clearCart();

                                // Show success message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Order submitted successfully!',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: AppColors.primary,
                                    duration: Duration(seconds: 3),
                                  ),
                                );

                                // Navigate back
                                Navigator.of(context).pop();
                                print(
                                  '🟢 [CartPage] Order submission flow completed',
                                );
                              } catch (e) {
                                print(
                                  '🔴 [CartPage] Error during order submission: $e',
                                );
                                print(
                                  '🔴 [CartPage] Error type: ${e.runtimeType}',
                                );

                                // Show error
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Error: ${e.toString()}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: AppColors.error,
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                              }
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_bag, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Submit Order (${controller.totalItems} items)',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

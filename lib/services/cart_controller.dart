import 'package:get/get.dart';
import 'package:order_pad/models/meal_item.dart';

class CartController extends GetxController {
  // Observable cart items and quantities
  final RxMap<String, MealItem> _cartItems = <String, MealItem>{}.obs;
  final RxMap<String, int> _itemQuantities = <String, int>{}.obs;

  // Getters
  Map<String, MealItem> get cartItems => _cartItems;
  Map<String, int> get itemQuantities => _itemQuantities;

  // Get all meals as a list
  List<MealItem> get cartMealsList => _cartItems.values.toList();

  // Get total number of items
  int get totalItems {
    return _itemQuantities.values.fold(0, (sum, quantity) => sum + quantity);
  }

  // Get total amount
  double get totalAmount {
    double total = 0;
    _cartItems.forEach((id, meal) {
      final quantity = _itemQuantities[id] ?? 0;
      total += meal.price * quantity;
    });
    return total;
  }

  // Check if item is in cart
  bool isInCart(String mealId) {
    return _cartItems.containsKey(mealId);
  }

  // Get quantity of specific item
  int getQuantity(String mealId) {
    return _itemQuantities[mealId] ?? 0;
  }

  // Add meal to cart
  void addToCart(MealItem meal) {
    if (_cartItems.containsKey(meal.id)) {
      // If already in cart, increase quantity
      _itemQuantities[meal.id] = (_itemQuantities[meal.id] ?? 0) + 1;
    } else {
      // Add new item with quantity 1
      _cartItems[meal.id] = meal;
      _itemQuantities[meal.id] = 1;
    }
    update();
  }

  // Remove meal from cart
  void removeFromCart(String mealId) {
    _cartItems.remove(mealId);
    _itemQuantities.remove(mealId);
    update();
  }

  // Update quantity
  void updateQuantity(String mealId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(mealId);
    } else {
      _itemQuantities[mealId] = quantity;
      update();
    }
  }

  // Clear cart
  void clearCart() {
    _cartItems.clear();
    _itemQuantities.clear();
    update();
  }

  // Get cart items as map for order submission
  Map<MealItem, int> getCartItemsMap() {
    Map<MealItem, int> result = {};
    _cartItems.forEach((id, meal) {
      result[meal] = _itemQuantities[id] ?? 0;
    });
    return result;
  }
}

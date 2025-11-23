class Order {
  final String id;
  final DateTime createdAt;
  final double totalAmount;
  final String status;

  Order({
    required this.id,
    required this.createdAt,
    required this.totalAmount,
    required this.status,
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      totalAmount: (map['total_amount'] as num).toDouble(),
      status: map['status'] as String,
    );
  }
}

class OrderItem {
  final String id;
  final String orderId;
  final String mealId;
  final int quantity;
  final double price;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.mealId,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'] as String,
      orderId: map['order_id'] as String,
      mealId: map['meal_id'] as String,
      quantity: (map['quantity'] as num).toInt(),
      price: (map['price'] as num).toDouble(),
    );
  }
}

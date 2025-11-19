class OrderItem {
  final String id;
  final String orderId;
  final String customerName;
  final String status;
  final String details;
  final double total;
  final DateTime createdAt;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.customerName,
    required this.status,
    required this.details,
    required this.total,
    required this.createdAt,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'].toString(),
      orderId: 'ORD-${json['id']}',
      customerName: json['customer_name'] ?? 'Unknown customer',
      status: json['status'] ?? 'New',
      details: json['details'] ?? 'Order details: Not available',
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

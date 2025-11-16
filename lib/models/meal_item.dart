class MealItem {
  final String id;
  final String? categoryId;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final bool isAvailable;
  MealItem({
    required this.id,
    this.categoryId,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    required this.isAvailable,
  });
  factory MealItem.fromMap(Map<String, dynamic> m) {
    final p = m['price'];
    return MealItem(
      id: m['id'] as String,
      categoryId: m['category_id'] as String?,
      name: (m['name'] ?? '') as String,
      description: m['description'] as String?,
      price: p is num ? p.toDouble() : double.tryParse(p?.toString() ?? '0') ?? 0,
      imageUrl: m['image_url'] as String?,
      isAvailable: (m['is_available'] ?? true) as bool,
    );
  }
}
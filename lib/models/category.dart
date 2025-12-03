class Category {
  final String id;
  final String name;
  final String? color;
  final String? imageUrl;

  Category({required this.id, required this.name, this.color, this.imageUrl});

  factory Category.fromMap(Map<String, dynamic> m) {
    return Category(
      id: m['id'] as String,
      name: (m['name'] ?? '') as String,
      color: m['color'] as String?,
      imageUrl: m['image_url'] as String?,
    );
  }
}

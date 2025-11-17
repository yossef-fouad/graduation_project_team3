class Category {
  final String id;
  final String name;
  final String? color;
  Category({required this.id, required this.name, this.color});
  factory Category.fromMap(Map<String, dynamic> m) {
    return Category(id: m['id'] as String, name: (m['name'] ?? '') as String, color: m['color'] as String?);
  }
}
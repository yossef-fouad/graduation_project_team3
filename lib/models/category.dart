class Category {
  final String id;
  final String name;
  Category({required this.id, required this.name});
  factory Category.fromMap(Map<String, dynamic> m) {
    return Category(id: m['id'] as String, name: (m['name'] ?? '') as String);
  }
}
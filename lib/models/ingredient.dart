class Ingredient {
  final String id;
  final String name;
  final double stockLevel;
  final String unit;

  Ingredient({
    required this.id,
    required this.name,
    required this.stockLevel,
    required this.unit,
  });

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      id: map['id'] as String,
      name: map['name'] as String,
      stockLevel: (map['stock_level'] as num).toDouble(),
      unit: map['unit'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'stock_level': stockLevel,
      'unit': unit,
    };
  }
}

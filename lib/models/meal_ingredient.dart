class MealIngredient {
  final String mealId;
  final String ingredientId;
  final double quantityUsed;
  final String? ingredientName;
  final String? unit;

  MealIngredient({
    required this.mealId,
    required this.ingredientId,
    required this.quantityUsed,
    this.ingredientName,
    this.unit,
  });

  factory MealIngredient.fromMap(Map<String, dynamic> map) {
    return MealIngredient(
      mealId: map['meal_id'] as String,
      ingredientId: map['ingredient_id'] as String,
      quantityUsed: (map['quantity_used'] as num).toDouble(),
      ingredientName: map['ingredients']?['name'] as String?,
      unit: map['ingredients']?['unit'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'meal_id': mealId,
      'ingredient_id': ingredientId,
      'quantity_used': quantityUsed,
    };
  }
}

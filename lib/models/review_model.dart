class Review {
  final String? id;
  final String orderId;
  final String mealId;
  final int rating;
  final String? comment;
  final Map<String, double> ingredientRatings;
  final DateTime? createdAt;

  Review({
    this.id,
    required this.orderId,
    required this.mealId,
    required this.rating,
    this.comment,
    this.ingredientRatings = const {},
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'order_id': orderId,
      'meal_id': mealId,
      'rating': rating,
      'comment': comment,
      'ingredient_ratings': ingredientRatings,
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'] as String?,
      orderId: map['order_id'] as String,
      mealId: map['meal_id'] as String,
      rating: (map['rating'] as num).toInt(),
      comment: map['comment'] as String?,
      ingredientRatings: Map<String, double>.from(map['ingredient_ratings'] ?? {}),
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : null,
    );
  }
}

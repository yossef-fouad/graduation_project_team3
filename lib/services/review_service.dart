import 'package:order_pad/models/review_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReviewService {
  final _client = Supabase.instance.client;

  Future<void> submitReview(Review review) async {
    try {
      await _client.from('reviews').insert(review.toMap());
      print('Review submitted successfully for meal ${review.mealId}');
    } catch (e) {
      print('Error submitting review: $e');
      rethrow;
    }
  }
}

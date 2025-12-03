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

  Future<List<Review>> getReviewsForOrder(String orderId) async {
    try {
      final res = await _client
          .from('reviews')
          .select('*, meals(name)')
          .eq('order_id', orderId);
      
      return (res as List).map((e) => Review.fromMap(e)).toList();
    } catch (e) {
      print('Error fetching reviews for order $orderId: $e');
      rethrow;
    }
  }
}

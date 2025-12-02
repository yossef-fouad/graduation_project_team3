import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:order_pad/models/meal_item.dart';
import 'package:order_pad/models/review_model.dart';
import 'package:order_pad/services/review_service.dart';
import 'package:order_pad/widgets/review_meal_card.dart';

class FeedbackScreen extends StatefulWidget {
  final String orderId;
  final List<MealItem> meals;

  const FeedbackScreen({
    super.key,
    required this.orderId,
    required this.meals,
  });

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final ReviewService _reviewService = ReviewService();
  bool _isSubmitting = false;

  // Temporary storage for ratings before submission
  // Map<MealId, Rating>
  final Map<String, double> _mealRatings = {};
  // Map<MealId, Map<IngredientName, Rating>>
  final Map<String, Map<String, double>> _ingredientRatings = {};
  // Map<MealId, Comment>
  final Map<String, String> _mealComments = {};

  void _submitReviews() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      for (var meal in widget.meals) {
        // Only submit if the meal was rated
        if (_mealRatings.containsKey(meal.id)) {
          final review = Review(
            // id: Let DB generate it
            orderId: widget.orderId,
            mealId: meal.id,
            rating: _mealRatings[meal.id]!.toInt(), // Convert to int as per DB
            comment: _mealComments[meal.id],
            ingredientRatings: _ingredientRatings[meal.id] ?? {},
            createdAt: DateTime.now(),
          );
          await _reviewService.submitReview(review);
        }
      }
      
      Get.snackbar(
        'Success',
        'Thank you for your feedback!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      // Delay to show snackbar then go back
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.of(context).pop();
      }

    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit review: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Your Meal'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.meals.length,
              itemBuilder: (context, index) {
                final meal = widget.meals[index];
                return ReviewMealCard(
                  meal: meal,
                  accentColor: theme.colorScheme.primary,
                  onRatingUpdate: (rating) {
                    setState(() {
                      _mealRatings[meal.id] = rating;
                    });
                  },
                  onIngredientRatingUpdate: (ingredient, rating) {
                    setState(() {
                      if (!_ingredientRatings.containsKey(meal.id)) {
                        _ingredientRatings[meal.id] = {};
                      }
                      _ingredientRatings[meal.id]![ingredient] = rating;
                    });
                  },
                  onCommentUpdate: (comment) {
                    setState(() {
                      _mealComments[meal.id] = comment;
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReviews,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Submit Feedback',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

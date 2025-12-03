import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:order_pad/models/review_model.dart';
import 'package:order_pad/services/review_service.dart';
import 'package:order_pad/widgets/colors.dart';
import 'package:skeletonizer/skeletonizer.dart';

class OrderReviewsController extends GetxController {
  final String orderId;
  OrderReviewsController(this.orderId);

  final ReviewService _service = ReviewService();
  final reviews = <Review>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchReviews();
  }

  void fetchReviews() async {
    try {
      isLoading.value = true;
      // DATA FLOW: Fetching reviews for the specific order ID from Supabase.
      // The service returns a list of Review objects, which includes meal names joined from the meals table.
      reviews.value = await _service.getReviewsForOrder(orderId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load reviews: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

class OrderReviewsScreen extends StatelessWidget {
  final String orderId;

  const OrderReviewsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrderReviewsController(orderId), tag: orderId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Reviews'),
        centerTitle: true,
      ),
      body: Obx(() {
        final isLoading = controller.isLoading.value && controller.reviews.isEmpty;
        final list = isLoading
            ? List.generate(
                3,
                (i) => Review(
                  orderId: orderId,
                  mealId: 'dummy',
                  rating: 5,
                  comment: 'Placeholder comment',
                  mealName: 'Meal Name',
                ),
              )
            : controller.reviews;

        if (!isLoading && controller.reviews.isEmpty) {
          return const Center(child: Text('No reviews found for this order.'));
        }

        return Skeletonizer(
          enabled: isLoading,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final review = list[index];
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  // DISPLAY LOGIC: Each card represents a review.
                  // We use an ExpansionTile to show the meal name and rating initially,
                  // and reveal the comment and detailed ingredient ratings when expanded.
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            review.mealName ?? 'Unknown Meal',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Row(
                          children: List.generate(5, (starIndex) {
                            return Icon(
                              starIndex < review.rating ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 20,
                            );
                          }),
                        ),
                      ],
                    ),
                    subtitle: review.comment != null && review.comment!.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              review.comment!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[800],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          )
                        : null,
                    children: [
                      if (review.ingredientRatings.isNotEmpty) ...[
                        const Divider(),
                        const SizedBox(height: 8),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Ingredient Ratings:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: review.ingredientRatings.entries.map((entry) {
                              return Chip(
                                label: Text('${entry.key}: ${entry.value}'),
                                backgroundColor: Colors.grey[100],
                                labelStyle: const TextStyle(fontSize: 12),
                              );
                            }).toList(),
                          ),
                        ),
                      ] else
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('No ingredient ratings available.'),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:order_pad/models/meal_item.dart';

class ReviewMealCard extends StatefulWidget {
  final MealItem meal;
  final Color accentColor;
  final Function(double) onRatingUpdate;
  final Function(String, double) onIngredientRatingUpdate;
  final Function(String) onCommentUpdate;

  const ReviewMealCard({
    super.key,
    required this.meal,
    required this.accentColor,
    required this.onRatingUpdate,
    required this.onIngredientRatingUpdate,
    required this.onCommentUpdate,
  });

  @override
  State<ReviewMealCard> createState() => _ReviewMealCardState();
}

class _ReviewMealCardState extends State<ReviewMealCard> {
  double _mealRating = 0;

  void _showIngredientsDialog() {
    showDialog(
      context: context,
      builder: (context) => _IngredientsDialog(
        ingredients: widget.meal.ingredients,
        accentColor: widget.accentColor,
        onIngredientRatingUpdate: widget.onIngredientRatingUpdate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = (widget.meal.description ?? '').trim();
    final fadedBodyColor = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: _showIngredientsDialog,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border(left: BorderSide(color: widget.accentColor, width: 4)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(
                id: widget.meal.id,
                url: widget.meal.imageUrl,
                accentColor: widget.accentColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.meal.name,
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          '\$${widget.meal.price.toStringAsFixed(2)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description.isEmpty ? 'No description' : description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(color: fadedBodyColor),
                    ),
                    const SizedBox(height: 8),
                    RatingBar.builder(
                      initialRating: _mealRating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 20,
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        setState(() {
                          _mealRating = rating;
                        });
                        widget.onRatingUpdate(rating);
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Add a comment',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.all(8),
                      ),
                      style: theme.textTheme.bodySmall,
                      onChanged: widget.onCommentUpdate,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String id;
  final String? url;
  final Color accentColor;

  const _Avatar({
    required this.id,
    required this.url,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'review_meal_$id',
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentColor.withValues(alpha: 0.4), width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: url == null || url!.isEmpty
              ? const _PlaceholderThumb()
              : CachedNetworkImage(
                  imageUrl: url!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const _PlaceholderThumb(),
                  errorWidget: (_, __, ___) => const _PlaceholderThumb(),
                ),
        ),
      ),
    );
  }
}

class _PlaceholderThumb extends StatelessWidget {
  const _PlaceholderThumb();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(child: Icon(Icons.fastfood, color: Colors.grey)),
    );
  }
}

class _IngredientsDialog extends StatelessWidget {
  final List<String> ingredients;
  final Color accentColor;
  final Function(String, double) onIngredientRatingUpdate;

  const _IngredientsDialog({
    required this.ingredients,
    required this.accentColor,
    required this.onIngredientRatingUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rate Ingredients'),
      content: SizedBox(
        width: double.maxFinite,
        child: ingredients.isEmpty
            ? const Text('No ingredients listed for this meal.')
            : ListView.builder(
                shrinkWrap: true,
                itemCount: ingredients.length,
                itemBuilder: (context, index) {
                  return _IngredientRatingItem(
                    ingredient: ingredients[index],
                    accentColor: accentColor,
                    onRatingUpdate: (rating) => onIngredientRatingUpdate(ingredients[index], rating),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _IngredientRatingItem extends StatefulWidget {
  final String ingredient;
  final Color accentColor;
  final Function(double) onRatingUpdate;

  const _IngredientRatingItem({
    required this.ingredient,
    required this.accentColor,
    required this.onRatingUpdate,
  });

  @override
  State<_IngredientRatingItem> createState() => _IngredientRatingItemState();
}

class _IngredientRatingItemState extends State<_IngredientRatingItem> {
  double _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.ingredient,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          RatingBar.builder(
            initialRating: _rating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemSize: 16,
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              setState(() {
                _rating = rating;
              });
              widget.onRatingUpdate(rating);
            },
          ),
        ],
      ),
    );
  }
}

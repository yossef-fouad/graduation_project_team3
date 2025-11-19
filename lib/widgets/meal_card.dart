import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:order_pad/models/meal_item.dart';

class MealCard extends StatelessWidget {
  final MealItem meal;
  final String categoryName;
  final Color accentColor;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleAvailable;
  final VoidCallback? onDelete;
  final bool isDeleting;
  final bool isUpdating;
  const MealCard({
    super.key,
    required this.meal,
    required this.categoryName,
    required this.accentColor,
    required this.onEdit,
    required this.onToggleAvailable,
    required this.onDelete,
    this.isDeleting = false,
    this.isUpdating = false,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = (meal.description ?? '').trim();
    final fadedBodyColor = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8);
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: accentColor, width: 4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Avatar(
              url: meal.imageUrl,
              accentColor: accentColor,
              isAvailable: meal.isAvailable,
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
                          meal.name,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        '\$${meal.price.toStringAsFixed(2)}',
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
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _InfoChip(
                        label: categoryName,
                        backgroundColor: accentColor.withValues(alpha: 0.15),
                        textColor: accentColor,
                        icon: Icons.category,
                      ),
                      _InfoChip(
                        label: meal.isAvailable ? 'Available' : 'Hidden',
                        backgroundColor: (meal.isAvailable ? Colors.green : Colors.red).withValues(alpha: 0.15),
                        textColor: meal.isAvailable ? Colors.green.shade700 : Colors.red.shade700,
                        icon: meal.isAvailable ? Icons.check_circle : Icons.remove_circle,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            isDeleting
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(onPressed: onEdit, icon: const Icon(Icons.edit)),
                      IconButton(
                        onPressed: isUpdating ? null : onToggleAvailable,
                        icon: Icon(meal.isAvailable ? Icons.visibility : Icons.visibility_off),
                      ),
                      IconButton(onPressed: onDelete, icon: const Icon(Icons.delete, color: Colors.red)),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? url;
  final Color accentColor;
  final bool isAvailable;
  const _Avatar({
    required this.url,
    required this.accentColor,
    required this.isAvailable,
  });
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
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
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isAvailable ? Colors.green : Colors.red,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;
  const _InfoChip({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
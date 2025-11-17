import 'package:flutter/material.dart';
import 'package:order_pad/models/meal_item.dart';

class MealCard extends StatelessWidget {
  final MealItem meal;
  final String categoryName;
  final Color accentColor;
  final VoidCallback onEdit;
  final VoidCallback onToggleAvailable;
  final VoidCallback onDelete;
  const MealCard({
    super.key,
    required this.meal,
    required this.categoryName,
    required this.accentColor,
    required this.onEdit,
    required this.onToggleAvailable,
    required this.onDelete,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: accentColor, width: 4)),
        ),
        child: ListTile(
          leading: _Avatar(url: meal.imageUrl),
          title: Text(meal.name),
          subtitle: Text('$categoryName • ${meal.price.toStringAsFixed(2)}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(onPressed: onEdit, icon: const Icon(Icons.edit)),
              IconButton(onPressed: onToggleAvailable, icon: Icon(meal.isAvailable ? Icons.visibility : Icons.visibility_off)),
              IconButton(onPressed: onDelete, icon: const Icon(Icons.delete, color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? url;
  const _Avatar({required this.url});
  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return const CircleAvatar(child: Icon(Icons.fastfood));
    }
    return ClipOval(
      child: Image.network(
        url!,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const CircleAvatar(child: Icon(Icons.fastfood)),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String name;
  final Color accentColor;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isBusy;
  const CategoryCard({
    super.key,
    required this.name,
    required this.accentColor,
    required this.onEdit,
    required this.onDelete,
    this.isBusy = false,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: accentColor, width: 4)),
        ),
        child: ListTile(
          leading: CircleAvatar(backgroundColor: accentColor),
          title: Text(name),
          trailing: isBusy
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(onPressed: onEdit, icon: const Icon(Icons.edit)),
                    IconButton(onPressed: onDelete, icon: const Icon(Icons.delete, color: Colors.red)),
                  ],
                ),
        ),
      ),
    );
  }
}
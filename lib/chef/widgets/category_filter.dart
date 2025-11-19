import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';
import '../../Category Model.dart';
import '../controllers/menu_controller.dart';

class CategoryFilter extends StatelessWidget {
  final MenuController c;
  final bool isFilteringCustomerView;

  const CategoryFilter({super.key, required this.c, required this.isFilteringCustomerView});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedId = c.selectedCategoryId.value;
      final categories = c.categories;
      final allCategories = [Category(id: '', name: isFilteringCustomerView ? 'All' : 'Show all')] + categories;

      return DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Filter by category',
          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          isDense: true,
          filled: true,
          fillColor: Colors.white,
        ),
        value: selectedId.isEmpty ? '' : selectedId,
        items: allCategories.map((cat) {
          return DropdownMenuItem<String>(
            value: cat.id,
            child: Text(cat.name),
          );
        }).toList(),
        onChanged: (String? newId) {
          c.setCategoryFilter(newId);
        },
      );
    });
  }
}

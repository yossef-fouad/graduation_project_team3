import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:order_pad/models/category.dart';
import 'package:order_pad/models/meal_item.dart';
import 'package:order_pad/models/ingredient.dart';
import 'package:order_pad/widgets/category_card.dart';
import 'package:order_pad/widgets/meal_card.dart';
import 'package:order_pad/screens/05_menu_management/menu_controller.dart';
import 'package:image_picker/image_picker.dart';

class MenuManagementScreen extends StatelessWidget {
  const MenuManagementScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = Get.put(MenuManagementController());
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Menu Management'),
          bottom: const TabBar(tabs: [
            Tab(text: 'Categories'),
            Tab(text: 'Meals'),
            Tab(text: 'Ingredients'),
          ]),
        ),
        body: TabBarView(children: [
          // Categories Tab
          Column(children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Obx(() => Row(children: [
                    ElevatedButton(
                      onPressed: c.savingCategory.value ? null : () => _showAddCategoryDialog(context, c),
                      child: c.savingCategory.value
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Add Category'),
                    ),
                  ])),
            ),
            Expanded(
              child: Obx(() {
                if (c.categoriesLoading.value && c.categories.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (c.categories.isEmpty) {
                  return const Center(child: Text('No categories yet'));
                }
                return ListView.separated(
                  itemCount: c.categories.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final cat = c.categories[i];
                    final color = _categoryColor(cat.name);
                    final deleting = c.deletingCategoryId.value == cat.id;
                    return CategoryCard(
                      name: cat.name,
                      accentColor: color,
                      isBusy: deleting,
                      onEdit: deleting ? null : () => _showEditCategoryDialog(context, c, cat),
                      onDelete: deleting ? null : () => _confirmDeleteCategory(context, c, cat),
                    );
                  },
                );
              }),
            ),
          ]),
          // Meals Tab
          Column(children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                Expanded(child: _CategoryFilter(c: c)),
                const SizedBox(width: 12),
                Obx(() => ElevatedButton(
                      onPressed: c.savingMeal.value ? null : () => _showAddMealDialog(context, c),
                      child: c.savingMeal.value
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Add Meal'),
                    )),
              ]),
            ),
            Expanded(
              child: Obx(() {
                if (c.mealsLoading.value && c.meals.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (c.meals.isEmpty) {
                  return const Center(child: Text('No meals found'));
                }
                return NotificationListener<ScrollNotification>(
                  onNotification: (n) {
                    if (n.metrics.pixels >= n.metrics.maxScrollExtent - 100) {
                      c.loadMoreMeals();
                    }
                    return false;
                  },
                  child: ListView.separated(
                    itemCount: c.meals.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final m = c.meals[i];
                      final category = c.categories.firstWhere((cat) => cat.id == m.categoryId, orElse: () => Category(id: '', name: 'Uncategorized'));
                      final accent = _categoryColor(category.name);
                      final deleting = c.deletingMealId.value == m.id;
                      final updating = c.savingMeal.value;
                      
                      final rating = c.mealRatings[m.id];
                      final count = c.mealReviewCounts[m.id];

                      return MealCard(
                        meal: m,
                        categoryName: category.name,
                        accentColor: accent,
                        isDeleting: deleting,
                        isUpdating: updating,
                        rating: rating,
                        reviewCount: count,
                        onEdit: deleting ? null : () => _showEditMealDialog(context, c, m),
                        onToggleAvailable: (updating || deleting)
                            ? null
                            : () => c.updateMeal(m, isAvailable: !m.isAvailable, refresh: false),
                        onDelete: deleting ? null : () => _confirmDeleteMeal(context, c, m),
                      );
                    },
                  ),
                );
              }),
            ),
            Obx(() => c.loadingMore.value
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : const SizedBox.shrink()),
          ]),
          // Ingredients Tab
          Column(children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Obx(() => Row(children: [
                    ElevatedButton(
                      onPressed: c.savingIngredient.value ? null : () => _showAddIngredientDialog(context, c),
                      child: c.savingIngredient.value
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Add Ingredient'),
                    ),
                  ])),
            ),
            Expanded(
              child: Obx(() {
                if (c.ingredientsLoading.value && c.ingredients.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (c.ingredients.isEmpty) {
                  return const Center(child: Text('No ingredients yet'));
                }
                return ListView.separated(
                  itemCount: c.ingredients.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final ing = c.ingredients[i];
                    final deleting = c.deletingIngredientId.value == ing.id;
                    return ListTile(
                      title: Text(ing.name),
                      subtitle: Text('Stock: ${ing.stockLevel} ${ing.unit}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (deleting)
                            const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          else ...[
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showEditIngredientDialog(context, c, ing),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDeleteIngredient(context, c, ing),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ]),
        ]),
      ),
    );
  }

  Future<T?> _showAnimatedDialog<T>({
    required BuildContext context,
    required WidgetBuilder builder,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (ctx, a1, a2) => builder(ctx),
      transitionBuilder: (ctx, a1, a2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: a1, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: a1, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }

  void _showAddCategoryDialog(BuildContext context, MenuManagementController c) {
    final nameCtl = TextEditingController();
    _showAnimatedDialog(
      context: context,
      builder: (_) => Obx(() => AlertDialog(
            title: const Text('Add Category'),
            content: TextField(controller: nameCtl, decoration: const InputDecoration(labelText: 'Name')),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: c.savingCategory.value
                    ? null
                    : () async {
                        await c.addCategory(nameCtl.text.trim());
                        if (context.mounted) Navigator.pop(context);
                      },
                child: c.savingCategory.value
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save'),
              ),
            ],
          )),
    );
  }

  void _showEditCategoryDialog(BuildContext context, MenuManagementController c, Category cat) {
    final nameCtl = TextEditingController(text: cat.name);
    _showAnimatedDialog(
      context: context,
      builder: (_) => Obx(() => AlertDialog(
            title: const Text('Edit Category'),
            content: TextField(controller: nameCtl, decoration: const InputDecoration(labelText: 'Name')),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: c.savingCategory.value
                    ? null
                    : () async {
                        await c.updateCategory(cat.id, nameCtl.text.trim());
                        if (context.mounted) Navigator.pop(context);
                      },
                child: c.savingCategory.value
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save'),
              ),
            ],
          )),
    );
  }

  void _showAddIngredientDialog(BuildContext context, MenuManagementController c) {
    final nameCtl = TextEditingController();
    final stockCtl = TextEditingController();
    final unitCtl = TextEditingController(text: 'pcs');
    _showAnimatedDialog(
      context: context,
      builder: (_) => Obx(() => AlertDialog(
            title: const Text('Add Ingredient'),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: nameCtl, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: stockCtl, decoration: const InputDecoration(labelText: 'Stock Level'), keyboardType: TextInputType.numberWithOptions(decimal: true)),
              TextField(controller: unitCtl, decoration: const InputDecoration(labelText: 'Unit (e.g. kg, pcs)')),
            ]),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: c.savingIngredient.value
                    ? null
                    : () async {
                        final stock = double.tryParse(stockCtl.text.trim()) ?? 0;
                        await c.addIngredient(nameCtl.text.trim(), stock, unitCtl.text.trim());
                        if (context.mounted) Navigator.pop(context);
                      },
                child: c.savingIngredient.value
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save'),
              ),
            ],
          )),
    );
  }

  void _showEditIngredientDialog(BuildContext context, MenuManagementController c, Ingredient ing) {
    final nameCtl = TextEditingController(text: ing.name);
    final stockCtl = TextEditingController(text: ing.stockLevel.toString());
    final unitCtl = TextEditingController(text: ing.unit);
    _showAnimatedDialog(
      context: context,
      builder: (_) => Obx(() => AlertDialog(
            title: const Text('Edit Ingredient'),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: nameCtl, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: stockCtl, decoration: const InputDecoration(labelText: 'Stock Level'), keyboardType: TextInputType.numberWithOptions(decimal: true)),
              TextField(controller: unitCtl, decoration: const InputDecoration(labelText: 'Unit')),
            ]),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: c.savingIngredient.value
                    ? null
                    : () async {
                        final stock = double.tryParse(stockCtl.text.trim()) ?? 0;
                        await c.updateIngredient(ing.id, nameCtl.text.trim(), stock, unitCtl.text.trim());
                        if (context.mounted) Navigator.pop(context);
                      },
                child: c.savingIngredient.value
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save'),
              ),
            ],
          )),
    );
  }

  void _showAddMealDialog(BuildContext context, MenuManagementController c) {
    final nameCtl = TextEditingController();
    final priceCtl = TextEditingController();
    final descCtl = TextEditingController();
    final imageCtl = TextEditingController();
    String selectedCat = c.selectedCategoryId.value.isNotEmpty ? c.selectedCategoryId.value : '';
    final selectedIngredients = <String>{};

    _showAnimatedDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (ctx, setState) {
        return AlertDialog(
          title: const Text('Add Meal'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: nameCtl, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: priceCtl, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.numberWithOptions(decimal: true)),
              TextField(controller: descCtl, decoration: const InputDecoration(labelText: 'Description')),
              TextField(
                controller: imageCtl,
                decoration: InputDecoration(
                  labelText: 'Image URL',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.photo_library),
                    onPressed: () async {
                      final picker = ImagePicker();
                      final image = await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        imageCtl.text = image.path;
                      }
                    },
                  ),
                ),
              ),
              DropdownButtonFormField<String>(
                value: selectedCat,
                items: [
                  const DropdownMenuItem<String>(value: '', child: Text('Uncategorized')),
                  ...c.categories.map((e) => DropdownMenuItem<String>(value: e.id, child: Text(e.name))).toList(),
                ],
                onChanged: (v) { setState(() { selectedCat = v ?? ''; }); },
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 16),
              const Align(alignment: Alignment.centerLeft, child: Text('Ingredients:', style: TextStyle(fontWeight: FontWeight.bold))),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: c.ingredients.map((ing) {
                  final isSelected = selectedIngredients.contains(ing.id);
                  return FilterChip(
                    label: Text(ing.name),
                    selected: isSelected,
                    onSelected: (v) {
                      setState(() {
                        if (v) {
                          selectedIngredients.add(ing.id);
                        } else {
                          selectedIngredients.remove(ing.id);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            Obx(() => ElevatedButton(
                  onPressed: c.savingMeal.value
                      ? null
                      : () async {
                          final price = double.tryParse(priceCtl.text.trim()) ?? 0;
                          await c.addMeal(
                            name: nameCtl.text.trim(),
                            price: price,
                            description: descCtl.text.trim().isEmpty ? null : descCtl.text.trim(),
                            imageUrl: imageCtl.text.trim().isEmpty ? null : imageCtl.text.trim(),
                            categoryId: selectedCat.isEmpty ? null : selectedCat,
                            ingredientIds: selectedIngredients.toList(),
                          );
                          if (context.mounted) Navigator.pop(context);
                        },
                  child: c.savingMeal.value
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Save'),
                )),
          ],
        );
      }),
    );
  }

  void _showEditMealDialog(BuildContext context, MenuManagementController c, MealItem m) {
    final nameCtl = TextEditingController(text: m.name);
    final priceCtl = TextEditingController(text: m.price.toStringAsFixed(2));
    final descCtl = TextEditingController(text: m.description ?? '');
    final imageCtl = TextEditingController(text: m.imageUrl ?? '');
    String selectedCat = m.categoryId ?? '';
    
    final selectedIngredients = <String>{};
    bool ingredientsLoaded = false;

    _showAnimatedDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (ctx, setState) {
        if (!ingredientsLoaded) {
          c.fetchMealIngredients(m.id).then((list) {
             if (ctx.mounted) {
               setState(() {
                 selectedIngredients.addAll(list.map((e) => e.ingredientId));
                 ingredientsLoaded = true;
               });
             }
           });
        }

        return AlertDialog(
          title: const Text('Edit Meal'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              if (m.imageUrl != null && m.imageUrl!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Hero(
                    tag: 'meal_${m.imageUrl}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        m.imageUrl!,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
              TextField(controller: nameCtl, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: priceCtl, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.numberWithOptions(decimal: true)),
              TextField(controller: descCtl, decoration: const InputDecoration(labelText: 'Description')),
              TextField(
                controller: imageCtl,
                decoration: InputDecoration(
                  labelText: 'Image URL',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.photo_library),
                    onPressed: () async {
                      final picker = ImagePicker();
                      final image = await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        imageCtl.text = image.path;
                      }
                    },
                  ),
                ),
              ),
              DropdownButtonFormField<String>(
                value: selectedCat,
                items: [
                  const DropdownMenuItem<String>(value: '', child: Text('Uncategorized')),
                  ...c.categories.map((e) => DropdownMenuItem<String>(value: e.id, child: Text(e.name))).toList(),
                ],
                onChanged: (v) { setState(() { selectedCat = v ?? ''; }); },
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 16),
              const Align(alignment: Alignment.centerLeft, child: Text('Ingredients:', style: TextStyle(fontWeight: FontWeight.bold))),
              const SizedBox(height: 8),
              if (!ingredientsLoaded)
                const Center(child: CircularProgressIndicator())
              else
                Wrap(
                  spacing: 8,
                  children: c.ingredients.map((ing) {
                    final isSelected = selectedIngredients.contains(ing.id);
                    return FilterChip(
                      label: Text(ing.name),
                      selected: isSelected,
                      onSelected: (v) {
                        setState(() {
                          if (v) {
                            selectedIngredients.add(ing.id);
                          } else {
                            selectedIngredients.remove(ing.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(onPressed: () async {
              final price = double.tryParse(priceCtl.text.trim());
              await c.updateMeal(
                m,
                name: nameCtl.text.trim(),
                price: price,
                description: descCtl.text.trim(),
                imageUrl: imageCtl.text.trim(),
                categoryId: selectedCat.isEmpty ? null : selectedCat,
                ingredientIds: selectedIngredients.toList(),
              );
              Navigator.pop(context);
            }, child: const Text('Save')),
          ],
        );
      }),
    );
  }

  Future<void> _confirmDeleteCategory(BuildContext context, MenuManagementController c, Category cat) async {
    final confirmed = await _showDeleteConfirmation(
      context,
      title: 'Delete Category',
      message: 'Are you sure you want to delete "${cat.name}"? This action cannot be undone.',
    );
    if (confirmed) await c.deleteCategory(cat.id);
  }

  Future<void> _confirmDeleteMeal(BuildContext context, MenuManagementController c, MealItem meal) async {
    final confirmed = await _showDeleteConfirmation(
      context,
      title: 'Delete Meal',
      message: 'Are you sure you want to delete "${meal.name}"?',
    );
    if (confirmed) await c.deleteMeal(meal.id);
  }

  Future<void> _confirmDeleteIngredient(BuildContext context, MenuManagementController c, Ingredient ing) async {
    final confirmed = await _showDeleteConfirmation(
      context,
      title: 'Delete Ingredient',
      message: 'Are you sure you want to delete "${ing.name}"?',
    );
    if (confirmed) await c.deleteIngredient(ing.id);
  }

  Future<bool> _showDeleteConfirmation(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    final result = await _showAnimatedDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

class _CategoryFilter extends StatelessWidget {
  final MenuManagementController c;
  const _CategoryFilter({required this.c});
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final value = c.selectedCategoryId.value;
      return DropdownButtonFormField<String>(
        value: value,
        items: [
          const DropdownMenuItem<String>(value: '', child: Text('All Categories')),
          ...c.categories.map((e) {
            final color = _categoryColor(e.name);
            return DropdownMenuItem<String>(
              value: e.id,
              child: Row(children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(e.name),
              ]),
            );
          }).toList(),
        ],
        onChanged: (v) => c.setCategoryFilter(v),
        decoration: const InputDecoration(labelText: 'Filter'),
      );
    });
  }
}

final categoryPalette = {
  'Appetizers': Colors.orange,
  'Main Courses': Colors.blue,
  'Drinks': Colors.green,
  'Desserts': Colors.pink,
};
Color _categoryColor(String name) {
  final c = categoryPalette[name];
  if (c != null) return c;
  final h = name.codeUnits.fold<int>(0, (a, b) => a + b) % 360;
  return HSLColor.fromAHSL(1, h.toDouble(), 0.6, 0.5).toColor();
}
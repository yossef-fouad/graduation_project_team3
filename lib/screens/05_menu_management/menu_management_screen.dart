import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:order_pad/main.dart';
import 'package:order_pad/models/category.dart';
import 'package:order_pad/models/meal_item.dart';
import 'package:order_pad/widgets/meal_card.dart';
import 'package:order_pad/widgets/category_card.dart';

class MenuController extends GetxController {
  final RxList<Category> categories = <Category>[].obs;
  final RxList<MealItem> meals = <MealItem>[].obs;
  final RxBool loading = false.obs;
  final RxString selectedCategoryId = ''.obs;
  final RxBool loadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final int pageSize = 10;
  int mealOffset = 0;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchMeals(reset: true);
  }

  Future<void> fetchCategories() async {
    loading.value = true;
    final res = await cloud.from('categories').select().order('name');
    categories.assignAll((res as List).map((e) => Category.fromMap(e as Map<String, dynamic>)).toList());
    loading.value = false;
  }

  Future<void> fetchMeals({bool reset = false}) async {
    loading.value = true;
    if (reset) {
      mealOffset = 0;
      meals.clear();
      hasMore.value = true;
    }
    final from = mealOffset;
    final to = mealOffset + pageSize - 1;
    final base = cloud.from('meals').select();
    final filtered = selectedCategoryId.value.isNotEmpty
        ? base.eq('category_id', selectedCategoryId.value)
        : base;
    final res = await filtered.order('name').range(from, to);
    final fetched = (res as List).map((e) => MealItem.fromMap(e as Map<String, dynamic>)).toList();
    meals.addAll(fetched);
    mealOffset += fetched.length;
    hasMore.value = fetched.length == pageSize;
    loading.value = false;
  }

  Future<void> loadMoreMeals() async {
    if (!hasMore.value || loadingMore.value) return;
    loadingMore.value = true;
    final from = mealOffset;
    final to = mealOffset + pageSize - 1;
    final base = cloud.from('meals').select();
    final filtered = selectedCategoryId.value.isNotEmpty
        ? base.eq('category_id', selectedCategoryId.value)
        : base;
    final res = await filtered.order('name').range(from, to);
    final fetched = (res as List).map((e) => MealItem.fromMap(e as Map<String, dynamic>)).toList();
    meals.addAll(fetched);
    mealOffset += fetched.length;
    hasMore.value = fetched.length == pageSize;
    loadingMore.value = false;
  }

  Future<void> addCategory(String name) async {
    await cloud.from('categories').insert({'name': name});
    await fetchCategories();
  }

  Future<void> updateCategory(String id, String name) async {
    await cloud.from('categories').update({'name': name}).eq('id', id);
    await fetchCategories();
  }

  Future<void> deleteCategory(String id) async {
    await cloud.from('categories').delete().eq('id', id);
    if (selectedCategoryId.value == id) selectedCategoryId.value = '';
    await fetchCategories();
    await fetchMeals();
  }

  Future<void> addMeal({
    required String name,
    required double price,
    String? description,
    String? imageUrl,
    String? categoryId,
  }) async {
    await cloud.from('meals').insert({
      'name': name,
      'price': price,
      'description': description,
      'image_url': imageUrl,
      'category_id': categoryId,
      'is_available': true,
    });
    await fetchMeals(reset: true);
  }

  Future<void> updateMeal(
    MealItem meal, {
    String? name,
    double? price,
    String? description,
    String? imageUrl,
    String? categoryId,
    bool? isAvailable,
  }) async {
    final update = <String, dynamic>{};
    if (name != null) update['name'] = name;
    if (price != null) update['price'] = price;
    if (description != null) update['description'] = description;
    if (imageUrl != null) update['image_url'] = imageUrl;
    if (categoryId != null) update['category_id'] = categoryId;
    if (isAvailable != null) update['is_available'] = isAvailable;
    if (update.isEmpty) return;
    await cloud.from('meals').update(update).eq('id', meal.id);
    await fetchMeals(reset: true);
  }

  Future<void> deleteMeal(String id) async {
    await cloud.from('meals').delete().eq('id', id);
    await fetchMeals(reset: true);
  }

  void setCategoryFilter(String? id) {
    selectedCategoryId.value = id ?? '';
    fetchMeals(reset: true);
  }
}

class MenuManagementScreen extends StatelessWidget {
  const MenuManagementScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = Get.put(MenuController());
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Menu Management'),
          bottom: const TabBar(tabs: [Tab(text: 'Categories'), Tab(text: 'Meals')]),
        ),
        body: TabBarView(children: [
          Obx(() => Column(children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(children: [
                    ElevatedButton(onPressed: () => _showAddCategoryDialog(context, c), child: const Text('Add Category')),
                    const SizedBox(width: 12),
                    if (c.loading.value) const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                  ]),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: c.categories.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final cat = c.categories[i];
                      final color = _categoryColor(cat.name);
                      return CategoryCard(
                        name: cat.name,
                        accentColor: color,
                        onEdit: () => _showEditCategoryDialog(context, c, cat),
                        onDelete: () => c.deleteCategory(cat.id),
                      );
                    },
                  ),
                ),
              ])),
          Obx(() => Column(children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(children: [
                    Expanded(child: _CategoryFilter(c: c)),
                    const SizedBox(width: 12),
                    ElevatedButton(onPressed: () => _showAddMealDialog(context, c), child: const Text('Add Meal')),
                    const SizedBox(width: 12),
                    if (c.loading.value) const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                  ]),
                ),
                Expanded(
                  child: NotificationListener<ScrollNotification>(
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
                        final catName = c.categories
                          .firstWhere(
                            (x) => x.id == m.categoryId,
                            orElse: () => Category(id: '', name: 'Uncategorized'),
                          )
                          .name;
                        final catObj = c.categories.firstWhere(
                          (x) => x.name == catName,
                          orElse: () => Category(id: '', name: 'Uncategorized'),
                        );
                        final accent = catObj.id.isEmpty ? Colors.grey : _categoryColor(catObj.name);
                        return MealCard(
                          meal: m,
                          categoryName: catName,
                          accentColor: accent,
                          onEdit: () => _showEditMealDialog(context, c, m),
                          onToggleAvailable: () => c.updateMeal(m, isAvailable: !m.isAvailable),
                          onDelete: () => c.deleteMeal(m.id),
                        );
                      },
                    ),
                  ),
                ),
                Obx(() => c.loadingMore.value
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : const SizedBox.shrink()),
              ])),
        ]),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, MenuController c) {
    final nameCtl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Category'),
        content: TextField(controller: nameCtl, decoration: const InputDecoration(labelText: 'Name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () async { await c.addCategory(nameCtl.text.trim()); Navigator.pop(context); }, child: const Text('Save')),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(BuildContext context, MenuController c, Category cat) {
    final nameCtl = TextEditingController(text: cat.name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Category'),
        content: TextField(controller: nameCtl, decoration: const InputDecoration(labelText: 'Name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () async { await c.updateCategory(cat.id, nameCtl.text.trim()); Navigator.pop(context); }, child: const Text('Save')),
        ],
      ),
    );
  }

  void _showAddMealDialog(BuildContext context, MenuController c) {
    final nameCtl = TextEditingController();
    final priceCtl = TextEditingController();
    final descCtl = TextEditingController();
    final imageCtl = TextEditingController();
    String selectedCat = c.selectedCategoryId.value.isNotEmpty ? c.selectedCategoryId.value : '';
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (ctx, setState) {
        return AlertDialog(
          title: const Text('Add Meal'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: nameCtl, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: priceCtl, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.numberWithOptions(decimal: true)),
              TextField(controller: descCtl, decoration: const InputDecoration(labelText: 'Description')),
              TextField(controller: imageCtl, decoration: const InputDecoration(labelText: 'Image URL')),
              DropdownButtonFormField<String>(
                value: selectedCat,
                items: [
                  const DropdownMenuItem<String>(value: '', child: Text('Uncategorized')),
                  ...c.categories.map((e) => DropdownMenuItem<String>(value: e.id, child: Text(e.name))).toList(),
                ],
                onChanged: (v) { setState(() { selectedCat = v ?? ''; }); },
                decoration: const InputDecoration(labelText: 'Category'),
              ),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(onPressed: () async {
              final price = double.tryParse(priceCtl.text.trim()) ?? 0;
              await c.addMeal(
                name: nameCtl.text.trim(),
                price: price,
                description: descCtl.text.trim().isEmpty ? null : descCtl.text.trim(),
                imageUrl: imageCtl.text.trim().isEmpty ? null : imageCtl.text.trim(),
                categoryId: selectedCat.isEmpty ? null : selectedCat,
              );
              Navigator.pop(context);
            }, child: const Text('Save')),
          ],
        );
      }),
    );
  }

  void _showEditMealDialog(BuildContext context, MenuController c, MealItem m) {
    final nameCtl = TextEditingController(text: m.name);
    final priceCtl = TextEditingController(text: m.price.toStringAsFixed(2));
    final descCtl = TextEditingController(text: m.description ?? '');
    final imageCtl = TextEditingController(text: m.imageUrl ?? '');
    String selectedCat = m.categoryId ?? '';
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (ctx, setState) {
        return AlertDialog(
          title: const Text('Edit Meal'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: nameCtl, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: priceCtl, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.numberWithOptions(decimal: true)),
              TextField(controller: descCtl, decoration: const InputDecoration(labelText: 'Description')),
              TextField(controller: imageCtl, decoration: const InputDecoration(labelText: 'Image URL')),
              DropdownButtonFormField<String>(
                value: selectedCat,
                items: [
                  const DropdownMenuItem<String>(value: '', child: Text('Uncategorized')),
                  ...c.categories.map((e) => DropdownMenuItem<String>(value: e.id, child: Text(e.name))).toList(),
                ],
                onChanged: (v) { setState(() { selectedCat = v ?? ''; }); },
                decoration: const InputDecoration(labelText: 'Category'),
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
              );
              Navigator.pop(context);
            }, child: const Text('Save')),
          ],
        );
      }),
    );
  }
}

 

class _CategoryFilter extends StatelessWidget {
  final MenuController c;
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
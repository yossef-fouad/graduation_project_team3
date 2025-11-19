// chefimport 'package:flutter/material.dart' hide MenuController;
// import 'package:get/get.dart';
// import '../../Category Model.dart';
// import '../../Meal Item Model.dart';
// import '../controllers/menu_controller.dart';
// import '../widgets/meal_image.dart';
// import '../widgets/category_filter.dart';
//
//
// class MenuManagementScreen extends StatelessWidget {
//   const MenuManagementScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final c = Get.find<MenuController>();
//
//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('إدارة المنيو', style: TextStyle(fontWeight: FontWeight.bold)),
//           centerTitle: true,
//           backgroundColor: Theme.of(context).colorScheme.primary,
//           foregroundColor: Colors.white,
//           bottom: const TabBar(tabs: [Tab(text: 'الأصناف'), Tab(text: 'الوجبات')], indicatorColor: Colors.white),
//         ),
//         body: TabBarView(children: [
//           Obx(() => Column(children: [
//             Padding(
//               padding: const EdgeInsets.all(12),
//               child: Row(children: [
//                 ElevatedButton.icon(
//                   onPressed: () => _showAddCategoryDialog(context, c),
//                   icon: const Icon(Icons.add),
//                   label: const Text('إضافة صنف'),
//                 ),
//                 const SizedBox(width: 12),
//                 if (c.loading.value) const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
//               ]),
//             ),
//             Expanded(
//               child: ListView.separated(
//                 itemCount: c.categories.length,
//                 separatorBuilder: (_, __) => const Divider(height: 1),
//                 itemBuilder: (_, i) {
//                   final cat = c.categories[i];
//                   return ListTile(
//                     title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w500)),
//                     trailing: Row(mainAxisSize: MainAxisSize.min, children: [
//                       IconButton(onPressed: () => _showEditCategoryDialog(context, c, cat), icon: const Icon(Icons.edit, color: Colors.blue)),
//                       IconButton(onPressed: () => c.deleteCategory(cat.id), icon: const Icon(Icons.delete, color: Colors.red)),
//                     ]),
//                   );
//                 },
//               ),
//             ),
//           ])),
//           Obx(() => Column(children: [
//             Padding(
//               padding: const EdgeInsets.all(12),
//               child: Row(children: [
//                 Expanded(child: CategoryFilter(c: c, isFilteringCustomerView: false)),
//                 const SizedBox(width: 12),
//                 ElevatedButton.icon(
//                   onPressed: () => _showAddMealDialog(context, c),
//                   icon: const Icon(Icons.add),
//                   label: const Text('إضافة وجبة'),
//                 ),
//                 const SizedBox(width: 12),
//                 if (c.loading.value) const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
//               ]),
//             ),
//             Expanded(
//               child: ListView.separated(
//                 itemCount: c.meals.length,
//                 separatorBuilder: (_, __) => const Divider(height: 1),
//                 itemBuilder: (_, i) {
//                   final m = c.meals[i];
//                   final catName = c.categories.firstWhereOrNull((x) => x.id == m.categoryId)?.name ?? 'غير مصنفة';
//                   return ListTile(
//                     leading: MealImage(url: m.imageUrl),
//                     title: Text(m.name,
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: m.isAvailable ? Colors.black : Colors.grey,
//                       ),
//                     ),
//                     subtitle: Text('$catName | ${m.price.toStringAsFixed(2)} \$',
//                       style: TextStyle(color: Theme.of(context).colorScheme.primary),
//                     ),
//                     trailing: Row(mainAxisSize: MainAxisSize.min, children: [
//                       IconButton(
//                         onPressed: () => c.updateMeal(m, isAvailable: !m.isAvailable),
//                         icon: Icon(m.isAvailable ? Icons.visibility : Icons.visibility_off,
//                             color: m.isAvailable ? Theme.of(context).colorScheme.primary : Colors.redAccent),
//                       ),
//                       IconButton(onPressed: () => _showEditMealDialog(context, c, m), icon: const Icon(Icons.edit, color: Colors.blue)),
//                       IconButton(onPressed: () => c.deleteMeal(m.id), icon: const Icon(Icons.delete, color: Colors.red)),
//                     ]),
//                   );
//                 },
//               ),
//             ),
//           ])),
//         ]),
//       ),
//     );
//   }
//
//   void _showAddCategoryDialog(BuildContext context, MenuController c) {
//     final nameCtl = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('إضافة صنف جديد'),
//         content: TextField(controller: nameCtl, decoration: const InputDecoration(labelText: 'اسم الصنف', border: OutlineInputBorder())),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
//           ElevatedButton(onPressed: () async {
//             await c.addCategory(nameCtl.text.trim());
//             Navigator.pop(context);
//           }, child: const Text('حفظ')),
//         ],
//       ),
//     );
//   }
//
//   void _showEditCategoryDialog(BuildContext context, MenuController c, Category cat) {
//     final nameCtl = TextEditingController(text: cat.name);
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('تعديل الصنف'),
//         content: TextField(controller: nameCtl, decoration: const InputDecoration(labelText: 'اسم الصنف', border: OutlineInputBorder())),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
//           ElevatedButton(onPressed: () async {
//             await c.updateCategory(cat.id, nameCtl.text.trim());
//             Navigator.pop(context);
//           }, child: const Text('حفظ التعديل')),
//         ],
//       ),
//     );
//   }
//
//   void _showAddMealDialog(BuildContext context, MenuController c) {
//     final nameCtl = TextEditingController();
//     final priceCtl = TextEditingController();
//     final descCtl = TextEditingController();
//     final imageCtl = TextEditingController();
//     String? selectedCat = c.selectedCategoryId.value.isNotEmpty ? c.selectedCategoryId.value : null;
//
//     showDialog(
//       context: context,
//       builder: (_) => StatefulBuilder(builder: (ctx, setState) {
//         return AlertDialog(
//           title: const Text('إضافة وجبة جديدة'),
//           content: SingleChildScrollView(
//             child: Column(mainAxisSize: MainAxisSize.min, children: [
//               TextField(controller: nameCtl, decoration: const InputDecoration(labelText: 'اسم الوجبة', border: OutlineInputBorder())),
//               const SizedBox(height: 10),
//               TextField(
//                 controller: priceCtl,
//                 decoration: const InputDecoration(labelText: 'السعر (\$)', border: OutlineInputBorder()),
//                 keyboardType: const TextInputType.numberWithOptions(decimal: true),
//               ),
//               const SizedBox(height: 10),
//               TextField(controller: descCtl, decoration: const InputDecoration(labelText: 'الوصف', border: OutlineInputBorder()), maxLines: 2),
//               const SizedBox(height: 10),
//               TextField(controller: imageCtl, decoration: const InputDecoration(labelText: 'رابط الصورة (URL)', border: OutlineInputBorder())),
//               const SizedBox(height: 10),
//               DropdownButtonFormField<String?>(
//                 value: selectedCat,
//                 decoration: const InputDecoration(labelText: 'الصنف', border: OutlineInputBorder()),
//                 items: [
//                   const DropdownMenuItem<String?>(value: null, child: Text('غير مصنفة')),
//                   ...c.categories.map((e) => DropdownMenuItem<String>(value: e.id, child: Text(e.name))),
//                 ],
//                 onChanged: (String? newValue) {
//                   setState(() {
//                     selectedCat = newValue;
//                   });
//                 },
//               ),
//             ]),
//           ),
//           actions: [
//             TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
//             ElevatedButton(onPressed: () async {
//               final name = nameCtl.text.trim();
//               final price = double.tryParse(priceCtl.text.trim()) ?? 0.0;
//               if (name.isNotEmpty && price > 0) {
//                 await c.addMeal(
//                   name: name,
//                   price: price,
//                   description: descCtl.text.trim(),
//                   imageUrl: imageCtl.text.trim(),
//                   categoryId: selectedCat,
//                 );
//                 Navigator.pop(context);
//               }
//             }, child: const Text('إضافة الوجبة')),
//           ],
//         );
//       }),
//     );
//   }
//
//   void _showEditMealDialog(BuildContext context, MenuController c, MealItem meal) {
//     final nameCtl = TextEditingController(text: meal.name);
//     final priceCtl = TextEditingController(text: meal.price.toString());
//     final descCtl = TextEditingController(text: meal.description);
//     final imageCtl = TextEditingController(text: meal.imageUrl);
//     String? selectedCat = meal.categoryId;
//
//     showDialog(
//       context: context,
//       builder: (_) => StatefulBuilder(builder: (ctx, setState) {
//         return AlertDialog(
//           title: Text('تعديل الوجبة: ${meal.name}'),
//           content: SingleChildScrollView(
//             child: Column(mainAxisSize: MainAxisSize.min, children: [
//               TextField(controller: nameCtl, decoration: const InputDecoration(labelText: 'اسم الوجبة', border: OutlineInputBorder())),
//               const SizedBox(height: 10),
//               TextField(
//                 controller: priceCtl,
//                 decoration: const InputDecoration(labelText: 'السعر (\$)', border: OutlineInputBorder()),
//                 keyboardType: const TextInputType.numberWithOptions(decimal: true),
//               ),
//               const SizedBox(height: 10),
//               TextField(controller: descCtl, decoration: const InputDecoration(labelText: 'الوصف', border: OutlineInputBorder()), maxLines: 2),
//               const SizedBox(height: 10),
//               TextField(controller: imageCtl, decoration: const InputDecoration(labelText: 'رابط الصورة (URL)', border: OutlineInputBorder())),
//               const SizedBox(height: 10),
//               DropdownButtonFormField<String?>(
//                 value: selectedCat,
//                 decoration: const InputDecoration(labelText: 'الصنف', border: OutlineInputBorder()),
//                 items: [
//                   const DropdownMenuItem<String?>(value: null, child: Text('غير مصنفة')),
//                   ...c.categories.map((e) => DropdownMenuItem<String>(value: e.id, child: Text(e.name))),
//                 ],
//                 onChanged: (String? newValue) {
//                   setState(() {
//                     selectedCat = newValue;
//                   });
//                 },
//               ),
//             ]),
//           ),
//           actions: [
//             TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
//             ElevatedButton(onPressed: () async {
//               final name = nameCtl.text.trim();
//               final price = double.tryParse(priceCtl.text.trim()) ?? 0.0;
//               if (name.isNotEmpty && price > 0) {
//                 await c.updateMeal(
//                   meal,
//                   name: name,
//                   price: price,
//                   description: descCtl.text.trim(),
//                   imageUrl: imageCtl.text.trim(),
//                   categoryId: selectedCat,
//                 );
//                 Navigator.pop(context);
//               }
//             }, child: const Text('حفظ التعديل')),
//           ],
//         );
//       }),
//     );
//   }
// }

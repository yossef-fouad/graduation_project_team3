import 'package:order_pad/models/meal_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:order_pad/models/category.dart';


final cloud = Supabase.instance.client;


class TopSellingMeal {
  final MealItem meal;
  final int count;
  final String? categoryName;

  TopSellingMeal({
    required this.meal,
    required this.count,
    this.categoryName,
  });
}

class DashboardService {
  Future<List<Category>> getCategories() async {
    final res = await cloud.from('categories').select().order('name');
    return (res as List).map((e) => Category.fromMap(e)).toList();
  }

  Future<List<TopSellingMeal>> getTopSellingMeals({
    int page = 0, 
    int pageSize = 10,
    String? categoryId,
  }) async {
    final from = page * pageSize;
    final to = from + pageSize - 1;

    dynamic query = cloud.from('view_meal_sales').select();

    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }

    query = query.order('total_sold', ascending: false);

    final res = await query.range(from, to);

    return (res as List).map((e) {
      return TopSellingMeal(
        meal: MealItem(
          id: e['meal_id'],
          name: e['meal_name'],
          price: (e['meal_price'] as num).toDouble(),
          imageUrl: e['meal_image_url'],
          isAvailable: true,
          categoryId: e['category_id'],
        ),
        count: (e['total_sold'] as num).toInt(),
        categoryName: e['category_name'],
      );
    }).toList();
  }
}

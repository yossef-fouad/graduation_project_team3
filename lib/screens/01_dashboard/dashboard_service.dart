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
  // DATA SOURCE: Fetches all categories from the 'categories' table in Supabase, ordered by name.
  Future<List<Category>> getCategories() async {
    final res = await cloud.from('categories').select().order('name');
    return (res as List).map((e) => Category.fromMap(e)).toList();
  }

  // DATA SOURCE: Fetches sales data from the 'view_meal_sales' view in Supabase.
  // Supports pagination (page/pageSize) and filtering by categoryId.
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

  Future<Map<String, double>> getDashboardStats() async {
    // Fetch all sales data to aggregate
    // Note: In a production app with large data, this aggregation should be done on the server (RPC or View).
    final res = await cloud.from('view_meal_sales').select();
    
    double totalSales = 0;
    double totalRevenue = 0;

    for (var e in (res as List)) {
      final count = (e['total_sold'] as num).toInt();
      final price = (e['meal_price'] as num).toDouble();
      totalSales += count;
      totalRevenue += count * price;
    }

    return {
      'totalSales': totalSales,
      'totalRevenue': totalRevenue,
    };
  }
}

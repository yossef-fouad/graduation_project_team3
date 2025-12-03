import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:order_pad/controllers/home_controller.dart';
import 'package:order_pad/models/category.dart';
import 'package:order_pad/screens/01_dashboard/dashboard_screen.dart';
import 'package:order_pad/screens/02_new_order/category_meals_page.dart';
import 'package:order_pad/services/cart_controller.dart';
import 'package:order_pad/widgets/animated_cart_badge.dart';
import 'package:order_pad/widgets/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:order_pad/screens/role_selection_screen.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());
    Get.put(CartController());

    List<String> banners = [
      "assets/banners/Slider 1.png",
      "assets/banners/Slider 2.png",
      "assets/banners/Slider 3.png",
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: SizedBox.shrink(),
        leadingWidth: 0,
        title: Row(
          children: [
            SvgPicture.asset("assets/icons/motor.svg"),
            SizedBox(width: 10),
            Text(
              "Order Pad",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                color: AppColors.primary,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(width: 10),
            GestureDetector(
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('user_role');
                Get.offAll(() => const RoleSelectionScreen());
              },
              child: Icon(Icons.logout, size: 24, color: Colors.red),
            ),
            Spacer(),
            const AnimatedCartBadge(),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Carousel
            CarouselSlider.builder(
              itemCount: banners.length,
              itemBuilder:
                  (BuildContext context, int itemIndex, int pageViewIndex) =>
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          banners[itemIndex],
                          fit: BoxFit.cover,
                        ),
                      ),
              options: CarouselOptions(
                height: 170,
                aspectRatio: 16 / 9,
                viewportFraction: 0.85,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 4),
                autoPlayAnimationDuration: Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: true,
                enlargeFactor: 0.2,
              ),
            ),

            SizedBox(height: 24),

            // Categories Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Categories',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            SizedBox(height: 16),

            // Categories List
            Obx(() {
              final isLoading = controller.isLoading.value;
              final categories =
                  isLoading
                      ? List.generate(
                        5,
                        (index) => Category(
                          id: 'dummy_$index',
                          name: 'Category Name',
                          imageUrl: '',
                        ),
                      )
                      : controller.categories;

              if (controller.error.isNotEmpty) {
                return Container(
                  height: 120,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 40),
                      SizedBox(height: 8),
                      Text(
                        'Error loading categories',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                );
              }

              if (!isLoading && categories.isEmpty) {
                return Container(
                  height: 120,
                  alignment: Alignment.center,
                  child: Text(
                    'No categories available',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                );
              }

              return Skeletonizer(
                enabled: isLoading,
                child: SizedBox(
                  height: 140,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            if (!isLoading) {
                              Get.to(
                                () => CategoryMealsPage(category: category),
                              );
                            }
                          },
                          child: Container(
                            width: 110,
                            child: Column(
                              children: [
                                // Modern card with image or gradient
                                Container(
                                  width: 110,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 12,
                                        offset: Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(18),
                                    child:
                                        category.imageUrl != null &&
                                                category.imageUrl!.isNotEmpty
                                            ? Stack(
                                              fit: StackFit.expand,
                                              children: [
                                                // Category image
                                                Image.network(
                                                  category.imageUrl!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) {
                                                    // Fallback to gradient on error
                                                    return Container(
                                                      decoration: BoxDecoration(
                                                        gradient: LinearGradient(
                                                          colors: [
                                                            AppColors.primary
                                                                .withOpacity(
                                                                  0.8,
                                                                ),
                                                            AppColors.secondary
                                                                .withOpacity(
                                                                  0.8,
                                                                ),
                                                          ],
                                                          begin:
                                                              Alignment.topLeft,
                                                          end:
                                                              Alignment
                                                                  .bottomRight,
                                                        ),
                                                      ),
                                                      child: Center(
                                                        child: Icon(
                                                          Icons.restaurant_menu,
                                                          size: 40,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  loadingBuilder: (
                                                    context,
                                                    child,
                                                    loadingProgress,
                                                  ) {
                                                    if (loadingProgress == null)
                                                      return child;
                                                    return Container(
                                                      decoration: BoxDecoration(
                                                        gradient: LinearGradient(
                                                          colors: [
                                                            AppColors.primary
                                                                .withOpacity(
                                                                  0.3,
                                                                ),
                                                            AppColors.secondary
                                                                .withOpacity(
                                                                  0.3,
                                                                ),
                                                          ],
                                                        ),
                                                      ),
                                                      child: Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                              color:
                                                                  AppColors
                                                                      .primary,
                                                              strokeWidth: 2,
                                                            ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                                // Gradient overlay for text readability
                                                Container(
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      begin:
                                                          Alignment.topCenter,
                                                      end:
                                                          Alignment
                                                              .bottomCenter,
                                                      colors: [
                                                        Colors.transparent,
                                                        Colors.black
                                                            .withOpacity(0.7),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                            : // Fallback gradient design
                                            Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    AppColors.primary
                                                        .withOpacity(0.8),
                                                    AppColors.secondary
                                                        .withOpacity(0.8),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  Icons.restaurant_menu,
                                                  size: 40,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                // Category name
                                Text(
                                  category.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }),

            SizedBox(height: 24),

            // Welcome Message
            GestureDetector(
              onTap: () {
                Get.back();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.1),
                        AppColors.secondary.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => const DashboardScreen());
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome to Order Pad! 👋',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Browse our categories and add your favorite meals to the cart.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

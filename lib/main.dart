import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:order_pad/screens/01_dashboard/dashboard_screen.dart';
import 'package:order_pad/screens/02_new_order/cart_page.dart';
import 'package:order_pad/screens/02_new_order/category_meals_page.dart';
import 'package:order_pad/screens/main_navigation_screen.dart';

// ... imports

import 'package:supabase_flutter/supabase_flutter.dart';

//test
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://bdizroznvlkmtpojsjbq.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJkaXpyb3pudmxrbXRwb2pzamJxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI4NjIwMzYsImV4cCI6MjA3ODQzODAzNn0.6Unw-qyYdtVvVG8fXLj8c2HpE5UzT2CKd8_Z6EtdnbU',
  );
  runApp(const MyApp());
}

final cloud = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.native,
      transitionDuration: const Duration(milliseconds: 500),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF056B4C),
        ).copyWith(
          secondary: const Color(0xFFE59D1B),
          tertiary: const Color(0xFF9FCCD5),
          error: const Color(0xFFD32F2F),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CustomPageTransitionBuilder(),
            TargetPlatform.iOS: CustomPageTransitionBuilder(),
            TargetPlatform.windows: CustomPageTransitionBuilder(),
          },
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class CustomPageTransitionBuilder extends PageTransitionsBuilder {
  const CustomPageTransitionBuilder();
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutQuart)),
      child: child,
    );
  }
}

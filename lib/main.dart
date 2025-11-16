import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:order_pad/screens/05_menu_management/menu_management_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: 'https://bdizroznvlkmtpojsjbq.supabase.co', anonKey:
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJkaXpyb3pudmxrbXRwb2pzamJxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI4NjIwMzYsImV4cCI6MjA3ODQzODAzNn0.6Unw-qyYdtVvVG8fXLj8c2HpE5UzT2CKd8_Z6EtdnbU');
  runApp(const MyApp());

}
final cloud = Supabase.instance.client;
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF056B4C)).copyWith(
          secondary: const Color(0xFFE59D1B),
          tertiary: const Color(0xFF9FCCD5),
          error: const Color(0xFFD32F2F),
        ),
      ),
      home: MenuManagementScreen(),
    );
  }
}
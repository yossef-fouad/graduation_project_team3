import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:order_pad/screens/02_new_order/new_order_screen.dart';
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
    return GetMaterialApp(home:NewOrderScreen()
    );
  }
}
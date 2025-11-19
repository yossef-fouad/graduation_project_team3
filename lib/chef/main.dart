// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'screens/customer_menu_screen.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Supabase.initialize(
//     url: 'https://bdizroznvlkmtpojsjbq.supabase.co',
//     anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJkaXpyb3pudmxrbXRwb2pzamJxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI4NjIwMzYsImV4cCI6MjA3ODQzODAzNn0.6Unw-qyYdtVvVG8fXLj8c2HpE5UzT2CKd8_Z6EtdnbU',
//   );
//   runApp(const MainApp());
// }
//
// class MainApp extends StatelessWidget {
//   const MainApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'نظام إدارة المطعم',
//       builder: (context, child) {
//         return Directionality(
//           textDirection: TextDirection.rtl,
//           child: child!,
//         );
//       },
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B5E20)),
//         useMaterial3: true,
//       ),
//       home: const CustomerMenuScreen(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:liquid_navbar/liquid_navbar.dart';
import 'package:order_pad/screens/01_dashboard/dashboard_screen.dart';
import 'package:order_pad/screens/02_new_order/home_page.dart';
import 'package:order_pad/screens/05_menu_management/menu_management_screen.dart';

class CoolScreen extends StatelessWidget {
  const CoolScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavScaffold(pages:
        //pages to show
     [
     MenuManagementScreen(),
       DashboardScreen(),
       HomePage(),
    ],
      // Navbar icons
      icons: const [
        Icon(Icons.menu_book_rounded),
        Icon(Icons.dashboard_rounded),
        Icon(Icons.home_rounded),
      ],
      // Labels
      labels: const [
        'Menu',
        'Dashboard',
        'Home',
      ],
      navbarHeight: 70,
      indicatorWidth: 70,
      bottomPadding: 16,
      selectedColor: Colors.green.shade600,
      unselectedColor: Colors.grey.shade600,
      horizontalPadding: 16,
    );
  }
}

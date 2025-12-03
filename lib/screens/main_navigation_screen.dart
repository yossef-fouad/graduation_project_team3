import 'package:flutter/material.dart';

import 'package:order_pad/screens/02_new_order/home_page.dart';
import 'package:order_pad/screens/04_order_history/order_history_screen.dart';
import 'package:order_pad/screens/02_new_order/cart_page.dart';
import 'package:get/get.dart';
import 'package:order_pad/widgets/colors.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomePage(),
    const OrderHistoryScreen(),
    CartPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
              child: child,
            ),
          );
        },
        child: Container(
          key: ValueKey<int>(_currentIndex),
          child: _screens[_currentIndex],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Colors.grey[400],
            selectedFontSize: 12,
            unselectedFontSize: 11,
            elevation: 0,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            items: [
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        _currentIndex == 0
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.home_rounded, size: 26),
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        _currentIndex == 1
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.history_rounded, size: 26),
                ),
                label: 'History',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        _currentIndex == 2
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.shopping_cart_rounded, size: 26),
                ),
                label: 'Cart',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

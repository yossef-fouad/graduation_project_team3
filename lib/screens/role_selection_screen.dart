import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:order_pad/screens/01_dashboard/dashboard_screen.dart';
import 'package:order_pad/screens/03_active_orders/active_orders_screen.dart';
import 'package:order_pad/screens/main_navigation_screen.dart';
import 'package:order_pad/widgets/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
               Text(
                'Welcome to OrderPad',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Please select your role to continue',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const Spacer(),
              _RoleCard(
                title: 'Waiter',
                description: 'Take orders and manage tables',
                icon: Icons.restaurant_menu,
                color: AppColors.primary,
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('user_role', 'waiter');
                  Get.offAll(() => const MainNavigationScreen());
                },
              ),
              const SizedBox(height: 16),
              _RoleCard(
                title: 'Chef',
                description: 'View and manage active orders',
                icon: Icons.kitchen,
                color: Colors.orange,
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('user_role', 'chef');
                  Get.offAll(() => ActiveOrdersScreen());
                },
              ),
              const SizedBox(height: 16),
              _RoleCard(
                title: 'Owner',
                description: 'View dashboard and analytics',
                icon: Icons.analytics,
                color: Colors.blue,
                onTap: () => _showLoginDialog(context),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  void _showLoginDialog(BuildContext context) {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Admin Login'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (usernameController.text == 'admin' &&
                  passwordController.text == '1234') {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('user_role', 'owner');
                Get.back(); // Close dialog
                Get.offAll(() => DashboardScreen());
              } else {
                Get.snackbar(
                  'Error',
                  'Invalid credentials',
                  backgroundColor: Colors.red.withOpacity(0.1),
                  colorText: Colors.red,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

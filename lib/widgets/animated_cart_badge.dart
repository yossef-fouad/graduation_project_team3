import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:order_pad/screens/02_new_order/cart_page.dart';
import 'package:order_pad/services/cart_controller.dart';
import 'package:order_pad/widgets/colors.dart';

class AnimatedCartBadge extends StatefulWidget {
  const AnimatedCartBadge({super.key});

  @override
  State<AnimatedCartBadge> createState() => _AnimatedCartBadgeState();
}

class _AnimatedCartBadgeState extends State<AnimatedCartBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  int _previousItemCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.5), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.5, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(
      builder: (controller) {
        // Trigger animation if item count increased
        if (controller.totalItems > _previousItemCount) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_controller.status != AnimationStatus.forward) {
               _controller.forward(from: 0.0);
            }
          });
        }
        _previousItemCount = controller.totalItems;

        return IconButton(
          onPressed: () {
            Get.to(
              () => const CartPage(),
              transition: Transition.cupertino,
              duration: const Duration(milliseconds: 500),
            );
          },
          icon: Stack(
            children: [
              const Icon(Icons.shopping_cart, size: 28),
              if (controller.totalItems > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        controller.totalItems.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

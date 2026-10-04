import 'package:flutter/material.dart';
import 'package:lib/core/constants/app_color.dart';

class PlantsWidget extends StatelessWidget {
  final VoidCallback? onTap;

  const PlantsWidget({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        constraints: const BoxConstraints(
          minHeight: 120,
          maxHeight: 160,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.lightGreen,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            const Text(
              '!نباتاتك',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            ImageIcon(
              AssetImage('assets/home_screen_and_navigation_icons/map_pin.png'),
              color: Colors.white,
              size: 50,
            ),
          ],
        ),
      ),
    );
  }
}

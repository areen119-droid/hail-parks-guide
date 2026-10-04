import 'package:flutter/material.dart';
import 'package:lib/core/constants/app_color.dart';

class FactsWidget extends StatelessWidget {
  final VoidCallback? onTap;

  const FactsWidget({
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
          color: AppColors.tealGreen,
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
            const SizedBox(height:10),
            const Text(
              'الحقائق',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),

             ImageIcon(
               AssetImage('assets/home_screen_and_navigation_icons/open_book.png'),
               color: Colors.white,
               size: 50,
             ),

          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hail_parks_guide/app/theme.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';
import 'package:hail_parks_guide/core/widgets/custom_button.dart';
import 'package:hail_parks_guide/features/navigation/bottom_nav_bar.dart';

/// Welcome screen shown when the app opens.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/welcome_bg.jpg', fit: BoxFit.cover),
          // Sand fade at the top for the title, dark fade at the bottom.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.sandLight,
                  Color(0xCCF3E8DC),
                  Color(0x00F3E8DC),
                  Color(0x00000000),
                  Color(0xB3000000),
                ],
                stops: [0.0, 0.25, 0.5, 0.7, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
              child: Column(
                children: [
                  const Text(
                    'هيا نستكشف حائل',
                    style: TextStyle(
                      fontFamily: AppText.headingFont,
                      fontSize: 22,
                      color: AppColors.brownMedium,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'اكتشف أجمل\nحدائق حائل',
                    textAlign: TextAlign.center,
                    style: AppText.display,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'حدائق ومتنزهات حائل وأجمل معالمها\nفي دليل واحد',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.brownMedium,
                      height: 1.5,
                    ),
                  ),
                  const Spacer(),
                  PrimaryButton(
                    label: 'ابدأ الاستكشاف',
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const MainNavigation()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

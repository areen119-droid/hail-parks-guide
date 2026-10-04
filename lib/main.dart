import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';
import 'package:hail_parks_guide/core/splashScreen/splash_screen.dart';
import 'package:hail_parks_guide/features/navigation/bottom_nav_bar.dart';
import 'package:hail_parks_guide/providers/favorites_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => FavoritesProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'دليل حدائق حائل',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Cairo',
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.darkGreen),
        scaffoldBackgroundColor: AppColors.creamBackground,
      ),
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const MainNavigation(),
      },
    );
  }
}

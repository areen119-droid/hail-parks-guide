import 'package:flutter/material.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';

/// Fonts: Amiri (serif) for headings, Tajawal for everything else.
class AppText {
  static const String headingFont = 'Amiri';
  static const String bodyFont = 'Tajawal';

  static const TextStyle display = TextStyle(
    fontFamily: headingFont,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle title = TextStyle(
    fontFamily: headingFont,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle section = TextStyle(
    fontFamily: bodyFont,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontFamily: bodyFont,
    fontSize: 15,
    color: AppColors.textPrimary,
    height: 1.7,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: bodyFont,
    fontSize: 13,
    color: AppColors.textSecondary,
  );
}

ThemeData buildAppTheme() {
  return ThemeData(
    fontFamily: AppText.bodyFont,
    scaffoldBackgroundColor: AppColors.sandLight,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.brown,
      primary: AppColors.brown,
      surface: AppColors.cream,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: AppColors.textPrimary,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: AppText.headingFont,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brown,
        foregroundColor: AppColors.white,
        elevation: 0,
        minimumSize: const Size.fromHeight(56),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(
          fontFamily: AppText.bodyFont,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.brown,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

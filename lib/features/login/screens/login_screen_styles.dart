import 'package:flutter/material.dart';
import 'package:lib/core/constants/app_color.dart';

// Signup Screen Styles - Arabic
class SignupScreenStyles {
  static const TextStyle forgotPasswordStyles = TextStyle(
    color: AppColors.baseLightGreenColor,
    fontSize: 18,
  );

  static const TextStyle signinSocialStyles = TextStyle(
    color: AppColors.baseLightGreenColor,
  );

  static const TextStyle signupButtonTextStyles = TextStyle(
    color: AppColors.baseLightGreenColor,
    fontSize: 20,
  );

  static TextStyle? signInAgreeStyle = const TextStyle(
    color: AppColors.baseBlackColor,
    fontSize: 12,
  );

  static TextStyle? termsTextStyle = const TextStyle(
    color: AppColors.baseDarkGreenColor,
    fontSize: 12,
    fontWeight: FontWeight.bold,
    decoration: TextDecoration.underline,
  );

  static TextStyle? andTextStyle = const TextStyle(
    color: AppColors.baseBlackColor,
    fontSize: 12,
  );
}
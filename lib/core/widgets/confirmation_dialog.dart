import 'package:flutter/material.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';

/// Asks the user to confirm an action. Returns true if they confirmed.
Future<bool> showConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.cream,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('إلغاء',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmLabel,
              style: const TextStyle(
                  color: AppColors.error, fontWeight: FontWeight.w700)),
        ),
      ],
    ),
  );
  return result ?? false;
}

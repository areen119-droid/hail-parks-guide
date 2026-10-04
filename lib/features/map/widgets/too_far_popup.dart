import 'package:flutter/material.dart';

class TooFarPopup extends StatelessWidget {
  final double distanceMeters;

  const TooFarPopup({super.key, required this.distanceMeters});

  @override
  Widget build(BuildContext context) {
    final meters = distanceMeters.toStringAsFixed(0);

    return Dialog(
      backgroundColor: const Color(0xFFE9E8E1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFD9EDD4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_off_outlined,
                size: 38,
                color: Color(0xFF0F6A3B),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'أنت بعيد جداً!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F6A3B),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'أنت على بُعد $meters متر من هذا الموقع.\nيجب أن تكون على بُعد 50 متر أو أقل.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Color(0xFF444444),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'اقترب أكثر وحاول مجدداً',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF888888),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F6A3B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                child: const Text('حسناً'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

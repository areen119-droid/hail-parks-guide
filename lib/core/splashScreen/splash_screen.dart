import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:hail_parks_guide/providers/auth_provider.dart' as app;
import 'package:hail_parks_guide/features/login/screens/login_screen.dart';
import 'package:hail_parks_guide/features/navigation/bottom_nav_bar.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    // Wait minimum 3 seconds for splash to show
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      // Not logged in — go straight to login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    // Logged in — wait for AuthProvider to finish fetching user from Firestore
    final authProvider = Provider.of<app.AuthProvider>(context, listen: false);

    // If user is already loaded, navigate immediately
    if (authProvider.currentUser != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
      return;
    }

    // Otherwise wait for it — poll every 100ms up to 5 seconds
    int attempts = 0;
    while (authProvider.currentUser == null && attempts < 50) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigation()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA8C5A2),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/plants/splash.json',
              width: 250,
              fit: BoxFit.contain,
              repeat: true,
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 28),
              child: Text(
                "قال ﷺ: ما من مسلمٍ يغرس غرسًا أو يزرع زرعًا فيأكل منه طيرٌ أو إنسانٌ أو بهيمةٌ إلا كان له به صدقة",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF02542D),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
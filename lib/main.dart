import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';
import 'package:hail_parks_guide/core/constants/app_config.dart';
import 'package:hail_parks_guide/firebase/firebase_options.dart';
import 'package:hail_parks_guide/features/navigation/bottom_nav_bar.dart';
import 'package:hail_parks_guide/features/login/screens/login_screen.dart';
import 'package:hail_parks_guide/providers/auth_provider.dart' as app;
import 'package:hail_parks_guide/providers/user_provider.dart';
import 'package:hail_parks_guide/providers/home_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AppConfig.firebaseReady = true;
  } catch (e) {
    // Not connected to Firebase yet: run with the screens that work offline.
    debugPrint('Firebase not configured, starting without it: $e');
    runApp(const MyApp());
    return;
  }

  final authProvider = app.AuthProvider();
  final userProvider = UserProvider();
  final homeProvider = HomeProvider(userProvider: userProvider);

  authProvider.onUserLoggedIn = (user) {
    userProvider.setLoggedInUser(user);
    homeProvider.initialize();
  };

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: userProvider),
        ChangeNotifierProvider.value(value: homeProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'دليل حائل',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Cairo',
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.darkGreen),
        scaffoldBackgroundColor: AppColors.creamBackground,
      ),
      home: const MainNavigation(),
      routes: {
        '/home': (context) => const MainNavigation(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}
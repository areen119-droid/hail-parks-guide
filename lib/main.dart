import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:hail_parks_guide/app/theme.dart';
import 'package:hail_parks_guide/core/splashScreen/splash_screen.dart';
import 'package:hail_parks_guide/features/navigation/bottom_nav_bar.dart';
import 'package:hail_parks_guide/journal/journal_shell.dart';
import 'package:hail_parks_guide/journal/journal_theme.dart';
import 'package:hail_parks_guide/journal/journal_welcome.dart';
import 'package:hail_parks_guide/providers/design_provider.dart';
import 'package:hail_parks_guide/providers/favorites_provider.dart';
import 'package:hail_parks_guide/providers/guide_provider.dart';
import 'package:hail_parks_guide/providers/navigation_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => GuideProvider()),
        ChangeNotifierProvider(create: (_) => DesignProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppDesign? _shownDesign;
  bool _switched = false;

  @override
  Widget build(BuildContext context) {
    final designs = context.watch<DesignProvider>();
    final design = designs.design;
    // The welcome screen only on launch; after switching designs, go
    // straight to the tabs.
    if (designs.loaded) {
      if (_shownDesign != null && design != _shownDesign) _switched = true;
      _shownDesign = design;
    }
    final switched = _switched;
    final journal = design == AppDesign.journal;

    return MaterialApp(
      // A new key rebuilds the whole app in the other design.
      key: ValueKey(design),
      title: 'دليل حدائق حائل',
      debugShowCheckedModeBanner: false,
      theme: journal ? buildJournalTheme() : buildAppTheme(),
      // Arabic, right-to-left throughout the app.
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: !designs.loaded
          ? const Scaffold(backgroundColor: J.paper)
          : journal
              ? (switched ? const JournalShell() : const JournalWelcome())
              : (switched ? const MainNavigation() : const SplashScreen()),
      routes: {
        '/home': (context) => const MainNavigation(),
      },
    );
  }
}

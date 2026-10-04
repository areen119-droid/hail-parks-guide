import 'package:flutter/material.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';
import 'package:hail_parks_guide/core/constants/app_config.dart';
import 'package:hail_parks_guide/features/home/screens/home_screen.dart';
import 'package:hail_parks_guide/features/parks/parks_screen.dart';
import 'package:hail_parks_guide/features/plants/plants_screen.dart';
import 'package:hail_parks_guide/features/map/screens/map_page.dart';
import 'package:hail_parks_guide/features/profile/screens/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;
  const MainNavigation({super.key, this.initialIndex = 0});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    // Without Firebase, open on the Parks tab since Home needs Firebase.
    _selectedIndex = !AppConfig.firebaseReady && widget.initialIndex == 0
        ? 1
        : widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final online = AppConfig.firebaseReady;
    final List<Widget> screens = [
      online ? const HomeScreen() : const _NeedsFirebase(),
      const ParksScreen(),
      const PlantsScreen(),
      online ? const MapPage() : const _NeedsFirebase(),
      online ? const ProfileScreen() : const _NeedsFirebase(),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.darkBrown.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: AppColors.darkGreen,
          unselectedItemColor: AppColors.mediumGrey,
          backgroundColor: AppColors.white,
          elevation: 0,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.park_outlined),
              activeIcon: Icon(Icons.park),
              label: 'الحدائق',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_florist_outlined),
              activeIcon: Icon(Icons.local_florist),
              label: 'النباتات',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map),
              label: 'الخريطة',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'ملفي',
            ),
          ],
        ),
      ),
    );
  }
}

class _NeedsFirebase extends StatelessWidget {
  const _NeedsFirebase();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.creamBackground,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off, size: 64, color: AppColors.mediumGrey),
              SizedBox(height: 16),
              Text(
                'هذه الصفحة تحتاج ربط التطبيق بـ Firebase',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppColors.darkText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

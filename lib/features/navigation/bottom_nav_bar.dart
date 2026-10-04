import 'package:flutter/material.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';
import 'package:hail_parks_guide/features/home/screens/home_screen.dart';
import 'package:hail_parks_guide/features/map/screens/map_page.dart';
import 'package:hail_parks_guide/features/plants/plants_screen.dart';
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
    _selectedIndex = widget.initialIndex;
  }

  void _selectTab(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(onOpenMap: () => _selectTab(1)),
      const MapPage(),
      const PlantsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      // IndexedStack keeps the map's position when switching tabs.
      body: IndexedStack(index: _selectedIndex, children: screens),
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
          onTap: _selectTab,
          selectedItemColor: AppColors.darkGreen,
          unselectedItemColor: AppColors.mediumGrey,
          backgroundColor: AppColors.white,
          elevation: 0,
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map),
              label: 'الخريطة',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_florist_outlined),
              activeIcon: Icon(Icons.local_florist),
              label: 'النباتات',
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

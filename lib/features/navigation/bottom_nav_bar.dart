import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';
import 'package:hail_parks_guide/features/guide/screens/guide_screen.dart';
import 'package:hail_parks_guide/features/home/screens/home_screen.dart';
import 'package:hail_parks_guide/features/map/screens/map_page.dart';
import 'package:hail_parks_guide/features/plants/plants_screen.dart';
import 'package:hail_parks_guide/features/profile/screens/profile_screen.dart';
import 'package:hail_parks_guide/providers/navigation_provider.dart';

/// Space screens leave at the bottom so content isn't hidden by the nav bar.
const double kNavBarSpace = 110;

class MainNavigation extends StatelessWidget {
  const MainNavigation({super.key});

  static const _items = [
    _NavItem(Icons.home_outlined, Icons.home_rounded, 'الرئيسية'),
    _NavItem(Icons.map_outlined, Icons.map_rounded, 'الخريطة'),
    _NavItem(Icons.auto_awesome_outlined, Icons.auto_awesome, 'المرشد'),
    _NavItem(Icons.local_florist_outlined, Icons.local_florist, 'النباتات'),
    _NavItem(Icons.person_outline, Icons.person_rounded, 'ملفي'),
  ];

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();

    return Scaffold(
      extendBody: true,
      // IndexedStack keeps each tab's state (like the map position).
      body: IndexedStack(
        index: nav.tabIndex,
        children: const [
          HomeScreen(),
          MapPage(),
          GuideScreen(),
          PlantsScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: _NavButton(
                    item: _items[i],
                    selected: nav.tabIndex == i,
                    onTap: () => nav.selectTab(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(this.icon, this.activeIcon, this.label);
}

class _NavButton extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.white : AppColors.chip.withValues(alpha: 0.6);
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(selected ? item.activeIcon : item.icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            item.label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

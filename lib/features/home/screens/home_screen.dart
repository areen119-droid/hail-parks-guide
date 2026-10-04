import 'package:flutter/material.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';
import 'package:hail_parks_guide/data/hail_data.dart';
import 'package:hail_parks_guide/features/home/widget/facts_widget.dart';
import 'package:hail_parks_guide/features/home/widget/featured_parks_widget.dart';
import 'package:hail_parks_guide/features/home/widget/plants_widget.dart';

class HomeScreen extends StatelessWidget {
  /// Switches the bottom navigation to the map tab.
  final VoidCallback onOpenMap;

  const HomeScreen({super.key, required this.onOpenMap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildSectionTitle(
                'حدائق حائل',
                action: TextButton.icon(
                  onPressed: onOpenMap,
                  icon: const Icon(Icons.map, size: 18),
                  label: const Text('عرض على الخريطة'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.mediumBrown,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const FeaturedParksWidget(),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: PlantsWidget(),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: FactsWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.darkGreen, AppColors.mediumBrown],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'مرحبًا، ${HailData.currentUser.name}',
            style: const TextStyle(color: AppColors.paleGreen, fontSize: 14),
          ),
          const SizedBox(height: 6),
          const Text(
            'دليل حدائق حائل',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'اكتشف أجمل الحدائق والنباتات في المنطقة',
            style: TextStyle(color: AppColors.paleBrown, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {Widget? action}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          if (action != null) action,
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGreen,
            ),
          ),
        ],
      ),
    );
  }
}

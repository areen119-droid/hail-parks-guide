import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hail_parks_guide/app/theme.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';
import 'package:hail_parks_guide/core/widgets/custom_button.dart';
import 'package:hail_parks_guide/data/hail_data.dart';
import 'package:hail_parks_guide/features/home/widget/facts_widget.dart';
import 'package:hail_parks_guide/features/home/widget/place_card.dart';
import 'package:hail_parks_guide/features/home/widget/plants_widget.dart';
import 'package:hail_parks_guide/features/navigation/bottom_nav_bar.dart';
import 'package:hail_parks_guide/features/places/food_card.dart';
import 'package:hail_parks_guide/features/settings/screens/settings_screen.dart';
import 'package:hail_parks_guide/models/place_model.dart';
import 'package:hail_parks_guide/providers/navigation_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _query = '';
  // Parks are the app's focus, so they're selected first. null shows all
  // main categories; restaurants and cafes have their own section below.
  PlaceCategory? _category = PlaceCategory.park;

  static final _foodPlaces =
      HailData.places.where((p) => p.category.isFood).toList();

  @override
  Widget build(BuildContext context) {
    final places = HailData.places.where((place) {
      if (place.category.isFood) return false;
      final matchesCategory = _category == null || place.category == _category;
      final matchesQuery = place.name.contains(_query.trim());
      return matchesCategory && matchesQuery;
    }).toList();

    return Container(
      decoration: AppDecorations.screenBackground,
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildTop(context)),
            SliverToBoxAdapter(child: _buildPanel(context, places)),
          ],
        ),
      ),
    );
  }

  Widget _buildTop(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مرحبًا، ${HailData.currentUser.name}',
                      style: AppText.caption,
                    ),
                    const Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 16, color: AppColors.accent),
                        SizedBox(width: 2),
                        Text(
                          'حائل',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              CircleIconButton(
                icon: Icons.tune,
                tooltip: 'الإعدادات',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SearchPill(
            hint: 'ابحث عن حديقة أو مكان...',
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 22),
          const Text('اكتشف', style: AppText.display),
          const Text(
            'أجمل الحدائق والمتنزهات في حائل',
            style: TextStyle(fontSize: 14, color: AppColors.brownMedium),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final c in PlaceCategory.main) ...[
                  PillChip(
                    label: c.label,
                    selected: _category == c,
                    onTap: () => setState(() => _category = c),
                  ),
                  const SizedBox(width: 8),
                ],
                PillChip(
                  label: 'الكل',
                  selected: _category == null,
                  onTap: () => setState(() => _category = null),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlannerBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<NavigationProvider>().openGuide(planner: true),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        decoration: BoxDecoration(
          color: AppColors.brown,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.accent,
              child: Icon(Icons.auto_awesome, color: AppColors.white),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'خطط رحلتك إلى حائل',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                  Text(
                    'دع المرشد الذكي يقترح لك خطة تناسبك',
                    style: TextStyle(fontSize: 13, color: AppColors.sandLight),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward, color: AppColors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildPanel(BuildContext context, List<PlaceModel> places) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, kNavBarSpace),
      decoration: const BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.chip,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildPlannerBanner(context),
          const SizedBox(height: 20),
          SectionHeader(
            title: _category?.label ?? 'أماكن حائل',
            actionLabel: 'عرض على الخريطة',
            onAction: () => context
                .read<NavigationProvider>()
                .selectTab(NavigationProvider.mapTab),
          ),
          const SizedBox(height: 14),
          if (places.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('لا توجد أماكن مطابقة', style: AppText.caption),
              ),
            )
          else
            for (final place in places)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: PlaceCard(place: place),
              ),
          const SizedBox(height: 10),
          const SectionHeader(title: 'أين تأكل؟'),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _foodPlaces.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) =>
                  FoodCard(place: _foodPlaces[index]),
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'نبتة اليوم'),
          const SizedBox(height: 12),
          const PlantsWidget(),
          const SizedBox(height: 24),
          const FactsWidget(),
        ],
      ),
    );
  }
}

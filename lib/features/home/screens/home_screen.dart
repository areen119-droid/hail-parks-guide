import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hail_parks_guide/app/theme.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';
import 'package:hail_parks_guide/core/widgets/custom_button.dart';
import 'package:hail_parks_guide/data/hail_data.dart';
import 'package:hail_parks_guide/features/home/widget/facts_widget.dart';
import 'package:hail_parks_guide/features/home/widget/park_card.dart';
import 'package:hail_parks_guide/features/home/widget/plants_widget.dart';
import 'package:hail_parks_guide/features/navigation/bottom_nav_bar.dart';
import 'package:hail_parks_guide/features/settings/screens/settings_screen.dart';
import 'package:hail_parks_guide/models/park_model.dart';
import 'package:hail_parks_guide/providers/navigation_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _allLabel = 'الكل';

  String _query = '';
  String _filter = _allLabel;

  /// Filter chips come from the parks' facilities.
  List<String> get _filters => [
        _allLabel,
        ...{for (final park in HailData.parks) ...park.facilities},
      ];

  @override
  Widget build(BuildContext context) {
    final parks = HailData.parks.where((park) {
      final matchesFilter =
          _filter == _allLabel || park.facilities.contains(_filter);
      final matchesQuery = park.name.contains(_query.trim());
      return matchesFilter && matchesQuery;
    }).toList();

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.background),
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildTop(context)),
            SliverToBoxAdapter(child: _buildPanel(context, parks)),
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
            hint: 'ابحث عن حديقة...',
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
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final label = _filters[index];
                return PillChip(
                  label: label,
                  selected: label == _filter,
                  onTap: () => setState(() => _filter = label),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanel(BuildContext context, List<ParkModel> parks) {
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
          SectionHeader(
            title: 'الحدائق',
            actionLabel: 'عرض على الخريطة',
            onAction: () => context
                .read<NavigationProvider>()
                .selectTab(NavigationProvider.mapTab),
          ),
          const SizedBox(height: 14),
          if (parks.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('لا توجد حدائق مطابقة', style: AppText.caption),
              ),
            )
          else
            for (final park in parks)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: ParkCard(park: park),
              ),
          const SizedBox(height: 10),
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

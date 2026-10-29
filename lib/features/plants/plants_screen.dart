import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hail_parks_guide/core/widgets/favorite_feedback.dart';
import 'package:hail_parks_guide/app/theme.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';
import 'package:hail_parks_guide/core/widgets/custom_button.dart';
import 'package:hail_parks_guide/core/widgets/smart_image.dart';
import 'package:hail_parks_guide/data/hail_data.dart';
import 'package:hail_parks_guide/features/navigation/bottom_nav_bar.dart';
import 'package:hail_parks_guide/features/plants/plant_detail_screen.dart';
import 'package:hail_parks_guide/models/plant_model.dart';
import 'package:hail_parks_guide/providers/favorites_provider.dart';

class PlantsScreen extends StatefulWidget {
  const PlantsScreen({super.key});

  @override
  State<PlantsScreen> createState() => _PlantsScreenState();
}

class _PlantsScreenState extends State<PlantsScreen> {
  static const _allLabel = 'الكل';

  String _query = '';
  String _filter = _allLabel;

  /// Filter chips come from the plants' types.
  List<String> get _filters => [
        _allLabel,
        ...{for (final plant in HailData.plants) plant.type},
      ];

  @override
  Widget build(BuildContext context) {
    final plants = HailData.plants.where((plant) {
      final matchesFilter = _filter == _allLabel || plant.type == _filter;
      return matchesFilter && plant.name.contains(_query.trim());
    }).toList();

    return Container(
      decoration: AppDecorations.screenBackground,
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('نباتات حائل', style: AppText.display),
                    const Text(
                      'تعرّف على النباتات في حدائق ومتنزهات المنطقة',
                      style: TextStyle(
                          fontSize: 14, color: AppColors.primaryMedium),
                    ),
                    const SizedBox(height: 16),
                    SearchPill(
                      hint: 'ابحث عن نبات...',
                      onChanged: (value) => setState(() => _query = value),
                    ),
                    const SizedBox(height: 14),
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
              ),
            ),
            if (plants.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text('لا توجد نباتات مطابقة', style: AppText.caption),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, kNavBarSpace),
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: plants.length,
                  itemBuilder: (context, index) =>
                      _PlantCard(plant: plants[index]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PlantCard extends StatelessWidget {
  final Plant plant;

  const _PlantCard({required this.plant});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final isFavorite = favorites.isFavoritePlant(plant.id);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PlantDetailScreen(plant: plant)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            SmartImage(imageData: plant.image),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0xB3000000)],
                  stops: [0.5, 1.0],
                ),
              ),
            ),
            PositionedDirectional(
              top: 8,
              end: 8,
              child: CircleIconButton(
                icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                iconColor: isFavorite ? AppColors.error : AppColors.primary,
                size: 36,
                tooltip: 'المفضلة',
                onPressed: () => toggleFavoritePlant(context, plant),
              ),
            ),
            PositionedDirectional(
              start: 12,
              end: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plant.name,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    plant.type,
                    style: const TextStyle(color: AppColors.chip, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

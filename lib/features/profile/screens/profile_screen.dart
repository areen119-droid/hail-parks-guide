import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hail_parks_guide/app/theme.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';
import 'package:hail_parks_guide/core/widgets/custom_button.dart';
import 'package:hail_parks_guide/core/widgets/smart_image.dart';
import 'package:hail_parks_guide/data/hail_data.dart';
import 'package:hail_parks_guide/features/navigation/bottom_nav_bar.dart';
import 'package:hail_parks_guide/features/places/place_detail_screen.dart';
import 'package:hail_parks_guide/features/plants/plant_detail_screen.dart';
import 'package:hail_parks_guide/features/settings/screens/settings_screen.dart';
import 'package:hail_parks_guide/providers/favorites_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _showPlaces = true;

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final places = favorites.favoritePlaces;
    final plants = favorites.favoritePlants;
    const user = HailData.currentUser;

    final List<_FavoriteItem> items = _showPlaces
        ? [
            for (final place in places)
              _FavoriteItem(
                title: place.name,
                subtitle: place.category.label,
                image: place.image,
                icon: place.category.icon,
                open: () => PlaceDetailScreen(place: place),
                remove: () => favorites.togglePlace(place.id),
              ),
          ]
        : [
            for (final plant in plants)
              _FavoriteItem(
                title: plant.name,
                subtitle: plant.type,
                image: plant.image,
                icon: Icons.local_florist,
                open: () => PlantDetailScreen(plant: plant),
                remove: () => favorites.togglePlant(plant.id),
              ),
          ];

    return Container(
      decoration: AppDecorations.screenBackground,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, kNavBarSpace),
          children: [
            Row(
              children: [
                const Text('ملفي', style: AppText.title),
                const Spacer(),
                CircleIconButton(
                  icon: Icons.settings_outlined,
                  tooltip: 'الإعدادات',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.cream,
                  shape: BoxShape.circle,
                ),
                child: const CircleAvatar(
                  radius: 46,
                  backgroundColor: AppColors.chip,
                  child: Icon(Icons.person, size: 52, color: AppColors.primaryMedium),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(child: Text(user.name, style: AppText.title)),
            Center(
              child: Text('@${user.username}', style: AppText.caption),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                user.bio,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.primaryMedium),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  _Stat(value: '${places.length}', label: 'أماكن مفضلة'),
                  Container(width: 1, height: 36, color: AppColors.divider),
                  _Stat(value: '${plants.length}', label: 'نباتات مفضلة'),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                PillChip(
                  label: 'الأماكن',
                  selected: _showPlaces,
                  onTap: () => setState(() => _showPlaces = true),
                ),
                const SizedBox(width: 8),
                PillChip(
                  label: 'النباتات',
                  selected: !_showPlaces,
                  onTap: () => setState(() => _showPlaces = false),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (items.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.favorite_border,
                        size: 36, color: AppColors.textSecondary),
                    const SizedBox(height: 8),
                    Text(
                      _showPlaces
                          ? 'اضغط ♡ على أي مكان لإضافته هنا'
                          : 'اضغط ♡ على أي نبتة لإضافتها هنا',
                      textAlign: TextAlign.center,
                      style: AppText.caption,
                    ),
                  ],
                ),
              )
            else
              for (final item in items) _FavoriteTile(item: item),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;

  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: AppText.headingFont,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          Text(label, style: AppText.caption),
        ],
      ),
    );
  }
}

class _FavoriteItem {
  final String title;
  final String subtitle;
  final String image;
  final IconData icon;
  final Widget Function() open;
  final VoidCallback remove;

  const _FavoriteItem({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.icon,
    required this.open,
    required this.remove,
  });
}

class _FavoriteTile extends StatelessWidget {
  final _FavoriteItem item;

  const _FavoriteTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => item.open()),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SmartImage(
                imageData: item.image,
                width: 64,
                height: 64,
                placeholderIcon: item.icon,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(item.subtitle, style: AppText.caption),
                ],
              ),
            ),
            IconButton(
              tooltip: 'إزالة من المفضلة',
              icon: const Icon(Icons.favorite, color: AppColors.error),
              onPressed: item.remove,
            ),
          ],
        ),
      ),
    );
  }
}

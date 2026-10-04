import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';
import 'package:hail_parks_guide/core/widgets/smart_image.dart';
import 'package:hail_parks_guide/data/hail_data.dart';
import 'package:hail_parks_guide/features/parks/park_detail_screen.dart';
import 'package:hail_parks_guide/features/plants/plant_detail_screen.dart';
import 'package:hail_parks_guide/features/settings/screens/settings_screen.dart';
import 'package:hail_parks_guide/providers/favorites_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final parks = favorites.favoriteParks;
    final plants = favorites.favoritePlants;

    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              _buildStatsRow(parks.length, plants.length),
              const SizedBox(height: 24),
              _buildSection(
                title: 'الحدائق المفضلة',
                icon: Icons.park,
                color: AppColors.darkBrown,
                emptyText: 'اضغط على ♡ في صفحة أي حديقة لإضافتها هنا',
                children: [
                  for (final park in parks)
                    _FavoriteTile(
                      title: park.name,
                      subtitle: park.location,
                      image: park.image,
                      placeholderIcon: Icons.park,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ParkDetailScreen(park: park)),
                      ),
                      onRemove: () => favorites.togglePark(park.id),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                title: 'النباتات المفضلة',
                icon: Icons.local_florist,
                color: AppColors.darkGreen,
                emptyText: 'اضغط على ♡ في صفحة أي نبتة لإضافتها هنا',
                children: [
                  for (final plant in plants)
                    _FavoriteTile(
                      title: plant.name,
                      subtitle: plant.type,
                      image: plant.image,
                      placeholderIcon: Icons.local_florist,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => PlantDetailScreen(plant: plant)),
                      ),
                      onRemove: () => favorites.togglePlant(plant.id),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    const user = HailData.currentUser;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.darkBrown, AppColors.darkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              tooltip: 'الإعدادات',
              icon: const Icon(Icons.settings, color: AppColors.white),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
            ),
          ),
          const CircleAvatar(
            radius: 45,
            backgroundColor: AppColors.lightSand,
            child: Icon(Icons.person, size: 50, color: AppColors.mediumBrown),
          ),
          const SizedBox(height: 12),
          Text(
            user.name,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '@${user.username}',
            style: const TextStyle(color: AppColors.paleBrown, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user.city,
                style: const TextStyle(color: AppColors.paleGreen, fontSize: 13),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.location_on,
                  size: 14, color: AppColors.paleGreen),
            ],
          ),
          if (user.bio.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              user.bio,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.white, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsRow(int parkCount, int plantCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildStatItem('$plantCount', 'نباتات مفضلة', AppColors.darkGreen),
          Container(height: 40, width: 1, color: AppColors.lightGrey),
          _buildStatItem('$parkCount', 'حدائق مفضلة', AppColors.darkBrown),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.mediumGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required String emptyText,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          if (children.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                emptyText,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.mediumGrey, fontSize: 13),
              ),
            )
          else
            ...children,
        ],
      ),
    );
  }
}

class _FavoriteTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String image;
  final IconData placeholderIcon;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _FavoriteTile({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.placeholderIcon,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: onTap,
        leading: IconButton(
          tooltip: 'إزالة من المفضلة',
          icon: const Icon(Icons.favorite, color: AppColors.errorRed),
          onPressed: onRemove,
        ),
        title: Text(
          title,
          textAlign: TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          subtitle,
          textAlign: TextAlign.right,
          style: const TextStyle(color: AppColors.mediumGrey, fontSize: 12),
        ),
        trailing: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SmartImage(
            imageData: image,
            width: 52,
            height: 52,
            placeholderIcon: placeholderIcon,
          ),
        ),
      ),
    );
  }
}

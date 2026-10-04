import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';
import 'package:hail_parks_guide/core/widgets/smart_image.dart';
import 'package:hail_parks_guide/models/park_model.dart';
import 'package:hail_parks_guide/providers/favorites_provider.dart';

class ParkDetailScreen extends StatelessWidget {
  final ParkModel park;

  const ParkDetailScreen({super.key, required this.park});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final isFavorite = favorites.isFavoritePark(park.id);

    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.darkGreen,
            foregroundColor: AppColors.white,
            actions: [
              IconButton(
                tooltip: 'المفضلة',
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                onPressed: () => favorites.togglePark(park.id),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                park.name,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: park.image.isEmpty
                  ? Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.darkGreen, AppColors.mediumBrown],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(Icons.park,
                          size: 80, color: AppColors.paleGreen),
                    )
                  : SmartImage(imageData: park.image, placeholderIcon: Icons.park),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildInfoRow(Icons.location_on, park.location),
                  if (park.openingHours.isNotEmpty)
                    _buildInfoRow(Icons.access_time, park.openingHours),
                  const SizedBox(height: 16),
                  _buildSectionTitle('عن الحديقة'),
                  Text(
                    park.description,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.darkText,
                      height: 1.6,
                    ),
                  ),
                  if (park.facilities.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildSectionTitle('المرافق'),
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 8,
                      runSpacing: 8,
                      children: park.facilities
                          .map((facility) => Chip(
                                label: Text(facility),
                                backgroundColor: AppColors.paleGreen,
                                labelStyle:
                                    const TextStyle(color: AppColors.darkGreen),
                                side: BorderSide.none,
                              ))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 20),
                  _buildSectionTitle('الموقع'),
                  _buildLocationMap(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationMap() {
    final point = LatLng(park.latitude, park.longitude);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 180,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: point,
            initialZoom: 15,
            interactionOptions:
                const InteractionOptions(flags: InteractiveFlag.none),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.hailparksguide.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: point,
                  width: 44,
                  height: 44,
                  alignment: Alignment.topCenter,
                  child: const Icon(Icons.location_on,
                      size: 44, color: AppColors.darkGreen),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(text,
              style: const TextStyle(fontSize: 14, color: AppColors.mediumBrown)),
          const SizedBox(width: 6),
          Icon(icon, size: 18, color: AppColors.mediumBrown),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: AppColors.darkGreen,
        ),
      ),
    );
  }
}

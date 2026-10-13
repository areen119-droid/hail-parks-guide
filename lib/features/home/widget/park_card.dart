import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';
import 'package:hail_parks_guide/core/widgets/custom_button.dart';
import 'package:hail_parks_guide/core/widgets/smart_image.dart';
import 'package:hail_parks_guide/features/parks/park_detail_screen.dart';
import 'package:hail_parks_guide/models/park_model.dart';
import 'package:hail_parks_guide/providers/favorites_provider.dart';

/// Large photo card for a park with its name over the image.
class ParkCard extends StatelessWidget {
  final ParkModel park;

  const ParkCard({super.key, required this.park});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final isFavorite = favorites.isFavoritePark(park.id);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ParkDetailScreen(park: park)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          height: 200,
          child: Stack(
            fit: StackFit.expand,
            children: [
              SmartImage(imageData: park.image, placeholderIcon: Icons.park),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00000000), Color(0xB3000000)],
                    stops: [0.45, 1.0],
                  ),
                ),
              ),
              PositionedDirectional(
                top: 12,
                end: 12,
                child: CircleIconButton(
                  icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                  iconColor: isFavorite ? AppColors.error : AppColors.brown,
                  size: 40,
                  tooltip: 'المفضلة',
                  onPressed: () => favorites.togglePark(park.id),
                ),
              ),
              if (park.openingHours.isNotEmpty)
                PositionedDirectional(
                  top: 14,
                  start: 14,
                  child: _Badge(icon: Icons.access_time, text: park.openingHours),
                ),
              PositionedDirectional(
                start: 18,
                end: 18,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      park.name,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 14, color: AppColors.chip),
                        const SizedBox(width: 4),
                        Text(
                          park.location,
                          style: const TextStyle(
                              color: AppColors.chip, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Badge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cream.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.accent),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

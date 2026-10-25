import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';
import 'package:hail_parks_guide/core/utils/helpers.dart';
import 'package:hail_parks_guide/core/widgets/custom_button.dart';
import 'package:hail_parks_guide/features/places/place_detail_screen.dart';
import 'package:hail_parks_guide/features/places/place_image.dart';
import 'package:hail_parks_guide/models/place_model.dart';
import 'package:hail_parks_guide/providers/favorites_provider.dart';

/// Large photo card for a place with its name over the image.
class PlaceCard extends StatelessWidget {
  final PlaceModel place;

  const PlaceCard({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final isFavorite = favorites.isFavoritePlace(place.id);
    final distance = distanceFromHailLabel(place);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PlaceDetailScreen(place: place)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          height: 200,
          child: Stack(
            fit: StackFit.expand,
            children: [
              PlaceImage(place: place),
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
                  iconColor: isFavorite ? AppColors.error : AppColors.primary,
                  size: 40,
                  tooltip: 'المفضلة',
                  onPressed: () => favorites.togglePlace(place.id),
                ),
              ),
              PositionedDirectional(
                top: 14,
                start: 14,
                child: _Badge(
                  icon: place.category.icon,
                  text: place.category.label,
                ),
              ),
              PositionedDirectional(
                start: 18,
                end: 18,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
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
                        Flexible(
                          child: Text(
                            distance == null
                                ? place.location
                                : '${place.location} · $distance',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: AppColors.chip, fontSize: 13),
                          ),
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

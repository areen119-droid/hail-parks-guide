import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hail_parks_guide/app/theme.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';
import 'package:hail_parks_guide/core/utils/helpers.dart';
import 'package:hail_parks_guide/core/widgets/custom_button.dart';
import 'package:hail_parks_guide/core/widgets/favorite_feedback.dart';
import 'package:hail_parks_guide/features/places/place_detail_screen.dart';
import 'package:hail_parks_guide/features/places/place_image.dart';
import 'package:hail_parks_guide/models/place_model.dart';
import 'package:hail_parks_guide/providers/favorites_provider.dart';

/// A place in the Home list: a large photo card when the place has a photo,
/// otherwise a compact row, so places with photos stand out.
class PlaceCard extends StatelessWidget {
  final PlaceModel place;

  const PlaceCard({super.key, required this.place});

  String get _subtitle {
    final distance = distanceFromHailLabel(place);
    return distance == null ? place.location : '${place.location} · $distance';
  }

  void _open(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PlaceDetailScreen(place: place)),
      );

  @override
  Widget build(BuildContext context) {
    final isFavorite = context.watch<FavoritesProvider>().isFavoritePlace(place.id);
    final favoriteButton = CircleIconButton(
      icon: isFavorite ? Icons.favorite : Icons.favorite_border,
      iconColor: isFavorite ? AppColors.error : AppColors.primary,
      size: 40,
      tooltip: isFavorite ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
      onPressed: () => toggleFavoritePlace(context, place),
    );

    return place.image.isEmpty
        ? _buildCompact(context, favoriteButton)
        : _buildPhoto(context, favoriteButton);
  }

  Widget _buildPhoto(BuildContext context, Widget favoriteButton) {
    return GestureDetector(
      onTap: () => _open(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 200,
          child: Stack(
            fit: StackFit.expand,
            children: [
              PlaceImage(place: place),
              // Darkens the bottom so the white text stays readable.
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
              PositionedDirectional(top: 12, end: 12, child: favoriteButton),
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
                    Text(
                      _subtitle,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.chip, fontSize: 13),
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

  Widget _buildCompact(BuildContext context, Widget favoriteButton) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _open(context),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: PlaceImage(place: place, width: 64, height: 64),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(_subtitle, style: AppText.caption),
                  ],
                ),
              ),
              favoriteButton,
            ],
          ),
        ),
      ),
    );
  }
}

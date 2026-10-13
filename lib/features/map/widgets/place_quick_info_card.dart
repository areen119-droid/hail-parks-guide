import 'package:flutter/material.dart';
import 'package:hail_parks_guide/app/theme.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';
import 'package:hail_parks_guide/core/utils/helpers.dart';
import 'package:hail_parks_guide/features/places/place_detail_screen.dart';
import 'package:hail_parks_guide/features/places/place_image.dart';
import 'package:hail_parks_guide/models/place_model.dart';

/// Card shown above the nav bar when a place pin is tapped.
class PlaceQuickInfoCard extends StatelessWidget {
  final PlaceModel place;
  final VoidCallback onClose;

  const PlaceQuickInfoCard({
    super.key,
    required this.place,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final distance = distanceFromHailLabel(place);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PlaceDetailScreen(place: place)),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: AppColors.brown.withValues(alpha: 0.2),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: PlaceImage(place: place, width: 96, height: 96),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${place.category.label}${distance == null ? '' : ' · $distance'}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    place.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    place.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.caption,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'إغلاق',
              icon: const Icon(Icons.close, color: AppColors.textSecondary),
              onPressed: onClose,
            ),
          ],
        ),
      ),
    );
  }
}

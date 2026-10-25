import 'package:flutter/material.dart';
import 'package:hail_parks_guide/app/theme.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';
import 'package:hail_parks_guide/core/widgets/custom_button.dart';
import 'package:hail_parks_guide/models/place_model.dart';

/// Title and category filter chips over the map.
class MapTopOverlay extends StatelessWidget {
  /// Selected category, or null for all places.
  final PlaceCategory? category;
  final ValueChanged<PlaceCategory?> onCategoryChanged;

  const MapTopOverlay({
    super.key,
    required this.category,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.sand,
            AppColors.sandLight.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'خريطة حائل',
                style: TextStyle(
                  fontFamily: AppText.headingFont,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 42,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    PillChip(
                      label: 'الكل',
                      selected: category == null,
                      onTap: () => onCategoryChanged(null),
                    ),
                    for (final c in PlaceCategory.values) ...[
                      const SizedBox(width: 8),
                      PillChip(
                        label: c.label,
                        selected: category == c,
                        onTap: () => onCategoryChanged(c),
                      ),
                    ],
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

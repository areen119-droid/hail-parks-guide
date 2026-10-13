import 'package:flutter/material.dart';
import 'package:hail_parks_guide/app/theme.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';
import 'package:hail_parks_guide/core/widgets/custom_button.dart';
import 'package:hail_parks_guide/models/park_model.dart';

/// Title and a scrollable row of park chips over the map.
class MapTopOverlay extends StatelessWidget {
  final List<ParkModel> parks;
  final String? selectedParkId;
  final ValueChanged<ParkModel> onParkSelected;

  const MapTopOverlay({
    super.key,
    required this.parks,
    required this.selectedParkId,
    required this.onParkSelected,
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
            color: AppColors.brown.withValues(alpha: 0.12),
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
                'خريطة الحدائق',
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
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: parks.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final park = parks[index];
                    return PillChip(
                      label: park.name,
                      selected: park.id == selectedParkId,
                      onTap: () => onParkSelected(park),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

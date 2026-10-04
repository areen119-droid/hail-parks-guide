import 'package:flutter/material.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';
import 'package:hail_parks_guide/models/park_model.dart';

/// Title bar over the map with a scrollable row of park chips.
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
    return SafeArea(
      bottom: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: AppColors.creamBackground.withOpacity(0.95),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'حدائق حائل',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGreen,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                reverse: true, // start from the right for Arabic
                itemCount: parks.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final park = parks[index];
                  final selected = park.id == selectedParkId;
                  return ChoiceChip(
                    label: Text(park.name),
                    selected: selected,
                    onSelected: (_) => onParkSelected(park),
                    showCheckmark: false,
                    avatar: Icon(
                      Icons.park,
                      size: 16,
                      color: selected ? AppColors.white : AppColors.darkGreen,
                    ),
                    selectedColor: AppColors.darkGreen,
                    backgroundColor: AppColors.white,
                    labelStyle: TextStyle(
                      color: selected ? AppColors.white : AppColors.darkText,
                      fontWeight: FontWeight.w600,
                    ),
                    side: const BorderSide(color: AppColors.paleGreen),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

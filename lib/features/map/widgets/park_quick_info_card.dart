import 'package:flutter/material.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';
import 'package:hail_parks_guide/features/parks/park_detail_screen.dart';
import 'package:hail_parks_guide/models/park_model.dart';

/// Card shown at the bottom of the map when a park pin is tapped.
class ParkQuickInfoCard extends StatelessWidget {
  final ParkModel park;
  final VoidCallback onClose;

  const ParkQuickInfoCard({
    super.key,
    required this.park,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.mediumGrey),
                onPressed: onClose,
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  park.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.park, color: AppColors.darkGreen),
            ],
          ),
          Text(
            park.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.mediumGrey,
              height: 1.4,
            ),
          ),
          if (park.openingHours.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  park.openingHours,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.mediumBrown),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.access_time,
                    size: 14, color: AppColors.mediumBrown),
              ],
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ParkDetailScreen(park: park),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkGreen,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('عرض التفاصيل'),
            ),
          ),
        ],
      ),
    );
  }
}

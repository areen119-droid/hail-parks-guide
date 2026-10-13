import 'package:flutter/material.dart';
import 'package:hail_parks_guide/app/theme.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';
import 'package:hail_parks_guide/core/widgets/smart_image.dart';
import 'package:hail_parks_guide/features/parks/park_detail_screen.dart';
import 'package:hail_parks_guide/models/park_model.dart';

/// Card shown above the nav bar when a park pin is tapped.
class ParkQuickInfoCard extends StatelessWidget {
  final ParkModel park;
  final VoidCallback onClose;

  const ParkQuickInfoCard({
    super.key,
    required this.park,
    required this.onClose,
  });

  void _openDetails(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ParkDetailScreen(park: park)),
      );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openDetails(context),
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
              child: SmartImage(
                imageData: park.image,
                width: 96,
                height: 96,
                placeholderIcon: Icons.park,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    park.name,
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
                    park.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.caption,
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Text(
                        'عرض التفاصيل',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward,
                          size: 16, color: AppColors.accent),
                    ],
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

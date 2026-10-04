import 'package:flutter/material.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';
import 'package:hail_parks_guide/core/widgets/smart_image.dart';
import 'package:hail_parks_guide/data/hail_data.dart';
import 'package:hail_parks_guide/features/parks/park_detail_screen.dart';
import 'package:hail_parks_guide/models/park_model.dart';

/// Horizontal list of park cards on the home screen.
class FeaturedParksWidget extends StatelessWidget {
  const FeaturedParksWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        reverse: true, // start from the right for Arabic
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: HailData.parks.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) =>
            _ParkCard(park: HailData.parks[index]),
      ),
    );
  }
}

class _ParkCard extends StatelessWidget {
  final ParkModel park;

  const _ParkCard({required this.park});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ParkDetailScreen(park: park)),
      ),
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkBrown.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              child: SmartImage(
                imageData: park.image,
                height: 115,
                width: double.infinity,
                placeholderIcon: Icons.park,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    park.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        park.location,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.mediumBrown,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.location_on,
                          size: 14, color: AppColors.mediumBrown),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

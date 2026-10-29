import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hail_parks_guide/app/theme.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';
import 'package:hail_parks_guide/core/widgets/custom_button.dart';
import 'package:hail_parks_guide/data/hail_data.dart';
import 'package:hail_parks_guide/features/places/place_detail_screen.dart';
import 'package:hail_parks_guide/features/places/place_image.dart';
import 'package:hail_parks_guide/models/chat_message.dart';
import 'package:hail_parks_guide/models/place_model.dart';
import 'package:hail_parks_guide/providers/navigation_provider.dart';

/// Shows an AI trip plan as days of place cards, followed by what the
/// visitor can do next with it.
class TripPlanCard extends StatelessWidget {
  final TripPlan plan;
  final VoidCallback onSaveAll;
  final VoidCallback onEditAnswers;
  final ValueChanged<String> onFollowUp;

  const TripPlanCard({
    super.key,
    required this.plan,
    required this.onSaveAll,
    required this.onEditAnswers,
    required this.onFollowUp,
  });

  static const _followUps = [
    'أضف مكانًا للغداء',
    'اجعلها أقصر',
    'أماكن أنسب للأطفال',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(plan.title, style: AppText.title.copyWith(fontSize: 22)),
          const SizedBox(height: 4),
          Text(plan.summary, style: AppText.body.copyWith(fontSize: 14)),
          for (final day in plan.days) ...[
            const SizedBox(height: 16),
            Text(day.label, style: AppText.section),
            const SizedBox(height: 10),
            for (var i = 0; i < day.stops.length; i++)
              _StopTile(
                stop: day.stops[i],
                isLast: i == day.stops.length - 1,
              ),
          ],
          if (plan.tips.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.sandLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'نصائح',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  for (final tip in plan.tips)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('• $tip',
                          style: const TextStyle(fontSize: 13, height: 1.6)),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 18),
          // What to do next: one main action, one secondary, quick tweaks.
          ElevatedButton(
            onPressed: onSaveAll,
            child: const Text('احفظ أماكن الخطة في مفضلتي'),
          ),
          const SizedBox(height: 4),
          Center(
            child: TextButton(
              onPressed: onEditAnswers,
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              child: const Text('عدّل إجاباتي وأعد التخطيط'),
            ),
          ),
          const SizedBox(height: 6),
          const Text('أو اطلب تعديلًا:', style: AppText.caption),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final followUp in _followUps)
                PillChip(
                  label: followUp,
                  selected: false,
                  onTap: () => onFollowUp(followUp),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StopTile extends StatelessWidget {
  final TripStop stop;
  final bool isLast;

  const _StopTile({required this.stop, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final PlaceModel? place =
        HailData.places.where((p) => p.id == stop.placeId).firstOrNull;
    if (place == null) return const SizedBox.shrink();

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline dot and line
          SizedBox(
            width: 22,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: AppColors.chip),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => PlaceDetailScreen(place: place)),
              ),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: PlaceImage(place: place, width: 64, height: 64),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stop.time,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accent,
                            ),
                          ),
                          Text(
                            place.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            stop.note,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (place.hasLocation)
                      IconButton(
                        tooltip: 'عرض على الخريطة',
                        icon: const Icon(Icons.map_outlined,
                            color: AppColors.primary),
                        onPressed: () => context
                            .read<NavigationProvider>()
                            .showPlaceOnMap(place.id),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

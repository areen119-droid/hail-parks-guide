import 'package:flutter/material.dart';
import 'package:hail_parks_guide/app/theme.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';
import 'package:hail_parks_guide/core/widgets/custom_button.dart';
import 'package:hail_parks_guide/data/hail_data.dart';
import 'package:hail_parks_guide/data/initiative_data.dart';
import 'package:hail_parks_guide/features/places/place_detail_screen.dart';

/// Our Ghars Nation planting initiative (classic design).
class InitiativeScreen extends StatelessWidget {
  const InitiativeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final park =
        HailData.places.where((p) => p.id == InitiativeData.parkId).firstOrNull;
    final details = <(String, String)>[
      if (InitiativeData.date != null) ('التاريخ', InitiativeData.date!),
      if (InitiativeData.participants != null)
        ('المشاركون', '${InitiativeData.participants}'),
      if (InitiativeData.seedlings != null)
        ('الشتلات', '${InitiativeData.seedlings}'),
    ];

    return Scaffold(
      body: Container(
        decoration: AppDecorations.screenBackground,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Row(
                children: [
                  CircleIconButton(
                    icon: Icons.arrow_back,
                    tooltip: 'رجوع',
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 14),
                  const Text('من أعمالنا', style: AppText.section),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Image.asset(InitiativeData.logo, height: 120),
              ),
              const SizedBox(height: 18),
              Text(
                '${InitiativeData.appName} (${InitiativeData.appNameLatin})',
                style: const TextStyle(
                    color: AppColors.primaryMedium, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              const Text(InitiativeData.title, style: AppText.title),
              const SizedBox(height: 10),
              const Text(InitiativeData.summary, style: AppText.body),
              if (details.isNotEmpty) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    for (final (label, value) in details)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(value, style: AppText.title),
                            Text(label, style: AppText.caption),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              _Panel(
                title: 'القصة',
                children: [
                  for (final paragraph in InitiativeData.story)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(paragraph, style: AppText.body),
                    ),
                ],
              ),
              _Panel(
                title: 'كيف شارك الزوار',
                children: [
                  for (var i = 0; i < InitiativeData.steps.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text('${i + 1}. ${InitiativeData.steps[i]}',
                          style: AppText.body),
                    ),
                ],
              ),
              if (InitiativeData.team.isNotEmpty)
                _Panel(
                  title: 'الفريق',
                  children: [
                    Text(InitiativeData.team.join('، '), style: AppText.body),
                  ],
                ),
              if (park != null)
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => PlaceDetailScreen(place: park)),
                  ),
                  child: Text('عن ${park.name}'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Panel({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.section),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

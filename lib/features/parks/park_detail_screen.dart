import 'package:flutter/material.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';
import 'package:hail_parks_guide/models/park_model.dart';

class ParkDetailScreen extends StatelessWidget {
  final ParkModel park;

  const ParkDetailScreen({super.key, required this.park});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.darkGreen,
            foregroundColor: AppColors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                park.name,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Image.network(
                park.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.darkGreen, AppColors.mediumBrown],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(Icons.park,
                      size: 80, color: AppColors.paleGreen),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildInfoRow(Icons.location_on, park.location),
                  if (park.openingHours.isNotEmpty)
                    _buildInfoRow(Icons.access_time, park.openingHours),
                  const SizedBox(height: 16),
                  _buildSectionTitle('عن الحديقة'),
                  Text(
                    park.description,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.darkText,
                      height: 1.6,
                    ),
                  ),
                  if (park.facilities.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildSectionTitle('المرافق'),
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 8,
                      runSpacing: 8,
                      children: park.facilities
                          .map((facility) => Chip(
                                label: Text(facility),
                                backgroundColor: AppColors.paleGreen,
                                labelStyle:
                                    const TextStyle(color: AppColors.darkGreen),
                                side: BorderSide.none,
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(text,
              style: const TextStyle(fontSize: 14, color: AppColors.mediumBrown)),
          const SizedBox(width: 6),
          Icon(icon, size: 18, color: AppColors.mediumBrown),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: AppColors.darkGreen,
        ),
      ),
    );
  }
}

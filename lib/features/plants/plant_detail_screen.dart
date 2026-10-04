import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';
import 'package:hail_parks_guide/core/widgets/smart_image.dart';
import 'package:hail_parks_guide/models/plant_model.dart';
import 'package:hail_parks_guide/providers/favorites_provider.dart';

class PlantDetailScreen extends StatelessWidget {
  final Plant plant;

  const PlantDetailScreen({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final isFavorite = favorites.isFavoritePlant(plant.id);

    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.darkGreen,
            foregroundColor: AppColors.white,
            actions: [
              IconButton(
                tooltip: 'المفضلة',
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                onPressed: () => favorites.togglePlant(plant.id),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: SmartImage(imageData: plant.image),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    plant.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  Text(
                    plant.scientificName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: AppColors.mediumGrey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Chip(
                    label: Text(plant.type),
                    backgroundColor: AppColors.paleGreen,
                    labelStyle: const TextStyle(color: AppColors.darkGreen),
                    side: BorderSide.none,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'عن النبات',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    plant.description,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.darkText,
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

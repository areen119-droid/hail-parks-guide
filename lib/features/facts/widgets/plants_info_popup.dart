import 'package:flutter/material.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';
import 'package:hail_parks_guide/models/plant_model.dart';

class PlantInfoPopup extends StatelessWidget {
  final Plant plant;
  const PlantInfoPopup({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.whiteColor,

      title: Text(
        plant.name,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          Image.network(
            plant.image,
            errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.image_not_supported),
          ),

          const SizedBox(height: 14),

          Text(
            plant.description,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
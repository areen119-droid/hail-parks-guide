import 'package:flutter/material.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';
import 'package:hail_parks_guide/core/widgets/smart_image.dart';
import 'package:hail_parks_guide/models/place_model.dart';

/// A place's photo, or a warm gradient with its category icon when it has none.
class PlaceImage extends StatelessWidget {
  final PlaceModel place;
  final String? image; // defaults to the place's main photo
  final double? width;
  final double? height;

  const PlaceImage({
    super.key,
    required this.place,
    this.image,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final src = image ?? place.image;
    if (src.isNotEmpty) {
      return SmartImage(
        imageData: src,
        width: width,
        height: height,
        placeholderIcon: place.category.icon,
      );
    }
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.brownMedium, AppColors.accent],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => Icon(
          place.category.icon,
          size: constraints.maxHeight.isFinite
              ? constraints.maxHeight * 0.35
              : 48,
          color: AppColors.sandLight.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

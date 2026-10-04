import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';

/// Displays an asset path, a base64 encoded image, or a network image URL.
/// Shows [placeholderIcon] when the image is empty or fails to load.
class SmartImage extends StatelessWidget {
  final String imageData;
  final double? width;
  final double? height;
  final BoxFit fit;
  final IconData placeholderIcon;

  const SmartImage({
    super.key,
    required this.imageData,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholderIcon = Icons.local_florist,
  });

  bool get isAsset => imageData.startsWith('assets/');
  bool get isBase64 => imageData.startsWith('data:image');

  @override
  Widget build(BuildContext context) {
    if (imageData.isEmpty) return _placeholder();

    if (isAsset) {
      return Image.asset(
        imageData,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    if (isBase64) {
      try {
        return Image.memory(
          base64Decode(imageData.split(',').last),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) => _placeholder(),
        );
      } catch (e) {
        return _placeholder();
      }
    }

    return Image.network(
      imageData,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.lightSand,
      child: Icon(placeholderIcon, size: 48, color: AppColors.mediumGrey),
    );
  }
}

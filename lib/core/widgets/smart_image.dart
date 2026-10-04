import 'dart:convert';
import 'package:flutter/material.dart';

/// Displays either a base64 encoded image or a network image URL
class SmartImage extends StatelessWidget {
  final String imageData;
  final double? width;
  final double? height;
  final BoxFit fit;

  const SmartImage({
    super.key,
    required this.imageData,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  bool get isBase64 => imageData.startsWith('data:image');

  @override
  Widget build(BuildContext context) {
    if (imageData.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: const Icon(Icons.local_florist, color: Colors.grey),
      );
    }

    if (isBase64) {
      final base64Str = imageData.split(',').last;
      try {
        final bytes = base64Decode(base64Str);
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) => Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Icon(Icons.image_not_supported),
          ),
        );
      } catch (e) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const Icon(Icons.image_not_supported),
        );
      }
    }

    // Regular network URL
    return Image.network(
      imageData,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: const Icon(Icons.image_not_supported),
      ),
    );
  }
}
import 'package:flutter/material.dart';

enum PlaceCategory {
  park('حدائق ومتنزهات', Icons.park),
  nature('جبال وطبيعة', Icons.terrain),
  heritage('تراث وتاريخ', Icons.account_balance),
  restaurant('مطاعم', Icons.restaurant),
  cafe('مقاهي', Icons.local_cafe);

  final String label;
  final IconData icon;
  const PlaceCategory(this.label, this.icon);

  /// Restaurants and cafes are shown on the side, not in the main lists.
  bool get isFood => this == restaurant || this == cafe;

  /// Categories shown in the main places list, parks first.
  static const List<PlaceCategory> main = [park, nature, heritage];
}

class PlaceModel {
  final String id;
  final String name;
  final PlaceCategory category;
  final String description;
  final String location; // area, e.g. "وسط مدينة حائل"
  final double? latitude; // null until the exact location is known
  final double? longitude;
  final String image; // asset path or network URL, empty for placeholder
  final List<String> gallery; // extra photos shown on the details page
  final String openingHours;
  final List<String> facilities;

  const PlaceModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.location,
    this.latitude,
    this.longitude,
    this.image = '',
    this.gallery = const [],
    this.openingHours = '',
    this.facilities = const [],
  });

  bool get hasLocation => latitude != null && longitude != null;
}

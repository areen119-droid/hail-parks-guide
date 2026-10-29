import 'dart:math';
import 'package:hail_parks_guide/data/hail_data.dart';
import 'package:hail_parks_guide/models/place_model.dart';

/// Straight-line distance in km between two points (haversine formula).
double distanceKm(double lat1, double lon1, double lat2, double lon2) {
  const earthRadiusKm = 6371.0;
  double rad(double deg) => deg * pi / 180;
  final dLat = rad(lat2 - lat1);
  final dLon = rad(lon2 - lon1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(rad(lat1)) * cos(rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
  return earthRadiusKm * 2 * atan2(sqrt(a), sqrt(1 - a));
}

/// Restaurants and cafes closest to [place], nearest first, with distances in km.
List<(PlaceModel, double)> nearbyFood(PlaceModel place, {int limit = 4}) {
  if (!place.hasLocation) return [];
  final results = [
    for (final p in HailData.places)
      if (p.category.isFood && p.hasLocation)
        (p, distanceKm(place.latitude!, place.longitude!, p.latitude!, p.longitude!)),
  ]..sort((a, b) => a.$2.compareTo(b.$2));
  return results.take(limit).toList();
}

/// "350 م" under a kilometer, otherwise "4.2 كم".
String formatKm(double km) =>
    km < 1 ? '${(km * 1000).round()} م' : '${km.toStringAsFixed(1)} كم';

/// "داخل المدينة" or "≈ 90 كم" from Hail city center, or null if unknown.
String? distanceFromHailLabel(PlaceModel place) {
  if (!place.hasLocation) return null;
  final km = distanceKm(HailData.hailLatitude, HailData.hailLongitude,
      place.latitude!, place.longitude!);
  if (km < 5) return 'داخل المدينة';
  return '≈ ${km.round()} كم';
}

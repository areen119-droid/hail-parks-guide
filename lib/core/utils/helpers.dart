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

/// "داخل المدينة" or "≈ 90 كم" from Hail city center, or null if unknown.
String? distanceFromHailLabel(PlaceModel place) {
  if (!place.hasLocation) return null;
  final km = distanceKm(HailData.hailLatitude, HailData.hailLongitude,
      place.latitude!, place.longitude!);
  if (km < 10) return 'داخل المدينة';
  return '≈ ${km.round()} كم';
}

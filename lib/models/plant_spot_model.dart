import 'package:cloud_firestore/cloud_firestore.dart';

class PlantSpot {
  final String id;
  final double latitude;
  final double longitude;
  final bool isPlanted;

  PlantSpot({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.isPlanted,
  });

  factory PlantSpot.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return PlantSpot(
      id: doc.id,
      latitude: parseDouble(data['latitude']),
      longitude: parseDouble(data['longitude']),
      isPlanted: data['isPlanted'] ?? false,
    );
  }
}
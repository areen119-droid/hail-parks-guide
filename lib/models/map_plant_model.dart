import 'package:cloud_firestore/cloud_firestore.dart';

class MapPlant {
  final String id;
  final String name;
  final String catalogPlantName;
  final String catalogPlantId;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final String ownerUsername;
  final DateTime plantedDate;
  final DateTime? lastWatered;
  final int waterCount;
  final int wateringInterval;

  MapPlant({
    required this.id,
    required this.name,
    required this.catalogPlantName,
    required this.catalogPlantId,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.ownerUsername,
    required this.plantedDate,
    this.lastWatered,
    required this.waterCount,
    required this.wateringInterval,
  });

  int daysUntilWater() {
    final base = lastWatered ?? plantedDate;
    final daysPassed = DateTime.now().difference(base).inDays.clamp(0, 9999);
    return wateringInterval - daysPassed;
  }

  bool needsWater() => daysUntilWater() <= 0;

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'catalogPlantName': catalogPlantName,
      'catalogPlantId': catalogPlantId,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'ownerUsername': ownerUsername,
      'plantedDate': Timestamp.fromDate(plantedDate),
      'lastWatered':
      lastWatered != null ? Timestamp.fromDate(lastWatered!) : null,
      'waterCount': waterCount,
      'wateringInterval': wateringInterval,
    };
  }

  factory MapPlant.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    DateTime parseTimestamp(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      return DateTime.tryParse(value.toString()) ?? DateTime.now();
    }

    return MapPlant(
      id: doc.id,
      name: data['name']?.toString() ?? '',
      catalogPlantName: data['catalogPlantName']?.toString() ??
          data['name']?.toString() ??
          '',
      catalogPlantId: data['catalogPlantId']?.toString() ?? '',
      imageUrl: data['imageUrl']?.toString() ?? '',
      latitude: parseDouble(data['latitude']),
      longitude: parseDouble(data['longitude']),
      ownerUsername: data['ownerUsername']?.toString() ??
          data['ownerName']?.toString() ??
          '',
      plantedDate: parseTimestamp(data['plantedDate']),
      lastWatered: data['lastWatered'] != null
          ? parseTimestamp(data['lastWatered'])
          : null,
      waterCount: parseInt(data['waterCount']),
      wateringInterval: parseInt(data['wateringInterval'] ?? 3).clamp(1, 365),
    );
  }
}
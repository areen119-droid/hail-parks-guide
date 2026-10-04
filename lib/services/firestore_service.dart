import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hail_parks_guide/models/map_plant_model.dart';
class FirestoreService {
  final _db = FirebaseFirestore.instance;

  Future<void> addPlant(MapPlant plant) async {
    await _db.collection('map_plants').add({
      'name': plant.name,
      'imageUrl': plant.imageUrl,
      'latitude': plant.latitude,
      'longitude': plant.longitude,
      'ownerUsername': plant.ownerUsername,
      'plantedDate': plant.plantedDate,
      'waterCount': 0,
    });
  }
}
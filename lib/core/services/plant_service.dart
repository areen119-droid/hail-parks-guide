import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hail_parks_guide/models/plant_model.dart';

class PlantService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Plant>> fetchPlants() async {
    final snapshot = await _firestore.collection('plants').get();
    return snapshot.docs.map((doc) => Plant.fromFirestore(doc)).toList();
  }
}
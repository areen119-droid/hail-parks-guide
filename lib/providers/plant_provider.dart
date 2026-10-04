import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hail_parks_guide/models/plant_model.dart';
//now reads from the plants collection in Firestore
class PlantProvider extends ChangeNotifier {
  List<Plant> plants = [];
  bool isLoading = false;

  Future<void> loadPlants() async {
    isLoading = true;
    notifyListeners();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('plants')
          .get();

      plants = snapshot.docs
          .map((doc) => Plant.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error loading plants: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
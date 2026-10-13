import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hail_parks_guide/data/hail_data.dart';
import 'package:hail_parks_guide/models/place_model.dart';
import 'package:hail_parks_guide/models/plant_model.dart';

/// Favorite places and plants, saved on the device.
class FavoritesProvider extends ChangeNotifier {
  static const _placesKey = 'favorite_places';
  static const _plantsKey = 'favorite_plants';

  final Set<String> _placeIds = {};
  final Set<String> _plantIds = {};

  FavoritesProvider() {
    _load();
  }

  List<PlaceModel> get favoritePlaces =>
      HailData.places.where((place) => _placeIds.contains(place.id)).toList();

  List<Plant> get favoritePlants =>
      HailData.plants.where((plant) => _plantIds.contains(plant.id)).toList();

  bool isFavoritePlace(String id) => _placeIds.contains(id);
  bool isFavoritePlant(String id) => _plantIds.contains(id);

  void togglePlace(String id) => _toggle(_placeIds, id, _placesKey);
  void togglePlant(String id) => _toggle(_plantIds, id, _plantsKey);

  Future<void> clearAll() async {
    _placeIds.clear();
    _plantIds.clear();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_placesKey);
    await prefs.remove(_plantsKey);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _placeIds.addAll(prefs.getStringList(_placesKey) ?? []);
    _plantIds.addAll(prefs.getStringList(_plantsKey) ?? []);
    notifyListeners();
  }

  Future<void> _toggle(Set<String> ids, String id, String key) async {
    if (!ids.remove(id)) ids.add(id);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, ids.toList());
  }
}

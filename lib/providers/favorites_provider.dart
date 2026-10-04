import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hail_parks_guide/data/hail_data.dart';
import 'package:hail_parks_guide/models/park_model.dart';
import 'package:hail_parks_guide/models/plant_model.dart';

/// Favorite parks and plants, saved on the device.
class FavoritesProvider extends ChangeNotifier {
  static const _parksKey = 'favorite_parks';
  static const _plantsKey = 'favorite_plants';

  final Set<String> _parkIds = {};
  final Set<String> _plantIds = {};

  FavoritesProvider() {
    _load();
  }

  List<ParkModel> get favoriteParks =>
      HailData.parks.where((park) => _parkIds.contains(park.id)).toList();

  List<Plant> get favoritePlants =>
      HailData.plants.where((plant) => _plantIds.contains(plant.id)).toList();

  bool isFavoritePark(String id) => _parkIds.contains(id);
  bool isFavoritePlant(String id) => _plantIds.contains(id);

  void togglePark(String id) => _toggle(_parkIds, id, _parksKey);
  void togglePlant(String id) => _toggle(_plantIds, id, _plantsKey);

  Future<void> clearAll() async {
    _parkIds.clear();
    _plantIds.clear();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_parksKey);
    await prefs.remove(_plantsKey);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _parkIds.addAll(prefs.getStringList(_parksKey) ?? []);
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

import 'package:flutter/foundation.dart';

/// Bottom navigation state, so any screen can switch tabs or
/// ask the map to show a specific park.
class NavigationProvider extends ChangeNotifier {
  static const int homeTab = 0;
  static const int mapTab = 1;
  static const int plantsTab = 2;
  static const int profileTab = 3;

  int _tabIndex = homeTab;
  String? _parkToShowOnMap;

  int get tabIndex => _tabIndex;

  void selectTab(int index) {
    if (index == _tabIndex) return;
    _tabIndex = index;
    notifyListeners();
  }

  /// Opens the map tab centered on [parkId].
  void showParkOnMap(String parkId) {
    _parkToShowOnMap = parkId;
    _tabIndex = mapTab;
    notifyListeners();
  }

  /// Returns the park the map should focus on, once.
  String? takeParkToShowOnMap() {
    final id = _parkToShowOnMap;
    _parkToShowOnMap = null;
    return id;
  }
}

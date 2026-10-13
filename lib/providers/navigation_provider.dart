import 'package:flutter/foundation.dart';

/// Bottom navigation state, so any screen can switch tabs, ask the map to
/// show a specific place, or open the guide with a request.
class NavigationProvider extends ChangeNotifier {
  static const int homeTab = 0;
  static const int mapTab = 1;
  static const int guideTab = 2;
  static const int plantsTab = 3;
  static const int profileTab = 4;

  int _tabIndex = homeTab;
  String? _placeToShowOnMap;
  bool _plannerRequested = false;
  String? _guideQuestion;

  int get tabIndex => _tabIndex;

  void selectTab(int index) {
    if (index == _tabIndex) return;
    _tabIndex = index;
    notifyListeners();
  }

  /// Opens the map tab centered on [placeId].
  void showPlaceOnMap(String placeId) {
    _placeToShowOnMap = placeId;
    _tabIndex = mapTab;
    notifyListeners();
  }

  /// Returns the place the map should focus on, once.
  String? takePlaceToShowOnMap() {
    final id = _placeToShowOnMap;
    _placeToShowOnMap = null;
    return id;
  }

  /// Opens the guide tab, optionally with the trip planner or a question.
  void openGuide({bool planner = false, String? question}) {
    _plannerRequested = planner;
    _guideQuestion = question;
    _tabIndex = guideTab;
    notifyListeners();
  }

  /// Returns whether the planner should open, once.
  bool takePlannerRequest() {
    final requested = _plannerRequested;
    _plannerRequested = false;
    return requested;
  }

  /// Returns the question the guide should be asked, once.
  String? takeGuideQuestion() {
    final question = _guideQuestion;
    _guideQuestion = null;
    return question;
  }
}

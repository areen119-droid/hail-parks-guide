import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The app's two looks. Both use the same data, guide and planner.
enum AppDesign {
  /// Rock-art field journal: paper, basalt ink and red ochre.
  journal('التصميم الجديد'),

  /// The earlier green and sand design.
  classic('التصميم الكلاسيكي');

  final String label;
  const AppDesign(this.label);
}

/// Which design is shown, saved on the device.
class DesignProvider extends ChangeNotifier {
  static const _key = 'app_design';

  /// The app ships with the journal design only. Set to true to let users
  /// switch back to the classic design (its code is kept in lib/features).
  static const bool switchable = false;

  AppDesign _design = AppDesign.journal;
  bool _loaded = false;

  DesignProvider() {
    _load();
  }

  AppDesign get design => _design;

  /// False until the saved choice is read, so the app doesn't flash the
  /// wrong design on start.
  bool get loaded => _loaded;

  Future<void> setDesign(AppDesign design) async {
    if (design == _design) return;
    _design = design;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, design.name);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (switchable) {
      _design = AppDesign.values.where((d) => d.name == saved).firstOrNull ?? _design;
    }
    _loaded = true;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:hail_parks_guide/providers/user_provider.dart';

class HomeProvider extends ChangeNotifier {
  final UserProvider _userProvider;
  bool _isDisposed = false;
  bool _initialized = false;

  HomeProvider({required UserProvider userProvider})
      : _userProvider = userProvider {
    _userProvider.addListener(_onUserChanged);
  }

  void _onUserChanged() {
    if (_isDisposed) return;
    final userId = _userProvider.currentUser?.id;
    if (userId != null && userId.isNotEmpty && !_initialized) {
      _initialized = true;
      notifyListeners();
    }
  }

  Future<void> initialize() async {
    if (_isDisposed) return;
    final userId = _userProvider.currentUser?.id;
    if (userId != null && userId.isNotEmpty) {
      _initialized = true;
      notifyListeners();
    }
  }

  String get userName =>
      _userProvider.currentUser?.name ?? 'المستخدم';

  int get visitedCount => 0; // implement later with Firestore
  int get savedCount => 0;   // implement later with Firestore

  void reset() {
    _initialized = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _userProvider.removeListener(_onUserChanged);
    super.dispose();
  }
}
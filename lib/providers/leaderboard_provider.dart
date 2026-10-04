import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/leaderboard_model.dart';

class LeaderboardProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<LeaderboardEntry> _globalLeaderboard = [];
  bool _isLoading = false;
  String? _error;
  bool _isDisposed = false;

  List<LeaderboardEntry> get globalLeaderboard => _globalLeaderboard;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _safeNotify() {
    if (!_isDisposed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed) {
          notifyListeners();
        }
      });
    }
  }

  Future<List<LeaderboardEntry>> getGlobalLeaderboard() async {
    if (_isDisposed) return _globalLeaderboard;

    _setLoading(true);
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('points', descending: true)
          .limit(100)
          .get();

      print('📊 Firestore returned ${snapshot.docs.length} users');

      int rank = 1;
      _globalLeaderboard = snapshot.docs.map((doc) {
        final data = doc.data();
        return LeaderboardEntry(
          userId: doc.id,
          name: data['name'] ?? 'مستخدم',
          username: data['username'] ?? 'user',
          profileImageUrl: data['profileImageUrl'],
          points: data['points'] ?? 0,
          streak: data['streak'] ?? 0,
          plantsPlanted: (data['mapPlant'] as List?)?.length ?? 0,
          plantsWatered: data['plantsWatered'] ?? 0,
          rank: rank++,
          rankChange: 0,
          city: data['city'] ?? '',
        );
      }).toList();

      _setLoading(false);
      return _globalLeaderboard;
    } catch (e) {
      print('❌ Error loading leaderboard: $e');
      _setError(e.toString());
      _setLoading(false);
      return [];
    }
  }

  Stream<List<LeaderboardEntry>> streamGlobalLeaderboard() {
    if (_isDisposed) return Stream.empty();

    return _firestore
        .collection('users')
        .orderBy('points', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
      int rank = 1;
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return LeaderboardEntry(
          userId: doc.id,
          name: data['name'] ?? 'مستخدم',
          username: data['username'] ?? 'user',
          profileImageUrl: data['profileImageUrl'],
          points: data['points'] ?? 0,
          streak: data['streak'] ?? 0,
          plantsPlanted: (data['mapPlant'] as List?)?.length ?? 0,
          plantsWatered: data['plantsWatered'] ?? 0,
          rank: rank++,
          rankChange: 0,
          city: data['city'] ?? '',
        );
      }).toList();
    });
  }

  void _setLoading(bool loading) {
    if (_isDisposed) return;
    _isLoading = loading;
    _safeNotify();
  }

  void _setError(String errorMessage) {
    if (_isDisposed) return;
    _error = errorMessage;
    _safeNotify();
  }

  void clearError() {
    if (_isDisposed) return;
    _error = null;
    _safeNotify();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
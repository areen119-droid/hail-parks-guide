import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hail_parks_guide/providers/user_provider.dart';
import 'package:hail_parks_guide/providers/plant_provider.dart';
import 'package:hail_parks_guide/models/user_model.dart';
import 'package:hail_parks_guide/models/plant_model.dart';

class SearchProvider extends ChangeNotifier {
  final UserProvider _userProvider;
  final PlantProvider _plantProvider;

  List<UserModel> _userResults = [];
  List<Plant> _plantResults = [];
  bool _isLoading = false;
  String? _error;
  String _currentQuery = '';

  List<UserModel> get userResults => _userResults;
  List<Plant> get plantResults => _plantResults;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentQuery => _currentQuery;

  SearchProvider(this._userProvider, this._plantProvider);

  Future<void> search(String query) async {
    if (query.isEmpty) {
      _clearResults();
      return;
    }

    _currentQuery = query;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        _searchUsers(query),
        _searchPlants(query),
      ]);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search users directly from Firestore
  Future<void> _searchUsers(String query) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();

      final lowerQuery = query.toLowerCase();

      _userResults = snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc.data(), doc.id))
          .where((user) =>
      user.name.toLowerCase().contains(lowerQuery) ||
          user.username.toLowerCase().contains(lowerQuery))
          .toList();
    } catch (e) {
      debugPrint('Error searching users: $e');
      _userResults = [];
    }
  }

  // Search plants directly from Firestore
  Future<void> _searchPlants(String query) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('plants')
          .get();

      final lowerQuery = query.toLowerCase();

      _plantResults = snapshot.docs
          .map((doc) => Plant.fromFirestore(doc))
          .where((plant) => plant.name.toLowerCase().contains(lowerQuery))
          .toList();
    } catch (e) {
      debugPrint('Error searching plants: $e');
      _plantResults = [];
    }
  }

  Future<void> toggleFollow(String userId) async {
    final currentUserId = _userProvider.currentUser?.id ?? '';
    if (currentUserId.isEmpty) return;

    final index = _userResults.indexWhere((u) => u.id == userId);
    if (index != -1) {
      final user = _userResults[index];
      if (user.isFollowing) {
        await _userProvider.unfollowUser(currentUserId, userId);
        _userResults[index] = user.copyWith(isFollowing: false);
      } else {
        await _userProvider.followUser(currentUserId, userId);
        _userResults[index] = user.copyWith(isFollowing: true);
      }
      notifyListeners();
    }
  }

  void _clearResults() {
    _userResults = [];
    _plantResults = [];
    _currentQuery = '';
    notifyListeners();
  }

  void clear() {
    _clearResults();
    _error = null;
  }
}
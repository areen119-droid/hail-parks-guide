import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hail_parks_guide/core/services/firestore_service.dart';
import 'package:hail_parks_guide/models/user_model.dart';
import 'package:hail_parks_guide/models/map_plant_model.dart';

class UserProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;
  List<UserModel> _allUsers = [];
  bool _isLoading = false;
  bool _isLoadingAllUsers = false;
  String? _error;
  bool _isDisposed = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoadingAllUsers => _isLoadingAllUsers;
  List<UserModel> get allUsers => _allUsers;
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

  void setLoggedInUser(UserModel user) {
    if (_isDisposed) return;
    _currentUser = user;
    _safeNotify();
  }

  void clearLoggedInUser() {
    if (_isDisposed) return;
    _currentUser = null;
    _safeNotify();
  }

  Future<UserModel?> loadUserData(String userId) async {
    if (_isDisposed) return _currentUser;

    print('🟡 UserProvider.loadUserData for ID: $userId');
    _setLoading(true);
    try {
      _currentUser = await _firestoreService.getUser(userId);
      print('🟡 User found: ${_currentUser?.name ?? "NOT FOUND"}');
      _setLoading(false);
      return _currentUser;
    } catch (e) {
      print('🟡 Error: $e');
      _setError(e.toString());
      _setLoading(false);
      return null;
    }
  }

  Future<UserModel?> loadLoggedInUserData(String userId) async {
    return loadUserData(userId);
  }

  Future<UserModel?> loadUserToView(String username) async {
    if (_isDisposed) return null;

    try {
      final snapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return UserModel.fromFirestore(snapshot.docs.first.data(), snapshot.docs.first.id);
      }
      return null;
    } catch (e) {
      print('Error loading user to view: $e');
      return null;
    }
  }

  Future<bool> isFollowing(String currentUserId, String targetUserId) async {
    if (_isDisposed) return false;

    try {
      final doc = await _firestore.collection('users').doc(currentUserId).get();
      final data = doc.data();
      final friendIds = List<String>.from(data?['friendIds'] ?? []);
      return friendIds.contains(targetUserId);
    } catch (e) {
      print('Error checking follow status: $e');
      return false;
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    if (_isDisposed) return [];

    _isLoadingAllUsers = true;
    _safeNotify();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();

      _allUsers = snapshot.docs.map((doc) =>
          UserModel.fromFirestore(doc.data(), doc.id)
      ).toList();

      _isLoadingAllUsers = false;
      _safeNotify();
      return _allUsers;
    } catch (e) {
      print('Error loading all users: $e');
      _isLoadingAllUsers = false;
      _safeNotify();
      return [];
    }
  }

  Future<bool> updateUserProfile(String userId, Map<String, dynamic> updates) async {
    if (_isDisposed) return false;

    _setLoading(true);

    try {
      await _firestoreService.updateUser(userId, updates);

      if (_currentUser != null && _currentUser!.id == userId) {
        _currentUser = UserModel(
          id: _currentUser!.id,
          name: updates['name'] ?? _currentUser!.name,
          username: updates['username'] ?? _currentUser!.username,
          email: updates['email'] ?? _currentUser!.email,
          profileImageUrl: updates['profileImageUrl'] ?? _currentUser!.profileImageUrl,
          bio: updates['bio'] ?? _currentUser!.bio,
          city: updates['city'] ?? _currentUser!.city,
          phoneNumber: updates['phoneNumber'] ?? _currentUser!.phoneNumber,
          gender: updates['gender'] ?? _currentUser!.gender,
          points: _currentUser!.points,
          streak: _currentUser!.streak,
          friendsCount: _currentUser!.friendsCount,
          friendIds: _currentUser!.friendIds,
          mapPlant: _currentUser!.mapPlant,
          photos: _currentUser!.photos,
          isFollowing: _currentUser!.isFollowing,
          createdAt: _currentUser!.createdAt,
        );
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> addPlantToUser(String userId, MapPlant plant) async {
    if (_isDisposed) return false;

    _setLoading(true);

    try {
      final user = await _firestoreService.getUser(userId);
      if (user != null) {
        List<MapPlant> updatedPlants = List.from(user.mapPlant)..add(plant);

        await _firestoreService.updateUser(userId, {
          'mapPlant': updatedPlants.map((p) => p.toFirestore()).toList(),
        });

        if (_currentUser != null && _currentUser!.id == userId) {
          _currentUser = UserModel(
            id: _currentUser!.id,
            name: _currentUser!.name,
            username: _currentUser!.username,
            email: _currentUser!.email,
            profileImageUrl: _currentUser!.profileImageUrl,
            bio: _currentUser!.bio,
            city: _currentUser!.city,
            phoneNumber: _currentUser!.phoneNumber,
            gender: _currentUser!.gender,
            points: _currentUser!.points,
            streak: _currentUser!.streak,
            friendsCount: _currentUser!.friendsCount,
            friendIds: _currentUser!.friendIds,
            mapPlant: updatedPlants,
            photos: _currentUser!.photos,
            isFollowing: _currentUser!.isFollowing,
            createdAt: _currentUser!.createdAt,
          );
        }
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> awardPoints(String userId, int points) async {
    if (_isDisposed) return;

    try {
      await _firestoreService.updateUser(userId, {
        'points': FieldValue.increment(points),
      });

      if (_currentUser != null && _currentUser!.id == userId) {
        _currentUser = UserModel(
          id: _currentUser!.id,
          name: _currentUser!.name,
          username: _currentUser!.username,
          email: _currentUser!.email,
          profileImageUrl: _currentUser!.profileImageUrl,
          bio: _currentUser!.bio,
          city: _currentUser!.city,
          phoneNumber: _currentUser!.phoneNumber,
          gender: _currentUser!.gender,
          points: _currentUser!.points + points,
          streak: _currentUser!.streak,
          friendsCount: _currentUser!.friendsCount,
          friendIds: _currentUser!.friendIds,
          mapPlant: _currentUser!.mapPlant,
          photos: _currentUser!.photos,
          isFollowing: _currentUser!.isFollowing,
          createdAt: _currentUser!.createdAt,
        );
        _safeNotify();
      }
    } catch (e) {
      print('Error awarding points: $e');
      rethrow;
    }
  }

  Future<void> followUser(String currentUserId, String targetUserId) async {
    if (_isDisposed) return;

    if (currentUserId == targetUserId) {
      print('❌ Cannot follow yourself');
      return;
    }

    try {
      await _firestore.collection('users').doc(currentUserId).update({
        'friendIds': FieldValue.arrayUnion([targetUserId]),
        'friendsCount': FieldValue.increment(1),
      });

      await _firestore.collection('users').doc(targetUserId).update({
        'followers': FieldValue.arrayUnion([currentUserId]),
      });

      print('✅ Successfully followed user $targetUserId');
    } catch (e) {
      print('❌ Error following user: $e');
      rethrow;
    }
  }

  Future<void> unfollowUser(String currentUserId, String targetUserId) async {
    if (_isDisposed) return;

    if (currentUserId == targetUserId) {
      print('❌ Cannot unfollow yourself');
      return;
    }

    try {
      await _firestore.collection('users').doc(currentUserId).update({
        'friendIds': FieldValue.arrayRemove([targetUserId]),
        'friendsCount': FieldValue.increment(-1),
      });

      await _firestore.collection('users').doc(targetUserId).update({
        'followers': FieldValue.arrayRemove([currentUserId]),
      });

      print('✅ Successfully unfollowed user $targetUserId');
    } catch (e) {
      print('❌ Error unfollowing user: $e');
      rethrow;
    }
  }

  void clearError() {
    if (_isDisposed) return;
    _error = null;
    _safeNotify();
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

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
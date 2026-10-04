import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hail_parks_guide/core/services/firebase_auth_service.dart';
import 'package:hail_parks_guide/core/services/firestore_service.dart';
import 'package:hail_parks_guide/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirestoreService _firestoreService = FirestoreService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;

  Function(UserModel)? onUserLoggedIn;

  AuthProvider() {
    print('🟢 AuthProvider created');
    _authService.authStateChanges.listen((User? user) async {
      print('🟢 Auth state changed: ${user?.uid ?? "null"}');
      if (user != null) {
        print('🟢 Fetching user from Firestore for ID: ${user.uid}');
        _currentUser = await _firestoreService.getUser(user.uid);
        print('🟢 User from Firestore: ${_currentUser?.name ?? "not found"}');

        // FIX: always fire the callback when user is available,
        // including on app restart when already logged in
        if (_currentUser != null && onUserLoggedIn != null) {
          onUserLoggedIn!(_currentUser!);
        } else if (_currentUser != null) {
          // callback not set yet (race on startup) — retry after frame
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_currentUser != null && onUserLoggedIn != null) {
              onUserLoggedIn!(_currentUser!);
            }
          });
        }

        notifyListeners();
      } else {
        print('🟢 User signed out');
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      print('Error signing out: $e');
      _currentUser = null;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> createNewUserProfile({
    required String userId,
    required String phoneNumber,
    required String name,
    required String username,
    required String email,
    String bio = '',
    String? city,
    String? gender,
  }) async {
    await _firestoreService.createUserProfile(userId, {
      'name': name,
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'bio': bio,
      'city': city ?? '',
      'gender': gender ?? 'Female',
    });
    _currentUser = await _firestoreService.getUser(userId);

    if (_currentUser != null && onUserLoggedIn != null) {
      onUserLoggedIn!(_currentUser!);
    }

    notifyListeners();
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.signInWithEmail(email, password);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> registerWithEmail({
    required String email,
    required String password,
    required String name,
    String phoneNumber = '',
    String city = '',
    String gender = 'Female',
  }) async {
    _setLoading(true);
    _clearError();

    try {
      UserCredential userCredential = await _authService.registerWithEmail(
        email: email,
        password: password,
        name: name,
        phoneNumber: phoneNumber,
        city: city,
        gender: gender,
      );

      if (userCredential.user != null) {
        await createNewUserProfile(
          userId: userCredential.user!.uid,
          phoneNumber: phoneNumber,
          name: name,
          username: name.toLowerCase().replaceAll(' ', '_'),
          email: email,
          bio: '',
          city: city,
          gender: gender,
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

  Future<void> loadUserProfile(String userId) async {
    _currentUser = await _firestoreService.getUser(userId);

    if (_currentUser != null && onUserLoggedIn != null) {
      onUserLoggedIn!(_currentUser!);
    }

    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
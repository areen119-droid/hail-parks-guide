import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hail_parks_guide/models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get user data
  Future<UserModel?> getUser(String userId) async {
    print('🔴 FirestoreService.getUser for ID: $userId');
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      print('🔴 Document exists: ${doc.exists}');
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        print('🔴 Data: name=${data['name']}, points=${data['points']}');
        return UserModel.fromFirestore(data, doc.id);
      }
      return null;
    } catch (e) {
      print('🔴 Error: $e');
      return null;
    }
  }

  // Create user profile - UPDATED with city and phoneNumber
  Future<void> createUserProfile(String userId, Map<String, dynamic> userData) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'uid': userId,
        'name': userData['name'] ?? '',
        'username': userData['username'] ?? '',
        'email': userData['email'] ?? '',
        'phoneNumber': userData['phoneNumber'] ?? '', // Phone number from parameter
        'city': userData['city'] ?? '', // City from parameter
        'profileImageUrl': userData['profileImageUrl'] ?? '',
        'bio': userData['bio'] ?? '',
        'gender': userData['gender'] ?? '',
        'points': 0,
        'streak': 0,
        'friendsCount': 0,
        'friendIds': [],
        'mapPlant': [],
        'photos': [],
        'createdAt': FieldValue.serverTimestamp(),
        'lastActive': FieldValue.serverTimestamp(),
      });
      print('✅ User profile created successfully for: ${userId}');
    } catch (e) {
      print('❌ Error creating user profile: $e');
      rethrow;
    }
  }

  // Stream user data (real-time updates)
  Stream<UserModel?> streamUser(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return UserModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    });
  }

  // Update user data
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).update(data);
      print('✅ User updated successfully for: $userId');
    } catch (e) {
      print('❌ Error updating user: $e');
      rethrow;
    }
  }
}
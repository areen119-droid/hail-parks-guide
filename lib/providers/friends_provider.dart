import 'package:flutter/material.dart';
import '../models/friend_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/friend_model.dart';

class FriendProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<FriendModel>> getUserFriends(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final friendIds = List<String>.from(userDoc.data()?['friendIds'] ?? []);

      List<FriendModel> friends = [];

      for (String id in friendIds) {
        final friendDoc = await _firestore.collection('users').doc(id).get();
        if (friendDoc.exists) {
          final data = friendDoc.data()!;
          friends.add(FriendModel(
            id: friendDoc.id,
            name: data['name'] ?? '',
            username: data['username'] ?? '',
            profileImageUrl: data['profileImageUrl'],
            points: data['points'] ?? 0,
            plantsPlanted: (data['plants'] as List?)?.length ?? 0,
            city: data['city'] ?? '',
            isOnline: false,
            isFollowing: true, // User is already following them
          ));
        }
      }

      return friends;
    } catch (e) {
      print('Error getting user friends: $e');
      return [];
    }
  }

  // Follow a user
  Future<void> followUser(String currentUserId, String targetUserId) async {
    try {
      // Add to current user's friend list
      await _firestore.collection('users').doc(currentUserId).update({
        'friendIds': FieldValue.arrayUnion([targetUserId]),
        'friendsCount': FieldValue.increment(1),
      });

      // Add to target user's followers list
      await _firestore.collection('users').doc(targetUserId).update({
        'followers': FieldValue.arrayUnion([currentUserId]),
      });
    } catch (e) {
      print('Error following user: $e');
      rethrow;
    }
  }

  // Unfollow a user
  Future<void> unfollowUser(String currentUserId, String targetUserId) async {
    try {
      // Remove from current user's friend list
      await _firestore.collection('users').doc(currentUserId).update({
        'friendIds': FieldValue.arrayRemove([targetUserId]),
        'friendsCount': FieldValue.increment(-1),
      });

      // Remove from target user's followers list
      await _firestore.collection('users').doc(targetUserId).update({
        'followers': FieldValue.arrayRemove([currentUserId]),
      });
    } catch (e) {
      print('Error unfollowing user: $e');
      rethrow;
    }
  }
}
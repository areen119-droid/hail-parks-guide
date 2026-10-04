import 'package:cloud_firestore/cloud_firestore.dart';
class UserPost {
  final String id;
  final String userId;
  final String username;
  final String action; // planted or watered
  final String mediaUrl;
  final String mediaType; // image or video
  final DateTime timestamp;

  UserPost({
    required this.id,
    required this.userId,
    required this.username,
    required this.action,
    required this.mediaUrl,
    required this.mediaType,
    required this.timestamp,
  });

  factory UserPost.fromFirestore(String id, Map<String, dynamic> data) {
    return UserPost(
      id: id,
      userId: data['userId'] ?? '',
      username: data['username'] ?? '',
      action: data['action'] ?? '',
      mediaUrl: data['mediaUrl'] ?? '',
      mediaType: data['mediaType'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'username': username,
      'action': action,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'timestamp': timestamp,
    };
  }
}
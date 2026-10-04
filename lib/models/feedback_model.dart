import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String id;
  final String userId;
  final String userName;
  final String message;
  final double rating;
  final String type; // 'feedback' or 'bug'
  final String? screen;
  final String? severity;
  final DateTime timestamp;
  final String status; // 'pending', 'reviewed', 'resolved'

  FeedbackModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.message,
    required this.rating,
    required this.type,
    this.screen,
    this.severity,
    required this.timestamp,
    this.status = 'pending',
  });

  // From Firestore
  factory FeedbackModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return FeedbackModel(
      id: documentId,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      message: data['message'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      type: data['type'] ?? 'feedback',
      screen: data['screen'],
      severity: data['severity'],
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'pending',
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'message': message,
      'rating': rating,
      'type': type,
      'screen': screen,
      'severity': severity,
      'timestamp': Timestamp.fromDate(timestamp),
      'status': status,
    };
  }

  // Factory for creating feedback
  factory FeedbackModel.createFeedback({
    required String userId,
    required String userName,
    required String message,
    required double rating,
  }) {
    return FeedbackModel(
      id: '', // Will be set by Firestore
      userId: userId,
      userName: userName,
      message: message,
      rating: rating,
      type: 'feedback',
      timestamp: DateTime.now(),
      status: 'pending',
    );
  }

  // Factory for creating bug report
  factory FeedbackModel.createBugReport({
    required String userId,
    required String userName,
    required String message,
    required String screen,
    required String severity,
  }) {
    return FeedbackModel(
      id: '', // Will be set by Firestore
      userId: userId,
      userName: userName,
      message: message,
      rating: 0,
      type: 'bug',
      screen: screen,
      severity: severity,
      timestamp: DateTime.now(),
      status: 'pending',
    );
  }
}
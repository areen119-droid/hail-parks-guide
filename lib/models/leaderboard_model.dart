import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardEntry {
  final String userId;
  final String name;
  final String username;
  final String? profileImageUrl;
  final int points;
  final int streak;
  final int plantsPlanted;
  final int plantsWatered;
  final int rank;
  final int rankChange;
  final String city;

  LeaderboardEntry({
    required this.userId,
    required this.name,
    required this.username,
    this.profileImageUrl,
    required this.points,
    required this.streak,
    required this.plantsPlanted,
    required this.plantsWatered,
    required this.rank,
    required this.rankChange,
    required this.city,
  });

  factory LeaderboardEntry.fromFirestore(Map<String, dynamic> data, String documentId) {
    return LeaderboardEntry(
      userId: documentId,
      name: data['name'] ?? '',
      username: data['username'] ?? '',
      profileImageUrl: data['profileImageUrl'],
      points: data['points'] ?? 0,
      streak: data['streak'] ?? 0,
      plantsPlanted: (data['mapPlant'] as List?)?.length ?? 0,
      plantsWatered: data['plantsWatered'] ?? 0,
      rank: 0,
      rankChange: 0,
      city: data['city'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'username': username,
      'profileImageUrl': profileImageUrl,
      'points': points,
      'streak': streak,
      'plantsPlanted': plantsPlanted,
      'plantsWatered': plantsWatered,
      'city': city,
    };
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hail_parks_guide/models/map_plant_model.dart';

class UserModel {
  final String id;
  final String name;
  final String username;
  final String email;
  final String? profileImageUrl;
  final String bio;
  final String city;
  final String phoneNumber;
  final String gender;
  final int points;
  final int streak;
  final int friendsCount;
  final List<String> friendIds;
  final List<dynamic> mapPlant;
  final List<dynamic> photos;
  bool isFollowing;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.profileImageUrl,
    required this.bio,
    required this.city,
    required this.phoneNumber,
    required this.gender,
    required this.points,
    required this.streak,
    required this.friendsCount,
    required this.friendIds,
    required this.mapPlant,
    required this.photos,
    this.isFollowing = false,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return UserModel(
      id: documentId,
      name: data['name'] ?? '',
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      profileImageUrl: data['profileImageUrl'] != '' && data['profileImageUrl'] != null
          ? data['profileImageUrl']
          : null,
      bio: data['bio'] ?? '',
      city: data['city'] ?? '',
      phoneNumber: data['phoneNumber']?.toString() ?? '', // Convert to string if number
      gender: data['gender'] ?? '',
      points: data['points'] ?? 0,
      streak: data['streak'] ?? 0,
      friendsCount: data['friendsCount'] ?? 0,
      friendIds: List<String>.from(data['friendIds'] ?? data['friendsIds'] ?? []), // Handle both spellings
      mapPlant: data['mapPlant'] ?? [], // Fixed: use mapPlant instead of plants
      photos: List<String>.from(data['photos'] ?? []),
      isFollowing: data['isFollowing'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'username': username,
      'email': email,
      'profileImageUrl': profileImageUrl ?? '',
      'bio': bio,
      'city': city,
      'phoneNumber': phoneNumber,
      'gender': gender,
      'points': points,
      'streak': streak,
      'friendsCount': friendsCount,
      'friendIds': friendIds,
      'mapPlant': mapPlant, // Fixed: use mapPlant instead of plants
      'photos': photos,
      'isFollowing': isFollowing,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // CopyWith method as part of the class
  UserModel copyWith({
    String? id,
    String? name,
    String? username,
    String? email,
    String? profileImageUrl,
    String? bio,
    String? city,
    String? phoneNumber,
    String? gender,
    int? points,
    int? streak,
    int? friendsCount,
    List<String>? friendIds,
    List<dynamic>? mapPlant,
    List<dynamic>? photos,
    bool? isFollowing,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      city: city ?? this.city,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      points: points ?? this.points,
      streak: streak ?? this.streak,
      friendsCount: friendsCount ?? this.friendsCount,
      friendIds: friendIds ?? this.friendIds,
      mapPlant: mapPlant ?? this.mapPlant,
      photos: photos ?? this.photos,
      isFollowing: isFollowing ?? this.isFollowing,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
class FriendModel {
  final String id;
  final String name;
  final String username;
  final String? profileImageUrl;
  final int points;
  final int plantsPlanted;
  final String city;
  final bool isOnline;
  bool isFollowing;

  FriendModel({
    required this.id,
    required this.name,
    required this.username,
    this.profileImageUrl,
    required this.points,
    required this.plantsPlanted,
    required this.city,
    this.isOnline = false,
    this.isFollowing = false,
  });

  // Copy with method for updating
  FriendModel copyWith({
    String? id,
    String? name,
    String? username,
    String? profileImageUrl,
    int? points,
    int? plantsPlanted,
    String? city,
    bool? isOnline,
    bool? isFollowing,
  }) {
    return FriendModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      points: points ?? this.points,
      plantsPlanted: plantsPlanted ?? this.plantsPlanted,
      city: city ?? this.city,
      isOnline: isOnline ?? this.isOnline,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}
class UserModel {
  final String name;
  final String username;
  final String city;
  final String bio;

  const UserModel({
    required this.name,
    required this.username,
    required this.city,
    this.bio = '',
  });
}

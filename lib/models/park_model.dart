class ParkModel {
  final String id;
  final String name;
  final String description;
  final String location;
  final String imageUrl;
  final String openingHours;
  final List<String> facilities;

  const ParkModel({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    this.imageUrl = '',
    this.openingHours = '',
    this.facilities = const [],
  });
}

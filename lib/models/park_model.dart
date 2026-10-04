class ParkModel {
  final String id;
  final String name;
  final String description;
  final String location;
  final double latitude;
  final double longitude;
  final String image; // asset path or network URL, empty for placeholder
  final String openingHours;
  final List<String> facilities;

  const ParkModel({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.latitude,
    required this.longitude,
    this.image = '',
    this.openingHours = '',
    this.facilities = const [],
  });
}

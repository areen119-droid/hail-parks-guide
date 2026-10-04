class Plant {
  final String id;
  final String name;
  final String scientificName;
  final String type; // e.g. wild native plant or ornamental plant
  final String description;
  final String image; // asset path

  const Plant({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.type,
    required this.description,
    required this.image,
  });
}

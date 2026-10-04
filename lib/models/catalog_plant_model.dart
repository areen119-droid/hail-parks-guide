class CatalogPlant {
  final String id;
  final String name;
  final String imageUrl;
  final String description;
  final int wateringInterval; // in days

  CatalogPlant({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.wateringInterval,
  });


  factory CatalogPlant.fromFirestore(Map<String, dynamic> data, String docId) {
    return CatalogPlant(
      id: docId,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? '',
      wateringInterval: data['wateringInterval'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'description': description,
      'wateringInterval': wateringInterval,
    };
  }
}
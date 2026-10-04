import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hail_parks_guide/models/map_plant_model.dart';
import 'package:hail_parks_guide/models/catalog_plant_model.dart';

class PlantInfoTab extends StatefulWidget {
  final MapPlant plant;

  const PlantInfoTab({super.key, required this.plant});

  @override
  State<PlantInfoTab> createState() => _PlantInfoTabState();
}

class _PlantInfoTabState extends State<PlantInfoTab> {
  CatalogPlant? _catalogPlant;

  @override
  void initState() {
    super.initState();
    _loadCatalogPlant();
  }

  Future<void> _loadCatalogPlant() async {
    if (widget.plant.catalogPlantId.isEmpty) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('plant_catalog')
          .doc(widget.plant.catalogPlantId)
          .get();

      if (doc.exists && mounted) {
        setState(() {
          _catalogPlant = CatalogPlant.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id);
        });
      }
    } catch (e) {
      debugPrint('Error loading catalog plant: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final wateringInterval =
        _catalogPlant?.wateringInterval ?? widget.plant.wateringInterval;
    final description = _catalogPlant?.description ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Plant type from catalog
          Text(
            "نوع النبتة: ${widget.plant.catalogPlantName.isNotEmpty ? widget.plant.catalogPlantName : widget.plant.name}",
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),

          // Custom name chosen by user
          if (widget.plant.name.isNotEmpty &&
              widget.plant.name != widget.plant.catalogPlantName)
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "اسم النبتة: ${widget.plant.name}",
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
              ],
            ),

          // Planted by
          Text(
            "زُرعت بواسطة: ${widget.plant.ownerUsername}",
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),

          // Care info header
          const Text(
            "معلومات للعناية بالنبتة:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Description from catalog
          if (description.isNotEmpty)
            Text(
              description,
              style: const TextStyle(fontSize: 16, height: 1.5),
              textAlign: TextAlign.center,
            ),

          const SizedBox(height: 8),

          // Watering interval from catalog
          Text(
            "يُسقى كل $wateringInterval ${wateringInterval == 1 ? 'يوم' : 'أيام'}",
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF0F6A3B),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
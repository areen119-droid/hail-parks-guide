import 'package:flutter/material.dart';
import 'package:hail_parks_guide/models/map_plant_model.dart';
import 'package:hail_parks_guide/core/widgets/smart_image.dart';
import 'plant_info_tab.dart';
import 'watering_log_tab.dart';

class PlantDetailsPage extends StatefulWidget {
  final MapPlant plant;
  const PlantDetailsPage({super.key, required this.plant});
  @override
  State<PlantDetailsPage> createState() => _PlantDetailsPageState();
}

class _PlantDetailsPageState extends State<PlantDetailsPage> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final plant = widget.plant;
    return Scaffold(
      backgroundColor: const Color(0xFFE9E8E1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE9E8E1),
        elevation: 0,
        centerTitle: true,
        title: Text(plant.name),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          // Plant image — supports both base64 and network URL
          Center(
            child: Container(
              width: 260,
              height: 200,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Colors.white,
              ),
              child: plant.imageUrl.isNotEmpty
                  ? SmartImage(
                imageData: plant.imageUrl,
                fit: BoxFit.cover,
                width: 260,
                height: 200,
              )
                  : const Icon(Icons.local_florist, size: 60),
            ),
          ),

          const SizedBox(height: 20),

          // Tab buttons centered
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _tabButton("معلومات النبتة", 0),
              const SizedBox(width: 20),
              _tabButton("جدول الريّ", 1),
            ],
          ),

          const SizedBox(height: 20),

          Expanded(
            child: selectedTab == 0
                ? PlantInfoTab(plant: plant)
                : WateringLogTab(plant: plant),
          ),
        ],
      ),
    );
  }

  Widget _tabButton(String text, int index) {
    final isActive = selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF0F6A3B) : Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(text,
            style: TextStyle(
                color: isActive ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold)),
      ),
    );
  }
}
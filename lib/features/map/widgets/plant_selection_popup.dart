import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:hail_parks_guide/providers/auth_provider.dart' as app;

class PlantOption {
  final String id;
  final String name;
  final String imageUrl;
  final int wateringInterval;
  final String description;
  final List<String> recommendedCities;

  const PlantOption({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.wateringInterval,
    required this.description,
    required this.recommendedCities,
  });
}

class PlantSelectionPopup extends StatelessWidget {
  const PlantSelectionPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<app.AuthProvider>(context, listen: false);
    final userCity = authProvider.currentUser?.city ?? '';

    return Dialog(
      backgroundColor: const Color(0xFFE9E8E1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: SizedBox(
        width: 320,
        height: 480,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                  const Spacer(),
                  if (userCity.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F6A3B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on,
                              size: 14, color: Color(0xFF0F6A3B)),
                          const SizedBox(width: 4),
                          Text(
                            userCity,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF0F6A3B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const Text(
                'اختر نبتة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F6A3B),
                ),
              ),
              if (userCity.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 8),
                  child: Text(
                    'النباتات الموصى بها لمدينتك',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),

              const SizedBox(height: 8),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('plant_catalog')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF0F6A3B)),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('لا يوجد نباتات'));
                    }

                    final allPlants = snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return PlantOption(
                        id: doc.id,
                        name: data['name'] ?? '',
                        imageUrl: data['imageUrl'] ?? '',
                        wateringInterval: data['wateringInterval'] ?? 3,
                        description: data['description'] ?? '',
                        recommendedCities: List<String>.from(
                            data['recommendedCities'] ?? []),
                      );
                    }).toList();

                    final recommended = userCity.isNotEmpty
                        ? allPlants
                        .where((p) =>
                        p.recommendedCities.contains(userCity))
                        .toList()
                        : <PlantOption>[];
                    final others = userCity.isNotEmpty
                        ? allPlants
                        .where((p) =>
                    !p.recommendedCities.contains(userCity))
                        .toList()
                        : allPlants;

                    return ListView(
                      children: [
                        if (recommended.isNotEmpty) ...[
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F6A3B).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.recommend,
                                    size: 16, color: Color(0xFF0F6A3B)),
                                SizedBox(width: 6),
                                Text(
                                  'موصى بها لمدينتك',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F6A3B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: recommended.length,
                            gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 14,
                              childAspectRatio: 0.72,
                            ),
                            itemBuilder: (context, index) {
                              return _PlantCard(
                                  plant: recommended[index],
                                  isRecommended: true);
                            },
                          ),
                          const SizedBox(height: 16),
                        ],

                        if (others.isNotEmpty) ...[
                          if (recommended.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                'نباتات أخرى',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: others.length,
                            gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 14,
                              childAspectRatio: 0.72,
                            ),
                            itemBuilder: (context, index) {
                              return _PlantCard(
                                  plant: others[index],
                                  isRecommended: false);
                            },
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlantCard extends StatelessWidget {
  final PlantOption plant;
  final bool isRecommended;

  const _PlantCard({required this.plant, required this.isRecommended});

  void _showDescriptionPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFFE9E8E1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  plant.imageUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                  const Icon(Icons.local_florist, size: 40),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                plant.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F6A3B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                plant.description.isNotEmpty
                    ? plant.description
                    : 'لا يوجد وصف متاح',
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 10),
              Text(
                'يُسقى كل ${plant.wateringInterval} ${plant.wateringInterval == 1 ? 'يوم' : 'أيام'}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF0F6A3B),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F6A3B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('إغلاق'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: 96,
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.white,
                border: isRecommended
                    ? Border.all(color: const Color(0xFF0F6A3B), width: 2)
                    : null,
              ),
              child: plant.imageUrl.isNotEmpty
                  ? Image.network(
                plant.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.local_florist, size: 40),
                  );
                },
              )
                  : const Center(
                child: Icon(Icons.local_florist, size: 40),
              ),
            ),
            if (isRecommended)
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F6A3B),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'موصى به',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            Positioned(
              top: 4,
              right: 4,
              child: InkWell(
                onTap: () => _showDescriptionPopup(context),
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.info_outline, size: 16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          plant.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 82,
          height: 32,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context, plant);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F6A3B),
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.zero,
            ),
            child: const Text('ازرع'),
          ),
        ),
      ],
    );
  }
}
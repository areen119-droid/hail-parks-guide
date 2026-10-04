import 'package:flutter/material.dart';
import 'package:hail_parks_guide/features/parks/park_detail_screen.dart';
import 'package:hail_parks_guide/data/hail_data.dart';
import 'package:hail_parks_guide/models/park_model.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';

class ParksScreen extends StatefulWidget {
  const ParksScreen({super.key});

  @override
  State<ParksScreen> createState() => _ParksScreenState();
}

class _ParksScreenState extends State<ParksScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(child: _buildParksList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.darkGreen, AppColors.mediumBrown],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            'الحدائق والمتنزهات',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'اكتشف أجمل الأماكن في حائل',
            style: TextStyle(color: AppColors.paleGreen, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: 'ابحث عن حديقة...',
          hintStyle: const TextStyle(color: AppColors.mediumGrey),
          prefixIcon: const Icon(Icons.search, color: AppColors.mediumGrey),
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildParksList() {
    final parks = HailData.parks
        .where((park) =>
            park.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    if (parks.isEmpty) {
      return const Center(
        child: Text('لا توجد حدائق بعد',
            style: TextStyle(color: AppColors.mediumGrey)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: parks.length,
      itemBuilder: (context, index) => _buildParkCard(parks[index]),
    );
  }

  Widget _buildParkCard(ParkModel park) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ParkDetailScreen(park: park),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkBrown.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ClipRRect(
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                park.imageUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 160,
                  width: double.infinity,
                  color: AppColors.lightSand,
                  child: const Icon(Icons.park,
                      size: 60, color: AppColors.mediumGrey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    park.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    park.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.mediumGrey,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        park.location,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.mediumBrown,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.location_on,
                          size: 14, color: AppColors.mediumBrown),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
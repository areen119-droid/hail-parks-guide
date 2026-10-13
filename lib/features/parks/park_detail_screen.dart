import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:hail_parks_guide/app/theme.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';
import 'package:hail_parks_guide/core/widgets/custom_button.dart';
import 'package:hail_parks_guide/core/widgets/smart_image.dart';
import 'package:hail_parks_guide/models/park_model.dart';
import 'package:hail_parks_guide/providers/favorites_provider.dart';
import 'package:hail_parks_guide/providers/navigation_provider.dart';

class ParkDetailScreen extends StatefulWidget {
  final ParkModel park;

  const ParkDetailScreen({super.key, required this.park});

  @override
  State<ParkDetailScreen> createState() => _ParkDetailScreenState();
}

class _ParkDetailScreenState extends State<ParkDetailScreen> {
  static const _tabs = ['نبذة', 'المرافق', 'الموقع'];
  int _tab = 0;

  ParkModel get park => widget.park;

  void _showOnMap() {
    context.read<NavigationProvider>().showParkOnMap(park.id);
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final isFavorite = favorites.isFavoritePark(park.id);

    return Scaffold(
      body: Container(
        decoration: AppDecorations.screenBackground,
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 120),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Row(
                  children: [
                    CircleIconButton(
                      icon: Icons.arrow_back,
                      tooltip: 'رجوع',
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    CircleIconButton(
                      icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                      iconColor: isFavorite ? AppColors.error : AppColors.brown,
                      tooltip: 'المفضلة',
                      onPressed: () => favorites.togglePark(park.id),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(park.name, style: AppText.title),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 16, color: AppColors.accent),
                        const SizedBox(width: 4),
                        Text(park.location, style: AppText.caption),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: SmartImage(
                    imageData: park.image,
                    height: 230,
                    width: double.infinity,
                    placeholderIcon: Icons.park,
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -24),
                child: _buildPanel(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: PrimaryButton(label: 'عرض على الخريطة', onPressed: _showOnMap),
      ),
    );
  }

  Widget _buildPanel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Stat(
                icon: Icons.access_time,
                value: park.openingHours.isEmpty ? '—' : park.openingHours,
                label: 'ساعات العمل',
              ),
              _Stat(
                icon: Icons.local_activity_outlined,
                value: '${park.facilities.length}',
                label: 'المرافق',
              ),
              _Stat(
                icon: Icons.location_city,
                value: park.location,
                label: 'المدينة',
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildTabs(),
          const SizedBox(height: 14),
          _buildTabContent(),
          if (park.gallery.isNotEmpty) ...[
            const SizedBox(height: 20),
            const SectionHeader(title: 'الصور'),
            const SizedBox(height: 10),
            SizedBox(
              height: 86,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: park.gallery.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) => ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SmartImage(
                    imageData: park.gallery[index],
                    width: 100,
                    height: 86,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < _tabs.length; i++)
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _tab = i),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: _tab == i ? AppColors.brown : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    _tabs[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: _tab == i ? FontWeight.w700 : FontWeight.w500,
                      color: _tab == i
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_tab) {
      case 1:
        if (park.facilities.isEmpty) {
          return const Text('لم تُضف مرافق بعد', style: AppText.caption);
        }
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final facility in park.facilities)
              Chip(
                avatar: const Icon(Icons.check_circle,
                    size: 18, color: AppColors.plantGreen),
                label: Text(facility),
                backgroundColor: AppColors.sandLight,
                side: BorderSide.none,
                shape: const StadiumBorder(),
              ),
          ],
        );
      case 2:
        return _buildLocationMap();
      default:
        return Text(park.description, style: AppText.body);
    }
  }

  Widget _buildLocationMap() {
    final point = LatLng(park.latitude, park.longitude);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 180,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: point,
            initialZoom: 15,
            interactionOptions:
                const InteractionOptions(flags: InteractiveFlag.none),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.hailparksguide.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: point,
                  width: 44,
                  height: 44,
                  alignment: Alignment.topCenter,
                  child: const Icon(Icons.location_on,
                      size: 44, color: AppColors.brown),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _Stat({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.accent, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

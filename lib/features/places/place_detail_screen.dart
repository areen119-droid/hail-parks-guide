import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:hail_parks_guide/app/theme.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';
import 'package:hail_parks_guide/core/utils/helpers.dart';
import 'package:hail_parks_guide/core/widgets/custom_button.dart';
import 'package:hail_parks_guide/features/places/food_card.dart';
import 'package:hail_parks_guide/features/places/place_image.dart';
import 'package:hail_parks_guide/models/place_model.dart';
import 'package:hail_parks_guide/providers/favorites_provider.dart';
import 'package:hail_parks_guide/providers/navigation_provider.dart';

class PlaceDetailScreen extends StatefulWidget {
  final PlaceModel place;

  const PlaceDetailScreen({super.key, required this.place});

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  int _tab = 0;

  PlaceModel get place => widget.place;

  /// Tabs shown for this place: facilities and location only when known.
  List<String> get _tabs => [
        'نبذة',
        if (place.facilities.isNotEmpty) 'المرافق',
        if (place.hasLocation) 'الموقع',
      ];

  void _askGuide() {
    context.read<NavigationProvider>().openGuide(
        question: 'أخبرني عن ${place.name}: ما الذي يميزه، وما أفضل وقت لزيارته، وبماذا تنصحني؟');
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  void _showOnMap() {
    context.read<NavigationProvider>().showPlaceOnMap(place.id);
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final isFavorite = favorites.isFavoritePlace(place.id);

    return Scaffold(
      body: Container(
        decoration: AppDecorations.screenBackground,
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: EdgeInsets.only(bottom: place.hasLocation ? 120 : 32),
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
                      iconColor: isFavorite ? AppColors.error : AppColors.primary,
                      tooltip: 'المفضلة',
                      onPressed: () => favorites.togglePlace(place.id),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(place.name, style: AppText.title),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 16, color: AppColors.accent),
                        const SizedBox(width: 4),
                        Text(place.location, style: AppText.caption),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: PlaceImage(
                    place: place,
                    height: 230,
                    width: double.infinity,
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
      bottomNavigationBar: place.hasLocation
          ? SafeArea(
              minimum: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: PrimaryButton(
                  label: 'عرض على الخريطة', onPressed: _showOnMap),
            )
          : null,
    );
  }

  Widget _buildPanel() {
    final distance = distanceFromHailLabel(place);
    final nearby = nearbyFood(place);
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
                icon: place.category.icon,
                value: place.category.label,
                label: 'التصنيف',
              ),
              _Stat(
                icon: Icons.near_me_outlined,
                value: distance ?? '—',
                label: 'المسافة من حائل',
              ),
              _Stat(
                icon: Icons.access_time,
                value: place.openingHours.isEmpty ? '—' : place.openingHours,
                label: 'ساعات العمل',
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (_tabs.length > 1) ...[
            _buildTabs(),
            const SizedBox(height: 14),
          ],
          _buildTabContent(),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: _askGuide,
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: const Text('اسأل المرشد عن هذا المكان'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.chip),
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
          ),
          if (!place.category.isFood && nearby.isNotEmpty) ...[
            const SizedBox(height: 20),
            const SectionHeader(title: 'مطاعم ومقاهي قريبة'),
            const SizedBox(height: 10),
            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: nearby.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) => FoodCard(
                  place: nearby[index].$1,
                  caption: 'على بعد ${formatKm(nearby[index].$2)}',
                ),
              ),
            ),
          ],
          if (place.gallery.isNotEmpty) ...[
            const SizedBox(height: 20),
            const SectionHeader(title: 'الصور'),
            const SizedBox(height: 10),
            SizedBox(
              height: 86,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: place.gallery.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) => ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: PlaceImage(
                    place: place,
                    image: place.gallery[index],
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
    final tabs = _tabs;
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++)
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _tab = i),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: _tab == i ? AppColors.primary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    tabs[i],
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
    switch (_tabs[_tab]) {
      case 'المرافق':
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final facility in place.facilities)
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
      case 'الموقع':
        return _buildLocationMap();
      default:
        return Text(place.description, style: AppText.body);
    }
  }

  Widget _buildLocationMap() {
    final point = LatLng(place.latitude!, place.longitude!);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 180,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: point,
            initialZoom: place.category == PlaceCategory.nature ? 10 : 15,
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
                      size: 44, color: AppColors.primary),
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
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

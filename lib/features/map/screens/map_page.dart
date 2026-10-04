import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';
import 'package:hail_parks_guide/data/hail_data.dart';
import 'package:hail_parks_guide/features/map/widgets/map_top_overlay.dart';
import 'package:hail_parks_guide/features/map/widgets/park_quick_info_card.dart';
import 'package:hail_parks_guide/models/park_model.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const _hailCenter =
      LatLng(HailData.hailLatitude, HailData.hailLongitude);

  final MapController _mapController = MapController();
  final Location _location = Location();

  ParkModel? _selectedPark;
  LatLng? _userPosition;

  void _selectPark(ParkModel park) {
    setState(() => _selectedPark = park);
    _mapController.move(LatLng(park.latitude, park.longitude), 15);
  }

  Future<void> _goToMyLocation() async {
    try {
      if (!await _location.serviceEnabled() &&
          !await _location.requestService()) {
        return;
      }
      var permission = await _location.hasPermission();
      if (permission == PermissionStatus.denied) {
        permission = await _location.requestPermission();
      }
      if (permission != PermissionStatus.granted &&
          permission != PermissionStatus.grantedLimited) {
        _showMessage('يرجى السماح بالوصول إلى الموقع');
        return;
      }

      final data = await _location.getLocation();
      if (data.latitude == null || data.longitude == null) return;
      final position = LatLng(data.latitude!, data.longitude!);
      setState(() => _userPosition = position);
      _mapController.move(position, 15);
    } catch (e) {
      _showMessage('تعذر تحديد موقعك');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _hailCenter,
              initialZoom: 13,
              onTap: (_, __) => setState(() => _selectedPark = null),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.hailparksguide.app',
              ),
              MarkerLayer(
                markers: [
                  for (final park in HailData.parks) _buildParkMarker(park),
                  if (_userPosition != null)
                    Marker(
                      point: _userPosition!,
                      width: 22,
                      height: 22,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.brightBlue,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.white, width: 3),
                        ),
                      ),
                    ),
                ],
              ),
              const RichAttributionWidget(
                alignment: AttributionAlignment.bottomLeft,
                attributions: [
                  TextSourceAttribution('OpenStreetMap contributors'),
                ],
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: MapTopOverlay(
              parks: HailData.parks,
              selectedParkId: _selectedPark?.id,
              onParkSelected: _selectPark,
            ),
          ),
          Positioned(
            right: 16,
            bottom: _selectedPark == null ? 24 : 250,
            child: FloatingActionButton(
              heroTag: 'my_location',
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.darkGreen,
              onPressed: _goToMyLocation,
              child: const Icon(Icons.my_location),
            ),
          ),
          if (_selectedPark != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ParkQuickInfoCard(
                park: _selectedPark!,
                onClose: () => setState(() => _selectedPark = null),
              ),
            ),
        ],
      ),
    );
  }

  Marker _buildParkMarker(ParkModel park) {
    final selected = park.id == _selectedPark?.id;
    return Marker(
      point: LatLng(park.latitude, park.longitude),
      width: 48,
      height: 48,
      alignment: Alignment.topCenter,
      child: GestureDetector(
        onTap: () => _selectPark(park),
        child: Icon(
          Icons.location_on,
          size: selected ? 48 : 40,
          color: selected ? AppColors.mediumBrown : AppColors.darkGreen,
        ),
      ),
    );
  }
}

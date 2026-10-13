import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';
import 'package:hail_parks_guide/core/widgets/custom_button.dart';
import 'package:hail_parks_guide/data/hail_data.dart';
import 'package:hail_parks_guide/features/map/widgets/map_top_overlay.dart';
import 'package:hail_parks_guide/features/map/widgets/place_quick_info_card.dart';
import 'package:hail_parks_guide/features/navigation/bottom_nav_bar.dart';
import 'package:hail_parks_guide/models/place_model.dart';
import 'package:hail_parks_guide/providers/navigation_provider.dart';

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

  PlaceCategory? _category;
  PlaceModel? _selectedPlace;
  LatLng? _userPosition;

  /// Places that have coordinates and match the category filter.
  List<PlaceModel> get _visiblePlaces => HailData.places
      .where((p) => p.hasLocation && (_category == null || p.category == _category))
      .toList();

  LatLng _pointOf(PlaceModel place) => LatLng(place.latitude!, place.longitude!);

  void _selectPlace(PlaceModel place) {
    setState(() => _selectedPlace = place);
    // Zoom out further for large natural areas.
    final zoom = place.category == PlaceCategory.nature ? 11.0 : 15.0;
    _mapController.move(_pointOf(place), zoom);
  }

  void _selectCategory(PlaceCategory? category) {
    setState(() {
      _category = category;
      _selectedPlace = null;
    });
    final points = _visiblePlaces.map(_pointOf).toList();
    if (points.length > 1) {
      _mapController.fitCamera(CameraFit.coordinates(
        coordinates: points,
        padding: const EdgeInsets.fromLTRB(48, 200, 48, kNavBarSpace + 40),
      ));
    } else if (points.length == 1) {
      _mapController.move(points.first, 13);
    }
  }

  /// Focuses a place when another screen asked to "show on map".
  void _handleFocusRequest(NavigationProvider nav) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final id = nav.takePlaceToShowOnMap();
      if (id == null) return;
      final place = HailData.places.where((p) => p.id == id).firstOrNull;
      if (place == null || !place.hasLocation) return;
      setState(() => _category = null);
      _selectPlace(place);
    });
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
    _handleFocusRequest(context.watch<NavigationProvider>());

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _hailCenter,
            initialZoom: 12,
            onTap: (_, __) => setState(() => _selectedPlace = null),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.hailparksguide.app',
            ),
            MarkerLayer(
              markers: [
                for (final place in _visiblePlaces) _buildMarker(place),
                if (_userPosition != null)
                  Marker(
                    point: _userPosition!,
                    width: 22,
                    height: 22,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.location,
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
            category: _category,
            onCategoryChanged: _selectCategory,
          ),
        ),
        PositionedDirectional(
          end: 16,
          bottom: _selectedPlace == null ? kNavBarSpace : kNavBarSpace + 130,
          child: CircleIconButton(
            icon: Icons.my_location,
            size: 52,
            tooltip: 'موقعي',
            onPressed: _goToMyLocation,
          ),
        ),
        if (_selectedPlace != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: kNavBarSpace - 16,
            child: PlaceQuickInfoCard(
              place: _selectedPlace!,
              onClose: () => setState(() => _selectedPlace = null),
            ),
          ),
      ],
    );
  }

  /// Round pin with the category icon; the selected place is larger.
  Marker _buildMarker(PlaceModel place) {
    final selected = place.id == _selectedPlace?.id;
    final size = selected ? 52.0 : 42.0;
    return Marker(
      point: _pointOf(place),
      width: size,
      height: size,
      child: GestureDetector(
        onTap: () => _selectPlace(place),
        child: Container(
          decoration: BoxDecoration(
            color: selected ? AppColors.accent : AppColors.brown,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.cream, width: 3),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 6),
            ],
          ),
          child: Icon(place.category.icon,
              size: size * 0.5, color: AppColors.white),
        ),
      ),
    );
  }
}

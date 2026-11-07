import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:hail_parks_guide/core/utils/helpers.dart';
import 'package:hail_parks_guide/data/hail_data.dart';
import 'package:hail_parks_guide/journal/journal_place.dart';
import 'package:hail_parks_guide/journal/journal_theme.dart';
import 'package:hail_parks_guide/journal/journal_widgets.dart';
import 'package:hail_parks_guide/models/place_model.dart';
import 'package:hail_parks_guide/providers/navigation_provider.dart';

/// The map in the journal design: diamond pins in each kind's color, text
/// tabs to filter, and a flat panel for the selected place.
class JournalMap extends StatefulWidget {
  const JournalMap({super.key});

  @override
  State<JournalMap> createState() => _JournalMapState();
}

class _JournalMapState extends State<JournalMap> {
  static const _hailCenter = LatLng(HailData.hailLatitude, HailData.hailLongitude);

  final _mapController = MapController();
  final _location = Location();

  PlaceCategory? _category;
  PlaceModel? _selected;
  LatLng? _user;

  List<PlaceModel> get _visible => HailData.places
      .where((p) => p.hasLocation && (_category == null || p.category == _category))
      .toList();

  LatLng _point(PlaceModel p) => LatLng(p.latitude!, p.longitude!);

  void _select(PlaceModel place) {
    setState(() => _selected = place);
    _mapController.move(_point(place), place.category == PlaceCategory.nature ? 11 : 15);
  }

  void _filter(PlaceCategory? category) {
    setState(() {
      _category = category;
      _selected = null;
    });
    final points = _visible.map(_point).toList();
    if (points.length > 1) {
      _mapController.fitCamera(CameraFit.coordinates(
        coordinates: points,
        padding: const EdgeInsets.fromLTRB(40, 150, 40, 60),
      ));
    } else if (points.length == 1) {
      _mapController.move(points.first, 13);
    }
  }

  void _handleFocusRequest(NavigationProvider nav) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final id = nav.takePlaceToShowOnMap();
      if (id == null) return;
      final place = HailData.places.where((p) => p.id == id).firstOrNull;
      if (place == null || !place.hasLocation) return;
      setState(() => _category = null);
      _select(place);
    });
  }

  Future<void> _myLocation() async {
    try {
      if (!await _location.serviceEnabled() && !await _location.requestService()) return;
      var permission = await _location.hasPermission();
      if (permission == PermissionStatus.denied) {
        permission = await _location.requestPermission();
      }
      if (permission != PermissionStatus.granted &&
          permission != PermissionStatus.grantedLimited) {
        _message('يرجى السماح بالوصول إلى الموقع');
        return;
      }
      final data = await _location.getLocation();
      if (data.latitude == null || data.longitude == null) return;
      final position = LatLng(data.latitude!, data.longitude!);
      setState(() => _user = position);
      _mapController.move(position, 15);
    } catch (_) {
      _message('تعذر تحديد موقعك');
    }
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    _handleFocusRequest(context.watch<NavigationProvider>());

    return Column(
      children: [
        Container(
          color: J.paper,
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(J.gutter, 12, J.gutter, 0),
                  child: Row(
                    children: [
                      Text('الخريطة', style: J.title),
                      const Spacer(),
                      Text(J.digits('${_visible.length} مكانًا'), style: J.meta),
                    ],
                  ),
                ),
                JTabs<PlaceCategory?>(
                  tabs: [(null, 'الكل'), for (final c in PlaceCategory.values) (c, c.label)],
                  selected: _category,
                  onSelected: _filter,
                ),
                const JRule(color: J.ink),
              ],
            ),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _hailCenter,
                  initialZoom: 12,
                  onTap: (_, _) => setState(() => _selected = null),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.hailparksguide.app',
                  ),
                  MarkerLayer(markers: [
                    for (final place in _visible) _pin(place),
                    if (_user != null)
                      Marker(
                        point: _user!,
                        width: 20,
                        height: 20,
                        child: Container(
                          decoration: BoxDecoration(
                            color: J.ink,
                            border: Border.all(color: J.paper, width: 3),
                          ),
                        ),
                      ),
                  ]),
                  const RichAttributionWidget(
                    alignment: AttributionAlignment.bottomLeft,
                    attributions: [TextSourceAttribution('OpenStreetMap contributors')],
                  ),
                ],
              ),
              PositionedDirectional(
                end: 14,
                top: 14,
                child: JSquareButton(
                  icon: Icons.my_location,
                  tooltip: 'موقعي',
                  filled: true,
                  onPressed: _myLocation,
                ),
              ),
              if (_selected != null)
                Positioned(left: 0, right: 0, bottom: 0, child: _panel(_selected!)),
            ],
          ),
        ),
      ],
    );
  }

  /// A diamond in the place's color; the selected one is larger and shows
  /// its name.
  Marker _pin(PlaceModel place) {
    final selected = place.id == _selected?.id;
    final side = selected ? 22.0 : 16.0;
    return Marker(
      point: _point(place),
      width: 44,
      height: 44,
      child: GestureDetector(
        onTap: () => _select(place),
        child: Center(
          child: Transform.rotate(
            angle: math.pi / 4,
            child: Container(
              width: side,
              height: side,
              decoration: BoxDecoration(
                color: selected ? J.ink : J.category(place.category),
                border: Border.all(color: J.paper, width: 2.5),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _panel(PlaceModel place) {
    final distance = distanceFromHailLabel(place);
    return Container(
      color: J.paper,
      padding: const EdgeInsets.fromLTRB(J.gutter, 0, J.gutter, 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 3, color: J.category(place.category)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              JPhoto(place: place, width: 72, height: 72),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(place.category.label, style: J.label),
                    Text(place.name, style: J.heading),
                    if (distance != null) Text(distance, style: J.meta),
                  ],
                ),
              ),
              JSquareButton(
                icon: Icons.close,
                tooltip: 'إغلاق',
                size: 36,
                onPressed: () => setState(() => _selected = null),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(46)),
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => JournalPlace(place: place))),
              child: const Text('صفحة المكان'),
            ),
          ),
        ],
      ),
    );
  }
}

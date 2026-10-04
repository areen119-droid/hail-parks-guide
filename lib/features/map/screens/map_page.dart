import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:hail_parks_guide/features/navigation/bottom_nav_bar.dart';
import 'package:hail_parks_guide/features/map/widgets/plant_confirm_popup.dart';
import 'package:hail_parks_guide/features/map/widgets/plant_quick_info_popup.dart';
import 'package:hail_parks_guide/features/map/widgets/plant_selection_popup.dart';
import 'package:hail_parks_guide/models/map_plant_model.dart';
import 'package:hail_parks_guide/models/plant_spot_model.dart';
import 'package:hail_parks_guide/providers/auth_provider.dart' as app;
import 'package:hail_parks_guide/features/map/widgets/map_top_overlay.dart';
import 'package:hail_parks_guide/features/map/widgets/too_far_popup.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Location _locationController = Location();
  final Completer<GoogleMapController> _mapController = Completer();
  final ImagePicker _picker = ImagePicker();

  static const LatLng _defaultLocation = LatLng(27.5219, 41.6907);

  LatLng? _currentP;
  bool _initialCameraMoved = false;

  BitmapDescriptor? _userAvatarIcon;
  BitmapDescriptor? _potIcon;
  BitmapDescriptor? _plantIcon;
  BitmapDescriptor? _plantNeedsWaterIcon;

  List<MapPlant> _mapPlants = [];
  List<PlantSpot> _plantSpots = [];

  StreamSubscription<QuerySnapshot>? _plantsSubscription;
  StreamSubscription<QuerySnapshot>? _spotsSubscription;

  @override
  void initState() {
    super.initState();
    _loadCustomMarkers();
    _getLocationUpdates();
    _listenToMapPlants();
    _listenToPlantSpots();
  }

  @override
  void dispose() {
    _plantsSubscription?.cancel();
    _spotsSubscription?.cancel();
    super.dispose();
  }

  void _listenToMapPlants() {
    _plantsSubscription = FirebaseFirestore.instance
        .collection('map_plants')
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          _mapPlants = snapshot.docs
              .map((doc) => MapPlant.fromFirestore(doc))
              .toList();
        });
      }
    });
  }

  void _listenToPlantSpots() {
    _spotsSubscription = FirebaseFirestore.instance
        .collection('plant_spots')
        .where('isPlanted', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          _plantSpots = snapshot.docs
              .map((doc) => PlantSpot.fromFirestore(doc))
              .toList();
        });
      }
    });
  }

  Future<void> _loadCustomMarkers() async {
    _potIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(80, 80)),
      'lib/features/map/assets/pot_marker.png',
    );
    _plantIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(80, 80)),
      'lib/features/map/assets/plant_marker.png',
    );
    _plantNeedsWaterIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(80, 80)),
      'lib/features/map/assets/plantNeedWater.png',
    );

    _userAvatarIcon = await _buildBlueCircleMarker();

    if (mounted) setState(() {});
  }

  Future<BitmapDescriptor> _buildBlueCircleMarker() async {
    const int size = 40;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..isAntiAlias = true;

    // ظل خارجي فاتح
    paint.color = const Color(0x304CAF50);
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2, paint);

    // الدائرة الزرقاء
    paint.color = const Color(0xFF235347);
    canvas.drawCircle(const Offset(size / 2, size / 2), 14, paint);

    // الحد الأبيض
    paint.color = Colors.white;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;
    canvas.drawCircle(const Offset(size / 2, size / 2), 14, paint);

    final img = await recorder.endRecording().toImage(size, size);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
  }

  Future<void> _updateStreak(String userId) async {
    if (userId.isEmpty) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final userDoc = await userRef.get();
    final data = userDoc.data();

    final createdAt = data?['createdAt'] != null
        ? (data!['createdAt'] as Timestamp).toDate()
        : DateTime.now();

    final now = DateTime.now();
    final daysSinceCreation = now.difference(createdAt).inDays;
    int streak = (daysSinceCreation ~/ 14) + 1;

    await userRef.update({
      'streak': streak,
      'lastActive': FieldValue.serverTimestamp(),
    });
  }

  Set<Marker> _buildMarkers() {
    final Set<Marker> markers = {};

    if (_currentP != null) {
      markers.add(Marker(
        markerId: const MarkerId('current_location'),
        position: _currentP!,
        icon: _userAvatarIcon ?? BitmapDescriptor.defaultMarker,
      ));
    }

    for (final spot in _plantSpots) {
      markers.add(Marker(
        markerId: MarkerId('spot_${spot.id}'),
        position: LatLng(spot.latitude, spot.longitude),
        icon: _potIcon ?? BitmapDescriptor.defaultMarker,
        infoWindow: const InfoWindow(
          title: 'Pot',
          snippet: 'اضغط للزراعة هنا',
        ),
        onTap: () => _handlePotTap(spot),
      ));
    }

    for (final plant in _mapPlants) {
      final needsWater = plant.needsWater();
      markers.add(Marker(
        markerId: MarkerId('plant_${plant.id}'),
        position: LatLng(plant.latitude, plant.longitude),
        icon: needsWater
            ? (_plantNeedsWaterIcon ?? _plantIcon ?? BitmapDescriptor.defaultMarker)
            : (_plantIcon ?? BitmapDescriptor.defaultMarker),
        infoWindow: InfoWindow(
          title: plant.name,
          snippet: needsWater ? 'This plant needs water' : 'اضغط لعرض معلومات النبتة',
        ),
        onTap: () => _handlePlantTap(plant),
      ));
    }

    return markers;
  }

  double _distanceInMeters(LatLng a, LatLng b) {
    const earthRadius = 6371000.0;
    final dLat = (b.latitude - a.latitude) * pi / 180;
    final dLon = (b.longitude - a.longitude) * pi / 180;
    final sinDLat = sin(dLat / 2);
    final sinDLon = sin(dLon / 2);
    final h = sinDLat * sinDLat +
        cos(a.latitude * pi / 180) *
            cos(b.latitude * pi / 180) *
            sinDLon * sinDLon;
    return 2 * earthRadius * asin(sqrt(h));
  }

  Future<void> _showTooFarPopup(double distance) async {
    await showDialog(
      context: context,
      builder: (_) => TooFarPopup(distanceMeters: distance),
    );
  }

  Future<void> _handlePotTap(PlantSpot spot) async {
    if (_currentP == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('جارٍ تحديد موقعك، حاول مجدداً')),
      );
      return;
    }

    final distance = _distanceInMeters(_currentP!, LatLng(spot.latitude, spot.longitude));
    if (distance > 50) {
      if (!mounted) return;
      await _showTooFarPopup(distance);
      return;
    }

    final selectedPlant = await showDialog<PlantOption>(
      context: context,
      builder: (_) => const PlantSelectionPopup(),
    );

    if (selectedPlant == null || !mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PlantConfirmPopup(
        selectedPlant: selectedPlant,
        latitude: spot.latitude,
        longitude: spot.longitude,
        spotId: spot.id,
      ),
    );
  }

  Future<void> _handlePlantTap(MapPlant plant) async {
    await showDialog(
      context: context,
      builder: (_) => PlantQuickInfoPopup(
        plant: plant,
        onWaterTap: () async {
          Navigator.pop(context);

          if (_currentP == null) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('جارٍ تحديد موقعك، حاول مجدداً')),
            );
            return;
          }

          final waterDistance = _distanceInMeters(_currentP!, LatLng(plant.latitude, plant.longitude));
          if (waterDistance > 50) {
            if (!mounted) return;
            await _showTooFarPopup(waterDistance);
            return;
          }

          final XFile? file = await _picker.pickImage(
            source: ImageSource.camera,
            imageQuality: 40,
            maxWidth: 800,
            maxHeight: 800,
          );
          if (file == null || !mounted) return;

          final firebaseUser = FirebaseAuth.instance.currentUser;
          final userId = firebaseUser?.uid ?? '';

          // Always fetch fresh from Firestore to avoid stale cached user
          String username = 'User';
          if (userId.isNotEmpty) {
            final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
            username = userDoc.data()?['username'] ?? userDoc.data()?['name'] ?? 'User';
          }

          final bytes = await File(file.path).readAsBytes();
          final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';

          final wateredAt = Timestamp.now();

          await FirebaseFirestore.instance
              .collection('map_plants')
              .doc(plant.id)
              .update({
            'lastWatered': wateredAt,
            'waterCount': FieldValue.increment(1),
          });

          await FirebaseFirestore.instance
              .collection('map_plants')
              .doc(plant.id)
              .collection('watering_logs')
              .add({
            'userId': userId,
            'username': username,
            'mediaUrl': base64Image,
            'timestamp': wateredAt,
          });

          await FirebaseFirestore.instance.collection('user_posts').add({
            'userId': userId,
            'username': username,
            'action': 'watered',
            'mediaUrl': base64Image,
            'mediaType': 'image',
            'plantName': plant.name,
            'mapPlantId': plant.id,
            'timestamp': Timestamp.now(),
          });

          await FirebaseFirestore.instance.collection('users').doc(userId).update({
            'points': FieldValue.increment(20),
          });

          await _updateStreak(userId);

          if (!mounted) return;

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainNavigation(initialIndex: 4)),
            (route) => false,
          );
        },
      ),
    );
  }

  Future<void> _getLocationUpdates() async {
    bool serviceEnabled = await _locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await _locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    await _locationController.changeSettings(
      accuracy: LocationAccuracy.high,
    );

    _locationController.onLocationChanged.listen((LocationData currentLocation) async {
      if (currentLocation.latitude != null && currentLocation.longitude != null) {
        final newPosition = LatLng(
          currentLocation.latitude!,
          currentLocation.longitude!,
        );

        if (mounted) {
          setState(() => _currentP = newPosition);
        }

        if (!_initialCameraMoved && _mapController.isCompleted) {
          _initialCameraMoved = true;
          final controller = await _mapController.future;
          controller.animateCamera(CameraUpdate.newLatLng(newPosition));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _defaultLocation,
              zoom: 15,
            ),
            onMapCreated: (controller) {
              if (!_mapController.isCompleted) {
                _mapController.complete(controller);
              }
            },
            markers: _buildMarkers(),
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
          const MapTopOverlay(),
        ],
      ),
    );
  }
}
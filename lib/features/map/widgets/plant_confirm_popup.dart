import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:hail_parks_guide/features/map/widgets/plant_selection_popup.dart';
import 'package:hail_parks_guide/features/navigation/bottom_nav_bar.dart';
import 'package:hail_parks_guide/providers/auth_provider.dart' as app;

class PlantConfirmationResult {
  final String plantCustomName;
  final String imagePath;
  PlantConfirmationResult({required this.plantCustomName, required this.imagePath});
}

class PlantConfirmPopup extends StatefulWidget {
  final PlantOption selectedPlant;
  final double latitude;
  final double longitude;
  final String spotId;

  const PlantConfirmPopup({
    super.key,
    required this.selectedPlant,
    required this.latitude,
    required this.longitude,
    required this.spotId,
  });

  @override
  State<PlantConfirmPopup> createState() => _PlantConfirmPopupState();
}

class _PlantConfirmPopupState extends State<PlantConfirmPopup> {
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? _capturedImagePath;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
    await userRef.update({'streak': streak, 'lastActive': FieldValue.serverTimestamp()});
  }

  Future<void> _openCamera() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 40,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (file == null) return;
    setState(() => _capturedImagePath = file.path);
  }

  Future<void> _confirm() async {
    if (_capturedImagePath == null) return;
    setState(() => _isLoading = true);

    try {
      final bytes = await File(_capturedImagePath!).readAsBytes();
      final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      final plantName = _nameController.text.trim().isEmpty
          ? widget.selectedPlant.name
          : _nameController.text.trim();
      final firebaseUser = FirebaseAuth.instance.currentUser;
      final userId = firebaseUser?.uid ?? '';
      final authProvider = Provider.of<app.AuthProvider>(context, listen: false);
      final ownerUsername = authProvider.currentUser?.username ??
          authProvider.currentUser?.name ??
          firebaseUser?.phoneNumber ??
          'User';
      final now = Timestamp.now();

      final docRef = await FirebaseFirestore.instance.collection('map_plants').add({
        'name': plantName,
        'catalogPlantName': widget.selectedPlant.name,
        'imageUrl': base64Image,
        'latitude': widget.latitude,
        'longitude': widget.longitude,
        'ownerUsername': ownerUsername,
        'userId': userId,
        'plantedDate': now,
        'waterCount': 0,
        'lastWatered': now,
        'catalogPlantId': widget.selectedPlant.id,
        'wateringInterval': widget.selectedPlant.wateringInterval,
      });

      await FirebaseFirestore.instance
          .collection('plant_spots')
          .doc(widget.spotId)
          .update({'isPlanted': true});

      await FirebaseFirestore.instance.collection('user_posts').add({
        'userId': userId,
        'username': ownerUsername,
        'action': 'planted',
        'mediaUrl': base64Image,
        'mediaType': 'image',
        'plantName': plantName,
        'catalogPlantName': widget.selectedPlant.name,
        'mapPlantId': docRef.id,
        'timestamp': now,
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'points': FieldValue.increment(50)});

      await _updateStreak(userId);

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavigation(initialIndex: 4)),
        (route) => false,
      );
    } catch (e) {
      debugPrint('Error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFE9E8E1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: SizedBox(
        width: 330,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          child: _isLoading
              ? const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator(color: Color(0xFF0F6A3B))),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Camera area
                    GestureDetector(
                      onTap: _openCamera,
                      child: Container(
                        width: double.infinity,
                        height: 170,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFF3E8B57), width: 2),
                        ),
                        child: _capturedImagePath == null
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.photo_camera_outlined, size: 50, color: Color(0xFF3E8B57)),
                                  SizedBox(height: 10),
                                  Text('لنرَ زرعتك!', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3E8B57))),
                                  SizedBox(height: 6),
                                  Text('التقط صورة للمتابعة', style: TextStyle(color: Color(0xFF3E8B57))),
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.file(File(_capturedImagePath!),
                                    width: double.infinity, height: 170, fit: BoxFit.cover),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Name field
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'أضف اسم لزرعتك',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF3E8B57), fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: widget.selectedPlant.name,
                        filled: true,
                        fillColor: const Color(0xFFD1D9C7),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'تذكير: لا تنسَ سقي زرعتك بعد غرسها.',
                        style: TextStyle(color: Color(0xFF3E8B57), fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F6A3B),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                            ),
                            child: const Text('إلغاء'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _capturedImagePath == null ? _openCamera : _confirm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F6A3B),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                            ),
                            child: Text(_capturedImagePath == null ? 'تصوير' : 'تأكيد'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

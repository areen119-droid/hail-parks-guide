import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';
import 'package:hail_parks_guide/features/navigation/bottom_nav_bar.dart';
class MapTopOverlay extends StatelessWidget {
  const MapTopOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final width = MediaQuery.of(context).size.width;

    final barHeight = width < 380 ? 68.0 : 74.0;
    final avatarSize = width < 380 ? 42.0 : 48.0;

    return SafeArea(
      bottom: false,
      child: Container(
        width: double.infinity,
        height: barHeight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.baseLightGreenColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          borderRadius: BorderRadius.zero,
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black,
                size: 26,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MainNavigation(initialIndex: 0),
                  ),
                );
              },
            ),
            const Spacer(),
            _ProfileAvatar(
              currentUser: currentUser,
              size: avatarSize,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final User? currentUser;
  final double size;

  const _ProfileAvatar({
    required this.currentUser,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return _buildAvatar(context, '');
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        String imageUrl = '';

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          imageUrl = (data['profileImageUrl'] ?? '').toString();
        }

        return _buildAvatar(context, imageUrl);
      },
    );
  }

  Widget _buildAvatar(BuildContext context, String imageUrl) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const MainNavigation(initialIndex: 4),
          ),
        );
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFF6DED6),
          border: Border.all(
            color: AppColors.darkGreen.withOpacity(0.9),
            width: 2,
          ),
        ),
        child: ClipOval(
          child: imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _fallbackIcon(),
                )
              : _fallbackIcon(),
        ),
      ),
    );
  }

  Widget _fallbackIcon() {
    return const Center(
      child: Icon(
        Icons.person,
        color: Colors.grey,
        size: 24,
      ),
    );
  }
}
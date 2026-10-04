import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';
import 'package:hail_parks_guide/providers/auth_provider.dart' as app;
import 'package:hail_parks_guide/providers/user_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider =
    Provider.of<app.AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(user?.name ?? 'المستخدم', user?.city ?? ''),
              const SizedBox(height: 20),
              _buildStatsRow(),
              const SizedBox(height: 24),
              _buildSection('الأماكن المفضلة', Icons.favorite,
                  AppColors.darkBrown),
              const SizedBox(height: 16),
              _buildSection('الأماكن التي زرتها', Icons.place,
                  AppColors.darkGreen),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String name, String city) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.darkBrown, AppColors.darkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 45,
            backgroundColor: AppColors.lightSand,
            child: Icon(Icons.person, size: 50, color: AppColors.mediumBrown),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (city.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  city,
                  style: const TextStyle(
                      color: AppColors.paleGreen, fontSize: 13),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.location_on,
                    size: 14, color: AppColors.paleGreen),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildStatItem('0', 'أماكن زرتها', AppColors.darkGreen),
          _buildDivider(),
          _buildStatItem('0', 'المفضلة', AppColors.darkBrown),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.mediumGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: AppColors.lightGrey,
    );
  }

  Widget _buildSection(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Text(
              'لا يوجد عناصر بعد',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.mediumGrey, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
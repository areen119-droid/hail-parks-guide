import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';
import 'package:hail_parks_guide/features/settings/screens/about_us_screen.dart';
import 'package:hail_parks_guide/providers/favorites_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        title: const Text(
          'الإعدادات',
          style: TextStyle(
            color: AppColors.darkText,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.creamBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkText),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildTile(
            icon: Icons.info_outline,
            title: 'عن التطبيق',
            color: AppColors.darkGreen,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutUsScreen()),
            ),
          ),
          _buildTile(
            icon: Icons.heart_broken_outlined,
            title: 'مسح المفضلة',
            color: AppColors.errorRed,
            onTap: () => _showClearFavoritesDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title,
            style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.mediumGrey),
        onTap: onTap,
      ),
    );
  }

  void _showClearFavoritesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('مسح المفضلة'),
        content: const Text('هل تريد إزالة جميع الحدائق والنباتات من المفضلة؟'),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء',
                style: TextStyle(color: AppColors.mediumGrey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<FavoritesProvider>().clearAll();
            },
            child: const Text('مسح',
                style: TextStyle(color: AppColors.errorRed)),
          ),
        ],
      ),
    );
  }
}

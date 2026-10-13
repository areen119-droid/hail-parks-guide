import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hail_parks_guide/app/theme.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';
import 'package:hail_parks_guide/core/widgets/confirmation_dialog.dart';
import 'package:hail_parks_guide/core/widgets/custom_button.dart';
import 'package:hail_parks_guide/features/settings/screens/about_us_screen.dart';
import 'package:hail_parks_guide/providers/favorites_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _clearFavorites(BuildContext context) async {
    final favorites = context.read<FavoritesProvider>();
    final confirmed = await showConfirmationDialog(
      context,
      title: 'مسح المفضلة',
      message: 'هل تريد إزالة جميع الحدائق والنباتات من المفضلة؟',
      confirmLabel: 'مسح',
    );
    if (confirmed) await favorites.clearAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.background),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Row(
                children: [
                  CircleIconButton(
                    icon: Icons.arrow_back,
                    tooltip: 'رجوع',
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 14),
                  const Text('الإعدادات', style: AppText.title),
                ],
              ),
              const SizedBox(height: 24),
              _SettingsTile(
                icon: Icons.info_outline,
                title: 'عن التطبيق',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutUsScreen()),
                ),
              ),
              _SettingsTile(
                icon: Icons.heart_broken_outlined,
                title: 'مسح المفضلة',
                color: AppColors.error,
                onTap: () => _clearFavorites(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: TextStyle(color: color, fontWeight: FontWeight.w700),
        ),
        trailing: const Icon(Icons.chevron_left, color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}

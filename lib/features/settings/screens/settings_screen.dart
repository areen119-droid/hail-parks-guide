import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lib/core/constants/app_colors.dart';
import 'package:hail_parks_guide/providers/auth_provider.dart' as app;
import 'package:hail_parks_guide/providers/user_provider.dart';
import 'package:hail_parks_guide/providers/home_provider.dart';
import 'package:hail_parks_guide/features/login/screens/signup_screen.dart';

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
            icon: Icons.logout,
            title: 'تسجيل الخروج',
            color: AppColors.errorRed,
            onTap: () => _showLogoutDialog(context),
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء',
                style: TextStyle(color: AppColors.mediumGrey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final authProvider =
              Provider.of<app.AuthProvider>(context, listen: false);
              final userProvider =
              Provider.of<UserProvider>(context, listen: false);
              final homeProvider =
              Provider.of<HomeProvider>(context, listen: false);
              await authProvider.signOut();
              userProvider.clearLoggedInUser();
              homeProvider.reset();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const SignupScreen()),
                      (route) => false,
                );
              }
            },
            child: const Text('تسجيل الخروج',
                style: TextStyle(color: AppColors.errorRed)),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_color.dart';
import '../../../providers/auth_provider.dart' as app;

class DeleteAccountScreen extends StatefulWidget {
  @override
  _DeleteAccountScreenState createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  bool _isChecked = false;
  bool _isLoading = false;

  Future<void> _deleteAccount() async {
    if (!_isChecked) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<app.AuthProvider>(context, listen: false);
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final userId = user.uid;

        // Option 1: HARD DELETE - Completely remove user data from Firestore
        await FirebaseFirestore.instance.collection('users').doc(userId).delete();

        // Option 2: SOFT DELETE - Deactivate account (keep data but mark as deleted)
        // await FirebaseFirestore.instance.collection('users').doc(userId).update({
        //   'isActive': false,
        //   'deletedAt': FieldValue.serverTimestamp(),
        //   'name': '[Deleted User]',
        //   'username': '[deleted_${userId.substring(0, 8)}]',
        //   'profileImageUrl': null,
        // });

        // Delete user from Firebase Authentication
        await user.delete();

        // Sign out after deletion
        await authProvider.signOut();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم حذف الحساب بنجاح'),
              backgroundColor: AppColors.signOutRed,
            ),
          );

          // Navigate to login screen
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        _showError('لأسباب أمنية، يرجى تسجيل الدخول مرة أخرى قبل حذف الحساب');
        // Optionally re-authenticate user
      } else {
        _showError('خطأ: ${e.message}');
      }
    } catch (e) {
      _showError('حدث خطأ: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        title: Text(
          'حذف الحساب',
          style: TextStyle(
            color: AppColors.signOutRed,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.signOutRed),
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning Icon
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.signOutRed.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: 50,
                  color: AppColors.signOutRed,
                ),
              ),
            ),

            SizedBox(height: 24),

            // Title
            Center(
              child: Text(
                'هل أنت متأكد؟',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.signOutRed,
                ),
              ),
            ),

            SizedBox(height: 16),

            // Warning Message
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.signOutRed.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.signOutRed.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  _buildWarningPoint(
                    icon: Icons.delete_forever,
                    text: 'سيتم حذف جميع بيانات نباتاتك نهائياً',
                  ),
                  SizedBox(height: 12),
                  _buildWarningPoint(
                    icon: Icons.emoji_events,
                    text: 'ستفقد جميع النقاط والإنجازات',
                  ),
                  SizedBox(height: 12),
                  _buildWarningPoint(
                    icon: Icons.people,
                    text: 'ستتم إزالتك من جميع لوحات المتصدرين',
                  ),
                  SizedBox(height: 12),
                  _buildWarningPoint(
                    icon: Icons.undo,
                    text: 'لا يمكن التراجع عن هذا الإجراء',
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Confirmation Checkbox
            Row(
              children: [
                Checkbox(
                  value: _isChecked,
                  onChanged: (value) {
                    setState(() {
                      _isChecked = value!;
                    });
                  },
                  activeColor: AppColors.signOutRed,
                ),
                Expanded(
                  child: Text(
                    'أدرك أن هذا الإجراء نهائي ولا يمكن التراجع عنه',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.baseBlackColor,
                    ),
                  ),
                ),
              ],
            ),

            Spacer(),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.mediumGrey,
                      side: BorderSide(color: AppColors.baseGreyColor),
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('إلغاء'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isChecked && !_isLoading
                        ? _deleteAccount
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.signOutRed,
                      foregroundColor: AppColors.whiteColor,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: AppColors.whiteColor,
                        strokeWidth: 2,
                      ),
                    )
                        : Text('حذف الحساب'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningPoint({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.signOutRed),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.baseBlackColor,
            ),
          ),
        ),
      ],
    );
  }
}
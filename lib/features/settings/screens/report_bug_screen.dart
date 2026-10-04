import 'package:flutter/material.dart';
import '../../../core/constants/app_color.dart';

class ReportBugScreen extends StatefulWidget {
  @override
  _ReportBugScreenState createState() => _ReportBugScreenState();
}

class _ReportBugScreenState extends State<ReportBugScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _screenController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _screenController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      await Future.delayed(Duration(seconds: 1));

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إرسال تقرير المشكلة بنجاح!'),
          backgroundColor: AppColors.baseDarkGreenColor,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        title: Text(
          'الإبلاغ عن مشكلة',
          style: TextStyle(
            color: AppColors.baseDarkGreenColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.baseDarkGreenColor),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(24),
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.bug_report_outlined,
                    size: 60,
                    color: AppColors.baseDarkGreenColor,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'ساعدنا على التحسين',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.baseBlackColor,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Instructions
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.softMint,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.baseDarkGreenColor.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'عند الإبلاغ عن مشكلة، يرجى تضمين:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.baseDarkGreenColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.circle, size: 6, color: AppColors.baseDarkGreenColor),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'وصف مختصر للمشكلة',
                          style: TextStyle(color: AppColors.baseBlackColor),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.circle, size: 6, color: AppColors.baseDarkGreenColor),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'مكان حدوث المشكلة (الشاشة أو الميزة)',
                          style: TextStyle(color: AppColors.baseBlackColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Screen/Feature Field
            TextFormField(
              controller: _screenController,
              decoration: InputDecoration(
                labelText: 'المكان',
                labelStyle: TextStyle(color: AppColors.mediumGrey),
                hintText: 'مثال: شاشة الملف الشخصي، لوحة المتصدرين...',
                hintStyle: TextStyle(color: AppColors.mediumGrey.withOpacity(0.5)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.baseGreyColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.baseDarkGreenColor, width: 2),
                ),
                prefixIcon: Icon(Icons.phone_android, color: AppColors.baseDarkGreenColor),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى تحديد مكان حدوث المشكلة';
                }
                return null;
              },
            ),

            SizedBox(height: 16),

            // Description Field
            TextFormField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'الوصف',
                labelStyle: TextStyle(color: AppColors.mediumGrey),
                hintText: 'صِف ما حدث...',
                hintStyle: TextStyle(color: AppColors.mediumGrey.withOpacity(0.5)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.baseGreyColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.baseDarkGreenColor, width: 2),
                ),
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Icon(Icons.description, color: AppColors.baseDarkGreenColor),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى وصف المشكلة';
                }
                return null;
              },
            ),

            SizedBox(height: 16),

            // Screenshot Option
            OutlinedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.camera_alt, color: AppColors.baseDarkGreenColor),
              label: Text(
                'إرفاق لقطة شاشة (اختياري)',
                style: TextStyle(color: AppColors.baseDarkGreenColor),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.baseDarkGreenColor),
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            SizedBox(height: 16),

            // Contact Email
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.softMint,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.email, color: AppColors.baseDarkGreenColor, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'HailParksGuide@gmail.com',
                    style: TextStyle(
                      color: AppColors.baseDarkGreenColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: _isLoading ? null : _submitReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.baseDarkGreenColor,
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
                  : Text(
                'إرسال التقرير',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
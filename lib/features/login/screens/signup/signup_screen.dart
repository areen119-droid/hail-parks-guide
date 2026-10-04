import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';
import 'package:hail_parks_guide/providers/auth_provider.dart' as app;

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _selectedCity;

  final List<String> _cities = [
    'الرياض', 'جدة', 'مكة المكرمة', 'المدينة المنورة', 'الدمام',
    'الخبر', 'الظهران', 'الجبيل', 'الأحساء', 'تبوك', 'بريدة',
    'القصيم', 'حائل', 'أبها', 'خميس مشيط', 'جازان', 'نجران',
    'الباحة', 'سكاكا', 'عرعر', 'ينبع', 'الطائف',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String _generateEmail(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return '$cleaned@hailparksguide.com';
  }

  String _generatePassword(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return 'GN_${cleaned}_2030';
  }

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final authProvider = Provider.of<app.AuthProvider>(context, listen: false);

        final phone = _phoneController.text.trim();
        final email = _generateEmail(phone);
        final password = _generatePassword(phone);

        bool success = await authProvider.registerWithEmail(
          email: email,
          password: password,
          name: _nameController.text.trim(),
          phoneNumber: phone,
          city: _selectedCity ?? '',
          gender: 'Female',
        );

        if (success && mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('فشل إنشاء الحساب. يرجى المحاولة مرة أخرى'),
              backgroundColor: AppColors.signOutRed,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${e.toString()}'),
            backgroundColor: AppColors.signOutRed,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.baseLightGreenColor,
      appBar: AppBar(
        title: const Text(
          'إنشاء حساب',
          style: TextStyle(
            color: AppColors.baseDarkGreenColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.baseDarkGreenColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Image.asset(
                    'assets/plants/GNLogo.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.eco,
                        size: 60,
                        color: AppColors.baseDarkGreenColor,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'إنشاء حساب جديد',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.baseDarkGreenColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'أدخل بياناتك للتسجيل',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.mediumGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'الاسم الكامل',
                    labelStyle: const TextStyle(color: AppColors.mediumGrey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.baseGreyColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.baseDarkGreenColor, width: 2),
                    ),
                    prefixIcon: const Icon(Icons.person,
                        color: AppColors.baseDarkGreenColor),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال الاسم الكامل';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Phone Field
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'رقم الجوال',
                    labelStyle: const TextStyle(color: AppColors.mediumGrey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.baseGreyColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.baseDarkGreenColor, width: 2),
                    ),
                    prefixIcon: const Icon(Icons.phone,
                        color: AppColors.baseDarkGreenColor),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال رقم الجوال';
                    }
                    if (value.length < 9) {
                      return 'الرجاء إدخال رقم جوال صحيح';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // City Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCity,
                  decoration: InputDecoration(
                    labelText: 'المدينة',
                    labelStyle: const TextStyle(color: AppColors.mediumGrey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.baseGreyColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.baseDarkGreenColor, width: 2),
                    ),
                    prefixIcon: const Icon(Icons.location_city,
                        color: AppColors.baseDarkGreenColor),
                  ),
                  items: _cities.map((city) {
                    return DropdownMenuItem<String>(
                      value: city,
                      child: Text(city, textAlign: TextAlign.right),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedCity = value);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء اختيار المدينة';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.baseDarkGreenColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: AppColors.whiteColor,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'إنشاء حساب',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.whiteColor,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'لديك حساب بالفعل؟',
                      style: TextStyle(color: AppColors.mediumGrey),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text(
                        'تسجيل الدخول',
                        style: TextStyle(
                          color: AppColors.baseDarkGreenColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
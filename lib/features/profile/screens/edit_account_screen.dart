import 'dart:io';
import 'dart:convert';  // ADD THIS
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:hail_parks_guide/models/user_model.dart';
import 'package:hail_parks_guide/providers/user_provider.dart';
import 'package:hail_parks_guide/providers/auth_provider.dart' as app;
import 'package:lib/core/constants/app_color.dart';

// REMOVED: import 'package:firebase_storage/firebase_storage.dart';

class EditAccountScreen extends StatefulWidget {
  final UserModel user;

  const EditAccountScreen({Key? key, required this.user}) : super(key: key);

  @override
  _EditAccountScreenState createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;
  late TextEditingController _cityController;
  String _selectedGender = 'أنثى';
  bool _isLoading = false;
  File? _selectedImage;
  String? _profileImageUrl;

  final List<String> _genders = ['ذكر', 'أنثى'];

  final List<String> _saudiCities = [
    'الرياض', 'جدة', 'مكة المكرمة', 'المدينة المنورة', 'الدمام',
    'الخبر', 'الظهران', 'بريدة', 'تبوك', 'حائل', 'الطائف', 'أبها',
    'خميس مشيط', 'نجران', 'جازان', 'ينبع', 'الجبيل', 'الأحساء',
    'القصيم', 'عرعر', 'سكاكا', 'الباحة',
  ];

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _nameController = TextEditingController(text: user.name);
    _usernameController = TextEditingController(text: user.username);
    _phoneController = TextEditingController(text: user.phoneNumber);
    _emailController = TextEditingController(text: user.email);
    _bioController = TextEditingController(text: user.bio);
    _cityController = TextEditingController(text: user.city);
    _selectedGender = user.gender == 'Male' ? 'ذكر' : 'أنثى';
    _profileImageUrl = user.profileImageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.photo_library, color: AppColors.baseDarkGreenColor),
              title: Text('اختر من المعرض', style: TextStyle(color: AppColors.baseBlackColor)),
              onTap: () async {
                Navigator.pop(context);
                await _pickImageFromSource(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppColors.baseDarkGreenColor),
              title: Text('التقاط صورة', style: TextStyle(color: AppColors.baseBlackColor)),
              onTap: () async {
                Navigator.pop(context);
                await _pickImageFromSource(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل اختيار الصورة'), backgroundColor: Colors.red),
      );
    }
  }

  // UPDATED: Convert image to Base64 instead of uploading to Firebase Storage
  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return _profileImageUrl;

    try {
      final bytes = await _selectedImage!.readAsBytes();
      return 'data:image/jpeg;base64,${base64Encode(bytes)}';
    } catch (e) {
      debugPrint('Error converting image: $e');
      return null;
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Convert image to Base64 if selected
        final imageUrl = await _uploadImage();

        final authProvider = Provider.of<app.AuthProvider>(context, listen: false);
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final userId = authProvider.currentUser!.id;

        Map<String, dynamic> updates = {
          'name': _nameController.text.trim(),
          'username': _usernameController.text.trim(),
          'bio': _bioController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
          'gender': _selectedGender == 'ذكر' ? 'Male' : 'Female',
          'city': _cityController.text.trim(),
        };

        if (imageUrl != null) {
          updates['profileImageUrl'] = imageUrl;
        }

        final bool success = await userProvider.updateUserProfile(userId, updates);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم تحديث الملف الشخصي بنجاح!'),
              backgroundColor: AppColors.baseDarkGreenColor,
            ),
          );
          Navigator.pop(context, true);
        } else {
          throw Exception('فشل في تحديث الملف الشخصي');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'تعديل الملف الشخصي',
          style: TextStyle(
            color: AppColors.baseDarkGreenColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.baseDarkGreenColor),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Profile Image with Upload Button
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.softMint,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : (_profileImageUrl != null && _profileImageUrl!.isNotEmpty
                        ? null  // Will be handled by child widget for base64
                        : null) as ImageProvider?,
                    child: _selectedImage == null && (_profileImageUrl == null || _profileImageUrl!.isEmpty)
                        ? Icon(Icons.person, size: 60, color: AppColors.baseDarkGreenColor)
                        : (_profileImageUrl != null && _profileImageUrl!.isNotEmpty && _selectedImage == null)
                        ? ClipOval(
                      child: Image.memory(
                        base64Decode(_profileImageUrl!.split(',').last),
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.baseDarkGreenColor,
                        child: Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Name Field
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'الاسم الكامل',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.person_outline, color: AppColors.baseDarkGreenColor),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال الاسم الكامل';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Username Field
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'اسم المستخدم',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.alternate_email, color: AppColors.baseDarkGreenColor),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال اسم المستخدم';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Bio Field
            TextFormField(
              controller: _bioController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'نبذة عني',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.description, color: AppColors.baseDarkGreenColor),
              ),
            ),
            const SizedBox(height: 16),

            // Gender Dropdown
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: InputDecoration(
                labelText: 'الجنس',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.people_outline, color: AppColors.baseDarkGreenColor),
              ),
              items: _genders.map((gender) {
                return DropdownMenuItem(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedGender = value!);
              },
            ),
            const SizedBox(height: 16),

            // City Dropdown
            DropdownButtonFormField<String>(
              value: _cityController.text.isNotEmpty ? _cityController.text : null,
              hint: const Text('اختر المدينة'),
              decoration: InputDecoration(
                labelText: 'المدينة',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.location_city, color: AppColors.baseDarkGreenColor),
              ),
              items: _saudiCities.map((city) {
                return DropdownMenuItem(
                  value: city,
                  child: Text(city),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _cityController.text = value ?? '');
              },
            ),
            const SizedBox(height: 16),

            // Phone Number Field
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'رقم الجوال',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.phone, color: AppColors.baseDarkGreenColor),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال رقم الجوال';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Email Field (Read Only)
            TextFormField(
              controller: _emailController,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'البريد الإلكتروني',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.email_outlined, color: AppColors.baseDarkGreenColor),
                filled: true,
                fillColor: AppColors.baseGreyColor.withOpacity(0.2),
              ),
            ),
            const SizedBox(height: 30),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.baseDarkGreenColor,
                foregroundColor: AppColors.whiteColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Text(
                'حفظ التغييرات',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
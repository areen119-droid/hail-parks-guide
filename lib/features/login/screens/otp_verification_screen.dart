import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_color.dart';
import '../../../providers/auth_provider.dart' as app;
import '../../profile/screens/profile_screen.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final bool isLogin;
  final String? userName;
  final String? username;
  final String? email;

  const OTPVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.isLogin,
    this.userName,
    this.username,
    this.email,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _verificationId = '';
  bool _isLoading = false;
  int _secondsRemaining = 30;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startPhoneVerification();
    _startTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          } else {
            _canResend = true;
            _timer?.cancel();
          }
        });
      }
    });
  }

  void _resetTimer() {
    setState(() {
      _secondsRemaining = 30;
      _canResend = false;
      _startTimer();
    });
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      UserCredential userCredential = await _auth.signInWithCredential(credential);

      final authProvider = Provider.of<app.AuthProvider>(context, listen: false);

      if (!widget.isLogin) {
        await authProvider.createNewUserProfile(
          userId: userCredential.user!.uid,
          phoneNumber: widget.phoneNumber,
          name: widget.userName ?? '',
          username: widget.username ?? '',
          email: widget.email ?? '',
          bio: '',
        );
        print('✅ New user profile created');
      } else {
        await authProvider.loadUserProfile(userCredential.user!.uid);
        print('✅ Existing user loaded');
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('فشل التحقق التلقائي: ${e.toString()}');
      }
    }
  }

  Future<void> _startPhoneVerification() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    await _auth.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        if (mounted) {
          setState(() => _isLoading = false);
          _showError('فشل التحقق: ${e.message}');
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        if (mounted) {
          setState(() {
            _verificationId = verificationId;
            _isLoading = false;
          });
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        if (mounted) {
          setState(() {
            _verificationId = verificationId;
            _isLoading = false;
          });
        }
      },
    );
  }

  Future<void> _resendCode() async {
    if (_canResend) {
      _resetTimer();
      setState(() => _isLoading = true);
      await _startPhoneVerification();
    }
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.length < 6) {
      _showError('الرجاء إدخال رمز التحقق المكون من 6 أرقام');
      return;
    }

    setState(() => _isLoading = true);

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otpController.text.trim(),
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      print('✅ User signed in: ${userCredential.user?.uid}');

      final authProvider = Provider.of<app.AuthProvider>(context, listen: false);

      if (!widget.isLogin) {
        await authProvider.createNewUserProfile(
          userId: userCredential.user!.uid,
          phoneNumber: widget.phoneNumber,
          name: widget.userName ?? '',
          username: widget.username ?? '',
          email: widget.email ?? '',
          bio: '',
        );
        print('✅ New user profile created');
      } else {
        await authProvider.loadUserProfile(userCredential.user!.uid);
        print('✅ Existing user loaded');
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('رمز غير صحيح: ${e.toString()}');
      }
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
        title: const Text('تأكيد الرمز'),
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        foregroundColor: AppColors.baseDarkGreenColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),

            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.softMint,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.message,
                  size: 50,
                  color: AppColors.baseDarkGreenColor,
                ),
              ),
            ),

            const SizedBox(height: 40),

            const Text(
              'أدخل رمز التحقق',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'تم إرسال رمز مكون من 6 أرقام إلى ${widget.phoneNumber}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 32),

            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                letterSpacing: 8,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                labelText: 'الرمز المكون من 6 أرقام',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Center(
              child: _canResend
                  ? TextButton(
                onPressed: _resendCode,
                child: const Text(
                  'إعادة إرسال الرمز',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              )
                  : Text(
                'إعادة الإرسال خلال $_secondsRemaining ثانية',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.baseDarkGreenColor,
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
                  'تأكيد وتسجيل الدخول',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
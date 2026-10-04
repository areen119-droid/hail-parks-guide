import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // This should work if files are in same directory

class FirebaseInitializer {
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('🔥 Firebase initialized successfully');
    } catch (e) {
      print('🔥 Firebase initialization error: $e');
    }
  }
}
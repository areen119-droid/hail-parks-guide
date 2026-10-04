import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload profile image
  Future<String?> uploadProfileImage(String userId, File imageFile) async {
    try {
      // Create a reference to the file location
      Reference ref = _storage.ref().child('profile_images').child('$userId.jpg');

      // Upload the file
      UploadTask uploadTask = ref.putFile(imageFile);

      // Wait for upload to complete
      TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();

      print('Profile image uploaded: $downloadUrl');
      return downloadUrl;
    } on FirebaseException catch (e) {
      print('Firebase Storage error: ${e.message}');
      return null;
    } catch (e) {
      print('Error uploading profile image: $e');
      return null;
    }
  }

  // Upload plant image
  Future<String?> uploadPlantImage(String plantId, File imageFile) async {
    try {
      // Create a reference to the file location
      Reference ref = _storage.ref().child('plant_images').child('$plantId.jpg');

      // Upload the file
      UploadTask uploadTask = ref.putFile(imageFile);

      // Wait for upload to complete
      TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();

      print('Plant image uploaded: $downloadUrl');
      return downloadUrl;
    } on FirebaseException catch (e) {
      print('Firebase Storage error: ${e.message}');
      return null;
    } catch (e) {
      print('Error uploading plant image: $e');
      return null;
    }
  }

  // Upload image with custom path
  Future<String?> uploadImage(String path, File imageFile) async {
    try {
      Reference ref = _storage.ref().child(path);
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Delete image
  Future<bool> deleteImage(String imageUrl) async {
    try {
      Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      print('Image deleted successfully');
      return true;
    } on FirebaseException catch (e) {
      print('Firebase Storage error: ${e.message}');
      return false;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  // Get download URL
  Future<String?> getDownloadURL(String path) async {
    try {
      Reference ref = _storage.ref().child(path);
      String url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Error getting download URL: $e');
      return null;
    }
  }

  // List all files in a folder
  Future<List<String>> listFiles(String folderPath) async {
    try {
      ListResult result = await _storage.ref().child(folderPath).listAll();
      List<String> fileNames = [];

      for (var item in result.items) {
        fileNames.add(item.name);
      }

      return fileNames;
    } catch (e) {
      print('Error listing files: $e');
      return [];
    }
  }
}
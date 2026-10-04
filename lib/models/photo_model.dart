import 'package:cloud_firestore/cloud_firestore.dart';

class PhotoModel {
  final String id;
  final String url;
  final String plantId;
  final String uploadedBy;
  final DateTime uploadedDate;
  final String? caption;

  PhotoModel({
    required this.id,
    required this.url,
    required this.plantId,
    required this.uploadedBy,
    required this.uploadedDate,
    this.caption,
  });

  factory PhotoModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return PhotoModel(
      id: documentId,
      url: data['url'] ?? '',
      plantId: data['plantId'] ?? '',
      uploadedBy: data['uploadedBy'] ?? '',
      uploadedDate: (data['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      caption: data['caption'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'url': url,
      'plantId': plantId,
      'uploadedBy': uploadedBy,
      'uploadedAt': Timestamp.fromDate(uploadedDate),
      'caption': caption,
    };
  }
}
import 'package:flutter/material.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';

class NewsModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String source;
  final DateTime publishedDate;
  final String category;
  final String content;
  final DateTime date; // Added this field

  NewsModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.source,
    required this.publishedDate,
    required this.category,
    required this.content,
    required this.date, // Added this
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      source: json['source'] ?? '',
      publishedDate: DateTime.parse(json['publishedDate'] ?? DateTime.now().toIso8601String()),
      category: json['category'] ?? 'General',
      content: json['content'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()), // Added this
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'source': source,
      'publishedDate': publishedDate.toIso8601String(),
      'category': category,
      'content': content,
      'date': date.toIso8601String(), // Added this
    };
  }
}
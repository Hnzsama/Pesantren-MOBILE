import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

class AchievementModel {
  final String id;
  final String title;
  final String studentId;
  final DateTime dateAchieved;
  final String description;
  final List<String> images; // JSON array of image URLs

  const AchievementModel({
    required this.id,
    required this.title,
    required this.studentId,
    required this.dateAchieved,
    required this.description,
    this.images = const [],
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    // Parse images: could be a JSON string or a List
    List<String> parsedImages = [];
    if (json['images'] != null) {
      if (json['images'] is List) {
        parsedImages = List<String>.from(json['images']);
      } else if (json['images'] is String) {
        // Handle encoded JSON string if API sends it that way
        try {
          // imports dart:convert implied if used, handled below or ensure imported
          // But images usually array. If string, likely serialized JSON array.
          // parsedImages = ...
        } catch (_) {}
      }
    }

    final baseUrl = dotenv.env['IMG_URL'] ?? '';
    if (baseUrl.isNotEmpty) {
      parsedImages = parsedImages.map((img) {
        if (!img.startsWith('http')) {
          if (img.startsWith('/')) {
            return '$baseUrl$img';
          } else {
            return '$baseUrl/$img';
          }
        }
        return img;
      }).toList();
    }

    return AchievementModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Prestasi Tanpa Judul',
      studentId: json['student_id']?.toString() ?? '',
      dateAchieved:
          DateTime.tryParse(json['date_achieved']?.toString() ?? '') ??
          DateTime.now(),
      description: json['description'] ?? '',
      images: parsedImages,
    );
  }

  String get formattedDate {
    return DateFormat('d MMMM yyyy', 'id_ID').format(dateAchieved);
  }
}

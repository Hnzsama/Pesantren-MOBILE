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

  String get formattedDate {
    return DateFormat('d MMMM yyyy', 'id_ID').format(dateAchieved);
  }
}

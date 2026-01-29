import 'package:pesantren_mobile/src/features/achievements/models/achievement_model.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pesantren_mobile/src/features/auth/services/auth_service.dart';

class AchievementService {
  // Mock Data attached to Students
  // Assuming student IDs match what we have in SantriModel or are generic
  // "1" = Ahmad Fulan
  // "2" = Siti Aminah

  // Mock Data attached to Students (Fallback)
  static final List<AchievementModel> _mockAchievements = [
    AchievementModel(
      id: '1',
      studentId: '1',
      title: 'Juara 1 Lomba Tahfidz Juz 30',
      dateAchieved: DateTime(2025, 12, 15),
      description:
          'Meraih juara pertama dalam musabaqah hifdzil quran kategori juz 30 tingkat kabupaten.',
      images: [
        'https://picsum.photos/id/1018/400/300',
        'https://picsum.photos/id/1015/400/300',
      ],
    ),
  ];

  Future<List<AchievementModel>> getAchievements(
    String studentId, {
    String? schoolId,
  }) async {
    final authService = AuthService();
    final token = await authService.getToken();

    if (token == null) {
      debugPrint('No token found, returning mock data');
      return _mockAchievements.where((a) => a.studentId == studentId).toList();
    }

    final baseUrl = dotenv.env['APP_URL'] ?? 'http://localhost:8000/api';
    // Append school_id query parameter if available
    final queryParams = <String, String>{};
    if (schoolId != null) queryParams['school_id'] = schoolId;

    final uri = Uri.parse(
      '$baseUrl/prestasi',
    ).replace(queryParameters: queryParams);

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      debugPrint('Prestasi Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = data['data'] ?? (data is List ? data : []);

        final allAchievements = list
            .map((json) => AchievementModel.fromJson(json))
            .toList();

        // Client-side filtering by studentId if API doesn't support it yet
        return allAchievements.where((a) => a.studentId == studentId).toList();
      } else {
        debugPrint('Failed to load achievements: ${response.body}');
        return _mockAchievements
            .where((a) => a.studentId == studentId)
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching achievements: $e');
      return _mockAchievements.where((a) => a.studentId == studentId).toList();
    }
  }
}

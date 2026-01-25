import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pesantren_mobile/src/features/activities/models/activity_model.dart';
import 'package:pesantren_mobile/src/features/auth/services/auth_service.dart';

class ActivityService {
  /// Fetches activities for a student on a specific date.
  ///
  /// Calls GET /api/activities with student_id, date, and optional type filter.
  Future<List<ActivityWithStatus>> getStudentActivities({
    required String studentId,
    required String? levelId, // Not used in API call, kept for compatibility
    required DateTime date,
    ActivityType? type, // null for 'Semua'
  }) async {
    final authService = AuthService();
    final token = await authService.getToken();

    if (token == null) {
      debugPrint('No token found');
      return [];
    }

    final baseUrl = dotenv.env['APP_URL'] ?? 'http://localhost:8000/api';

    final queryParams = <String, String>{
      'student_id': studentId,
      'date': _formatDate(date), // YYYY-MM-DD
    };

    if (type != null) {
      queryParams['type'] = type.name; // 'daily' or 'rutinan'
    }

    final uri = Uri.parse(
      '$baseUrl/activities',
    ).replace(queryParameters: queryParams);

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Activities Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => ActivityWithStatus.fromJson(item)).toList();
      } else {
        debugPrint('Failed to load activities: ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching activities: $e');
      return [];
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

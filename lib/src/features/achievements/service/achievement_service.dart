import 'package:pesantren_mobile/src/features/achievements/models/achievement_model.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pesantren_mobile/src/features/auth/services/auth_service.dart';
import 'package:pesantren_mobile/src/shared/utils/error_handler.dart';

class AchievementService {
  Future<List<AchievementModel>> getAchievements(
    String studentId, {
    String? schoolId,
  }) async {
    final authService = AuthService();
    final token = await authService.getToken();

    if (token == null) {
      throw ApiException('Sesi berakhir. Silakan login kembali.');
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
        throw ApiException(
          ErrorHandler.getErrorMessage(response),
          statusCode: response.statusCode,
        );
      }
    } on ApiException catch (_) {
      rethrow;
    } catch (e) {
      debugPrint('Error fetching achievements: $e');
      throw ApiException(ErrorHandler.getErrorMessage(e));
    }
  }
}

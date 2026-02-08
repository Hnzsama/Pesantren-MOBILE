import 'package:pesantren_mobile/src/features/kajian/models/kajian_model.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pesantren_mobile/src/features/auth/services/auth_service.dart';
import 'package:pesantren_mobile/src/shared/utils/error_handler.dart';

class KajianService {
  Future<List<VideoLecture>> getVideos() async {
    final authService = AuthService();
    final token = await authService.getToken();

    if (token == null) {
      throw ApiException('Sesi berakhir. Silakan login kembali.');
    }

    final baseUrl = dotenv.env['APP_URL'] ?? 'http://localhost:8000/api';
    final url = Uri.parse('$baseUrl/kajian');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      debugPrint('Kajian Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Assuming API resource returns { "data": [ ... ] } or simple [ ... ]
        // Standard Laravel Resource Collection usually wraps in 'data'
        final List<dynamic> list = data['data'] ?? (data is List ? data : []);

        return list.map((json) => VideoLecture.fromJson(json)).toList();
      } else {
        throw ApiException(
          ErrorHandler.getErrorMessage(response),
          statusCode: response.statusCode,
        );
      }
    } on ApiException catch (_) {
      rethrow;
    } catch (e) {
      debugPrint('Error fetching kajian: $e');
      throw ApiException(ErrorHandler.getErrorMessage(e));
    }
  }
}

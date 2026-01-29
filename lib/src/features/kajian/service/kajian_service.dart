import 'package:pesantren_mobile/src/features/kajian/models/kajian_model.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pesantren_mobile/src/features/auth/services/auth_service.dart';

class KajianService {
  // Mock Data
  // Mock Data (Fallback)
  static final List<VideoLecture> _mockVideos = [
    VideoLecture(
      id: '1',
      title: 'Tausiyah Rutin Bulanan',
      videoId: 'APaxt8Bp4D0',
      description:
          'Kajian rutin bulanan membahas pentingnya pendidikan karakter di era digital.',
      publishedAt: DateTime(2025, 12, 10),
    ),
  ];

  Future<List<VideoLecture>> getVideos() async {
    final authService = AuthService();
    final token = await authService.getToken();

    if (token == null) {
      debugPrint('No token found, returning mock data');
      return _mockVideos;
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
        debugPrint('Failed to load kajian: ${response.body}');
        return _mockVideos; // Fallback
      }
    } catch (e) {
      debugPrint('Error fetching kajian: $e');
      return _mockVideos; // Fallback
    }
  }
}

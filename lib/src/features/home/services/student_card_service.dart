import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pesantren_mobile/src/features/auth/services/auth_service.dart';
import 'package:pesantren_mobile/src/features/home/models/student_card_model.dart';
import 'package:pesantren_mobile/src/shared/utils/error_handler.dart';

class StudentCardService {
  Future<List<StudentCardModel>> getStudentCards() async {
    final authService = AuthService();
    final token = await authService.getToken();

    if (token == null) {
      debugPrint('No token found');
      return [];
    }

    final baseUrl = dotenv.env['APP_URL'] ?? 'http://localhost:8000/api';
    final uri = Uri.parse('$baseUrl/student-cards');

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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = data['data'] ?? [];
        return list.map((json) => StudentCardModel.fromJson(json)).toList();
      } else {
        throw ApiException(
          ErrorHandler.getErrorMessage(response),
          statusCode: response.statusCode,
        );
      }
    } on ApiException catch (_) {
      rethrow;
    } catch (e) {
      debugPrint('Error fetching student cards: $e');
      throw ApiException(ErrorHandler.getErrorMessage(e));
    }
  }
}

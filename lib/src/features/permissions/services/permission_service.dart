import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pesantren_mobile/src/features/permissions/models/permission_model.dart';
import 'package:pesantren_mobile/src/features/auth/services/auth_service.dart';

/// Service to handle permission requests API calls
class PermissionService {
  final AuthService _authService = AuthService();

  /// Fetches all permission requests for all students of the logged-in guardian
  /// GET /api/permissions
  Future<List<PermissionModel>> getPermissions() async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final baseUrl = dotenv.env['APP_URL'] ?? 'http://localhost:8000/api';
    final url = Uri.parse('$baseUrl/permissions');

    try {
      debugPrint('Fetching permissions');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      debugPrint('Permissions Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        debugPrint('Permissions count: ${data.length}');

        return data.map((json) => PermissionModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load permissions: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching permissions: $e');
      rethrow;
    }
  }

  /// Submit a new permission request
  /// POST /api/permissions
  Future<PermissionModel> submitPermission({
    required String studentId,
    required String reason,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final baseUrl = dotenv.env['APP_URL'] ?? 'http://localhost:8000/api';
    final url = Uri.parse('$baseUrl/permissions');

    final body = {
      'student_id': studentId,
      'reason': reason,
      'start_date':
          '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}',
      'end_date':
          '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}',
    };

    try {
      debugPrint('Submitting permission request: $body');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode(body),
      );

      debugPrint('Submit Permission Response: ${response.statusCode}');

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        debugPrint('Permission submitted: ${responseData['message']}');

        return PermissionModel.fromJson(responseData['data']);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to submit permission');
      }
    } catch (e) {
      debugPrint('Error submitting permission: $e');
      rethrow;
    }
  }
}

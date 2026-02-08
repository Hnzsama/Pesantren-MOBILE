import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pesantren_mobile/src/features/sowan/models/sowan_model.dart';
import 'package:pesantren_mobile/src/features/auth/services/auth_service.dart';

/// Service to handle sowan (visitation) schedules API calls
class SowanService {
  final AuthService _authService = AuthService();

  /// Fetches all sowan schedules
  /// GET /api/sowan-schedules
  Future<List<SowanModel>> getSowanSchedules({
    String? status,
    String? schoolId,
  }) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final baseUrl = dotenv.env['APP_URL'] ?? 'http://localhost:8000/api';

    // Build query parameters
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;
    if (schoolId != null) queryParams['school_id'] = schoolId;

    final uri = Uri.parse(
      '$baseUrl/sowan-schedules',
    ).replace(queryParameters: queryParams);

    try {
      debugPrint('Fetching sowan schedules: $uri');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      debugPrint('Sowan Schedules Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> data = responseData['data']['data'] ?? [];
        debugPrint('Sowan schedules count: ${data.length}');

        return data.map((json) => SowanModel.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load sowan schedules: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error fetching sowan schedules: $e');
      rethrow;
    }
  }

  /// Create a new sowan schedule
  /// POST /api/sowan-schedules
  Future<SowanModel> createSowanSchedule({
    required String schoolId,
    required String guestName,
    required DateTime requestDate,
    required String topic,
    String status = 'pending',
  }) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final baseUrl = dotenv.env['APP_URL'] ?? 'http://localhost:8000/api';
    final url = Uri.parse('$baseUrl/sowan-schedules');

    final body = {
      'school_id': schoolId,
      'guest_name': guestName,
      'request_date':
          '${requestDate.year}-${requestDate.month.toString().padLeft(2, '0')}-${requestDate.day.toString().padLeft(2, '0')} ${requestDate.hour.toString().padLeft(2, '0')}:${requestDate.minute.toString().padLeft(2, '0')}:${requestDate.second.toString().padLeft(2, '0')}',
      'topic': topic,
      'status': status,
    };

    try {
      debugPrint('Creating sowan schedule: $body');
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

      debugPrint('Create Sowan Response: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return SowanModel.fromJson(responseData['data']);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ?? 'Failed to create sowan schedule',
        );
      }
    } catch (e) {
      debugPrint('Error creating sowan schedule: $e');
      rethrow;
    }
  }

  /// Update an existing sowan schedule
  /// PUT/PATCH /api/sowan-schedules/{id}
  Future<SowanModel> updateSowanSchedule(
    String id,
    Map<String, dynamic> updates,
  ) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final baseUrl = dotenv.env['APP_URL'] ?? 'http://localhost:8000/api';
    final url = Uri.parse('$baseUrl/sowan-schedules/$id');

    try {
      debugPrint('Updating sowan schedule $id: $updates');
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode(updates),
      );

      debugPrint('Update Sowan Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return SowanModel.fromJson(responseData['data']);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ?? 'Failed to update sowan schedule',
        );
      }
    } catch (e) {
      debugPrint('Error updating sowan schedule: $e');
      rethrow;
    }
  }

  /// Delete a sowan schedule
  /// DELETE /api/sowan-schedules/{id}
  Future<void> deleteSowanSchedule(String id) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final baseUrl = dotenv.env['APP_URL'] ?? 'http://localhost:8000/api';
    final url = Uri.parse('$baseUrl/sowan-schedules/$id');

    try {
      debugPrint('Deleting sowan schedule $id');
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      debugPrint('Delete Sowan Response: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ?? 'Failed to delete sowan schedule',
        );
      }
    } catch (e) {
      debugPrint('Error deleting sowan schedule: $e');
      rethrow;
    }
  }
}

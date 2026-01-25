import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pesantren_mobile/src/features/bills/models/bill_model.dart';
import 'package:pesantren_mobile/src/features/auth/services/auth_service.dart';

/// Service to handle bill data retrieval from API.
class BillService {
  final AuthService _authService = AuthService();

  /// Fetches bills for a specific student
  /// Returns list of StudentBill from GET /api/bills?student_id={studentId}
  Future<List<StudentBill>> getBills(String studentId) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final baseUrl = dotenv.env['APP_URL'] ?? 'http://localhost:8000/api';
    final url = Uri.parse('$baseUrl/bills?student_id=$studentId');

    try {
      debugPrint('Fetching bills for student: $studentId');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Bills Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        debugPrint('Bills count: ${data.length}');

        return data.map((json) => StudentBill.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load bills: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching bills: $e');
      rethrow;
    }
  }
}

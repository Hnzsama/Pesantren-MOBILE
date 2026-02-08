import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pesantren_mobile/src/features/auth/services/auth_service.dart';
import 'package:pesantren_mobile/src/features/profile/models/parent_model.dart';
import 'package:pesantren_mobile/src/features/profile/models/school_model.dart';
import 'package:pesantren_mobile/src/features/profile/models/student_detail_model.dart';
import 'package:pesantren_mobile/src/shared/utils/error_handler.dart';

class ProfileService {
  final AuthService _authService = AuthService();

  /// Fetches complete student profile including parent and school data
  /// Returns a map with keys: 'student', 'parent', 'school'
  Future<Map<String, dynamic>> getStudentProfile(String studentId) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw ApiException('Sesi berakhir. Silakan login kembali.');
    }

    final baseUrl = dotenv.env['APP_URL'] ?? 'http://localhost:8000/api';
    final url = Uri.parse('$baseUrl/students/$studentId');

    try {
      debugPrint('Fetching student profile for ID: $studentId');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      debugPrint('Profile Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Profile Data: $data');

        return {
          'student': data['student'] != null
              ? StudentDetailModel.fromJson(data['student'])
              : StudentDetailModel.fromJson(data),
          'parent': data['parent'] != null || data['guardian'] != null
              ? ParentModel.fromJson(data['parent'] ?? data['guardian'])
              : null,
          'school': data['school'] != null
              ? SchoolModel.fromJson(data['school'])
              : null,
        };
      } else {
        throw ApiException(
          ErrorHandler.getErrorMessage(response),
          statusCode: response.statusCode,
        );
      }
    } on ApiException catch (_) {
      rethrow;
    } catch (e) {
      debugPrint('Error fetching student profile: $e');
      throw ApiException(ErrorHandler.getErrorMessage(e));
    }
  }

  /// Alternative method: Fetch user data which includes students with their relations
  Future<Map<String, dynamic>> getStudentProfileFromUser(
    String studentId,
  ) async {
    final user = await _authService.getUser();
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // Find the student in user's students list
    final student = user.students.firstWhere(
      (s) => s.id == studentId,
      orElse: () => throw Exception('Student not found'),
    );

    // Return basic data - parent and school might need separate endpoints
    return {
      'student': StudentDetailModel(
        id: student.id,
        name: student.nama,
        photoUrl: student.photoUrl,
        status: 'AKTIF', // Default, might come from API
        nis: student.id,
        gender: student.jenisKelamin,
      ),
      'parent': null, // Would need separate API call
      'school': student.schoolId != null
          ? await _getSchoolById(student.schoolId!)
          : null,
    };
  }

  Future<SchoolModel?> _getSchoolById(String schoolId) async {
    final token = await _authService.getToken();
    if (token == null) return null;

    final baseUrl = dotenv.env['APP_URL'] ?? 'http://localhost:8000/api';
    final url = Uri.parse('$baseUrl/schools/$schoolId');

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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SchoolModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Error fetching school: $e');
    }
    return null;
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pesantren_mobile/src/features/auth/services/auth_service.dart';
import 'package:pesantren_mobile/src/features/reports/models/report_models.dart';
import 'package:pesantren_mobile/src/shared/utils/error_handler.dart';

class ReportService {
  final AuthService _authService = AuthService();

  String get _baseUrl => dotenv.env['APP_URL'] ?? 'http://localhost:8000/api';

  Future<List<AcademicYear>> getAcademicFilters() async {
    final token = await _authService.getToken();
    if (token == null) {
      throw ApiException('Sesi berakhir. Silakan login kembali.');
    }

    final uri = Uri.parse('$_baseUrl/reports/filters');

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

      debugPrint('Report Filters Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> data = jsonData['data'] ?? [];
        return data.map((json) => AcademicYear.fromJson(json)).toList();
      } else {
        throw ApiException(
          ErrorHandler.getErrorMessage(response),
          statusCode: response.statusCode,
        );
      }
    } on ApiException catch (_) {
      rethrow;
    } catch (e) {
      debugPrint('Error fetching report filters: $e');
      throw ApiException(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<List<StudentReport>> getReports({
    String? studentId,
    String? academicYearId,
    String? semesterId,
    int perPage = 15,
  }) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw ApiException('Sesi berakhir. Silakan login kembali.');
    }

    final queryParams = {
      if (studentId != null) 'student_id': studentId,
      if (academicYearId != null) 'academic_year_id': academicYearId,
      if (semesterId != null) 'semester_id': semesterId,
      'per_page': perPage.toString(),
    };

    final uri = Uri.parse(
      '$_baseUrl/reports',
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

      debugPrint('Reports List Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> data = jsonData['data'] ?? [];
        return data.map((json) => StudentReport.fromJson(json)).toList();
      } else {
        throw ApiException(
          ErrorHandler.getErrorMessage(response),
          statusCode: response.statusCode,
        );
      }
    } on ApiException catch (_) {
      rethrow;
    } catch (e) {
      debugPrint('Error fetching reports: $e');
      throw ApiException(ErrorHandler.getErrorMessage(e));
    }
  }

  /// Helper to get a single report for a student in a specific semester
  Future<StudentReport?> getReport(String studentId, String semesterId) async {
    final reports = await getReports(
      studentId: studentId,
      semesterId: semesterId,
    );
    if (reports.isEmpty) return null;
    return reports.first;
  }
}

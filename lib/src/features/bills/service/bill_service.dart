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
          'ngrok-skip-browser-warning': 'true',
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

  /// Fetches bill detail by ID
  Future<StudentBill> getBillDetail(String id) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No token');

    final baseUrl = dotenv.env['APP_URL'] ?? "";
    final url = Uri.parse('$baseUrl/bills/$id');

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return StudentBill.fromJson(data);
    } else {
      throw Exception('Failed to load bill detail');
    }
  }

  /// Initiates payment for a bill
  /// Returns Map with snap_token, order_id, bill_id
  Future<Map<String, dynamic>> payBill(
    String billId, {
    String? paymentType,
    int? adminFee,
    int? paymentFee,
    String? studentId,
  }) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No token');

    final baseUrl = dotenv.env['APP_URL'] ?? "";
    final uri = Uri.parse('$baseUrl/bills/$billId/pay');

    debugPrint(
      'Initiating bill payment: $billId, Type: $paymentType, AdminFee: $adminFee, PaymentFee: $paymentFee',
    );

    final body = <String, dynamic>{};
    if (paymentType != null) body['payment_type'] = paymentType;
    if (adminFee != null) body['admin_fee'] = adminFee;
    if (paymentFee != null) body['payment_fee'] = paymentFee;
    if (studentId != null) body['student_id'] = studentId;

    final response = await http.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode(body),
    );

    debugPrint('Pay Bill Response: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Payment initiation failed');
    }
  }
}

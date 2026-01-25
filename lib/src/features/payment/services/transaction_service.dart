import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pesantren_mobile/src/features/auth/services/auth_service.dart';
import 'package:pesantren_mobile/src/features/transactions/models/transaction_model.dart';

class TransactionService {
  final AuthService _authService = AuthService();

  Future<String?> getSnapToken({
    required int amount,
    required String orderId,
    required String studentId,
    required String paymentType,
    int? adminFee, // Added adminFee
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        debugPrint("No authentication token found");
        return null;
      }

      final baseUrl = dotenv.env['APP_URL'] ?? "";
      final uri = Uri.parse('$baseUrl/midtrans/snap-token');

      final queryParams = {
        'amount': amount.toString(),
        'student_id': studentId,
        'payment_type': paymentType,
      };

      if (adminFee != null) {
        queryParams['admin_fee'] = adminFee.toString();
      }

      final url = uri.replace(queryParameters: queryParams);

      debugPrint("Fetching Snap Token from: $url");

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint("Response Status: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('snap_token')) {
          return data['snap_token'];
        } else if (data is Map && data.containsKey('token')) {
          return data['token'];
        }
        return null;
      } else {
        debugPrint("Failed to get snap token: ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("Error fetching snap token: $e");
      return null;
    }
  }

  Future<List<TransactionModel>> getTransactions({
    required String studentId,
    String? type,
    String? category,
    String? startDate,
    String? endDate,
    int page = 1,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return [];

      final baseUrl = dotenv.env['APP_URL'] ?? "";
      final uri = Uri.parse('$baseUrl/transactions');

      final queryParams = {'student_id': studentId, 'page': page.toString()};

      if (type != null) queryParams['type'] = type;
      if (category != null) queryParams['category'] = category;
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final url = uri.replace(queryParameters: queryParams);

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('data')) {
          return (data['data'] as List)
              .map((e) => TransactionModel.fromJson(e))
              .toList();
        }
        return [];
      } else {
        debugPrint("Failed to fetch transactions: ${response.body}");
        return [];
      }
    } catch (e) {
      debugPrint("Error fetching transactions: $e");
      return [];
    }
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pesantren_mobile/src/features/auth/services/auth_service.dart';
import 'package:pesantren_mobile/src/features/transactions/models/transaction_model.dart';
import 'package:pesantren_mobile/src/features/payment/models/payment_channel_model.dart';

class TransactionService {
  final AuthService _authService = AuthService();

  Future<PaymentChannelsResponse?> getPaymentChannels() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      final baseUrl = dotenv.env['APP_URL'] ?? "";
      final url = Uri.parse('$baseUrl/payment-channels');

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
        return PaymentChannelsResponse.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching payment channels: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getSnapToken({
    required int amount,
    required String orderId,
    required String studentId,
    required String paymentType,
    int? adminFee,
    int? paymentFee,
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
      if (paymentFee != null) {
        queryParams['payment_fee'] = paymentFee.toString();
      }

      final url = uri.replace(queryParameters: queryParams);

      debugPrint("Fetching Snap Token from: $url");

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      debugPrint("Response Status: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data as Map<String, dynamic>;
      } else {
        debugPrint("Failed to get snap token: ${response.body}");
        final errorData = jsonDecode(response.body);
        final errorMessage =
            errorData['message'] ?? 'Gagal memproses pembayaran';
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint("Error fetching snap token: $e");
      rethrow;
    }
  }

  Future<TransactionModel?> getTransactionById(String id) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      final baseUrl = dotenv.env['APP_URL'] ?? "";
      final url = Uri.parse('$baseUrl/transactions/$id');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      debugPrint("Get Transaction Status: ${response.statusCode}");
      debugPrint("Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return TransactionModel.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching transaction details: $e");
      return null;
    }
  }

  Future<List<TransactionModel>> getTransactions({
    required String studentId,
    String? type,
    String? category,
    String? status,
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
      if (status != null) queryParams['status'] = status;
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final url = uri.replace(queryParameters: queryParams);

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
        if (data is Map && data.containsKey('data')) {
          var transactions = (data['data'] as List)
              .map((e) => TransactionModel.fromJson(e))
              .toList();

          // Client-side filtering fallback
          if (status != null) {
            transactions = transactions
                .where((t) => t.status.toUpperCase() == status.toUpperCase())
                .toList();
          }
          if (type != null) {
            transactions = transactions
                .where((t) => t.type.toUpperCase() == type.toUpperCase())
                .toList();
          }
          if (category != null) {
            transactions = transactions
                .where(
                  (t) => t.category.toUpperCase() == category.toUpperCase(),
                )
                .toList();
          }

          return transactions;
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

  Future<bool> cancelTransaction(String id) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return false;

      final baseUrl = dotenv.env['APP_URL'] ?? "";
      final url = Uri.parse('$baseUrl/transactions/$id/cancel');

      debugPrint("Cancelling transaction: $url");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      debugPrint("Cancel Response: ${response.statusCode}");
      debugPrint("Body: ${response.body}");

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Error cancelling transaction: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>?> retryTransaction(String id) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      final baseUrl = dotenv.env['APP_URL'] ?? "";
      final url = Uri.parse('$baseUrl/transactions/$id/pay');

      debugPrint("Retrying transaction: $url");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      debugPrint("Retry Response: ${response.statusCode}");
      debugPrint("Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint("Error retrying transaction: $e");
      return null;
    }
  }
}

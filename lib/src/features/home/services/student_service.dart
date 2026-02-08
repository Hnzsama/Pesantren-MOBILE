import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pesantren_mobile/src/features/auth/services/auth_service.dart';
import 'package:pesantren_mobile/src/shared/utils/error_handler.dart';

class StudentService {
  final AuthService _authService = AuthService();

  Future<double?> getWalletBalance(String studentId) async {
    final token = await _authService.getToken();
    if (token == null) return null;

    final baseUrl = dotenv.env['APP_URL'] ?? 'http://localhost:8000/api';
    final uri = Uri.parse('$baseUrl/students/$studentId/wallet');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        var balance = data['wallet_balance'];

        if (balance == null && data['data'] != null) {
          balance = data['data']['wallet_balance'];
        }

        if (balance == null) {
          debugPrint("Wallet balance not found in response: ${response.body}");
          return null;
        }

        return double.tryParse(balance.toString());
      } else {
        throw ApiException(
          ErrorHandler.getErrorMessage(response),
          statusCode: response.statusCode,
        );
      }
    } on ApiException catch (_) {
      rethrow;
    } catch (e) {
      debugPrint('Error fetching wallet balance: $e');
      throw ApiException(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<Map<String, dynamic>> updateWalletPin(
    String studentId,
    String pin,
    String pinConfirmation,
  ) async {
    final token = await _authService.getToken();
    if (token == null) {
      return {
        'success': false,
        'message': 'Sesi berakhir. Silakan login kembali.',
      };
    }

    final baseUrl = dotenv.env['APP_URL'] ?? 'http://localhost:8000/api';
    final uri = Uri.parse('$baseUrl/students/$studentId/wallet/pin');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({'pin': pin, 'pin_confirmation': pinConfirmation}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': ErrorHandler.getErrorMessage(response),
          'errors': data['errors'],
        };
      }
    } catch (e) {
      debugPrint('Error updating wallet PIN: $e');
      return {'success': false, 'message': ErrorHandler.getErrorMessage(e)};
    }
  }

  Future<Map<String, dynamic>> updateDailyCashLimit(
    String studentId,
    double limit,
  ) async {
    final token = await _authService.getToken();
    if (token == null) {
      return {
        'success': false,
        'message': 'Sesi berakhir. Silakan login kembali.',
      };
    }

    final baseUrl = dotenv.env['APP_URL'] ?? 'http://localhost:8000/api';
    final uri = Uri.parse('$baseUrl/students/$studentId/wallet/limit');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({'daily_cash_limit': limit}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': ErrorHandler.getErrorMessage(response),
        };
      }
    } catch (e) {
      debugPrint('Error updating daily limit: $e');
      return {'success': false, 'message': ErrorHandler.getErrorMessage(e)};
    }
  }
}

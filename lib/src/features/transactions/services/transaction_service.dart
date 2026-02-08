import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pesantren_mobile/src/features/auth/services/auth_service.dart';
import 'package:pesantren_mobile/src/features/transactions/models/transaction_model.dart';
import 'package:pesantren_mobile/src/shared/utils/error_handler.dart';

class TransactionService {
  Future<List<TransactionModel>> getTransactions({
    required String studentId,
    String? type,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
  }) async {
    final authService = AuthService();
    final token = await authService.getToken();

    if (token == null) {
      debugPrint('No token found');
      return [];
    }

    final baseUrl = dotenv.env['APP_URL'] ?? 'http://localhost:8000/api';

    final queryParams = <String, String>{
      'student_id': studentId,
      'page': page.toString(),
    };

    if (type != null && type.isNotEmpty) queryParams['type'] = type;
    if (category != null && category.isNotEmpty)
      queryParams['category'] = category;

    if (startDate != null) {
      queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
    }
    if (endDate != null) {
      queryParams['end_date'] = endDate.toIso8601String().split('T')[0];
    }

    final uri = Uri.parse(
      '$baseUrl/transactions',
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

      debugPrint('Transactions Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = data['data'] ?? [];
        return list.map((json) => TransactionModel.fromJson(json)).toList();
      } else {
        throw ApiException(
          ErrorHandler.getErrorMessage(response),
          statusCode: response.statusCode,
        );
      }
    } on ApiException catch (_) {
      rethrow;
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
      throw ApiException(ErrorHandler.getErrorMessage(e));
    }
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pesantren_mobile/src/features/auth/services/auth_service.dart';
import 'package:pesantren_mobile/src/features/news/models/news_model.dart';
import 'package:pesantren_mobile/src/shared/utils/error_handler.dart';

class NewsService {
  final AuthService _authService = AuthService();

  Future<String?> _getToken() async {
    return await _authService.getToken();
  }

  String get _baseUrl => dotenv.env['APP_URL'] ?? 'http://localhost:8000/api';

  /// Get paginated news list
  /// [perPage] - Number of items per page (default: 15)
  /// [page] - Page number (default: 1)
  /// [targetRole] - Filter by target role (default: 'guardian')
  Future<Map<String, dynamic>> getNews({
    int perPage = 15,
    int page = 1,
    String? targetRole = 'guardian',
  }) async {
    final token = await _getToken();

    if (token == null) {
      throw ApiException('Sesi berakhir. Silakan login kembali.');
    }

    final queryParams = {
      'per_page': perPage.toString(),
      'page': page.toString(),
      if (targetRole != null) 'target_role': targetRole,
    };

    final uri = Uri.parse(
      '$_baseUrl/news',
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

      debugPrint('News Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        // Extract pagination data
        final data = jsonData['data'];
        final newsList = (data['data'] as List)
            .map((json) => NewsModel.fromJson(json))
            .toList();

        return {
          'data': newsList,
          'current_page': data['current_page'] ?? 1,
          'last_page': data['last_page'] ?? 1,
          'total': data['total'] ?? 0,
          'per_page': data['per_page'] ?? perPage,
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
      debugPrint('Error fetching news: $e');
      throw ApiException(ErrorHandler.getErrorMessage(e));
    }
  }

  /// Get single news by ID
  Future<NewsModel?> getNewsById(String id) async {
    final token = await _getToken();

    if (token == null) {
      debugPrint('No token found for news detail API');
      return null;
    }

    final uri = Uri.parse('$_baseUrl/news/$id');

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

      debugPrint('News Detail Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return NewsModel.fromJson(jsonData['data']);
      } else {
        debugPrint('Failed to load news detail: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching news detail: $e');
      return null;
    }
  }

  /// Get latest news for home page
  /// [limit] - Number of items to fetch (default: 5)
  Future<List<NewsModel>> getLatestNews({int limit = 5}) async {
    final result = await getNews(perPage: limit, page: 1);
    return result['data'] as List<NewsModel>;
  }
}

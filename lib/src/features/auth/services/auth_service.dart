import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pesantren_mobile/src/features/auth/models/user_model.dart';
import 'package:pesantren_mobile/src/shared/utils/error_handler.dart';
import 'package:pesantren_mobile/src/shared/services/notification_service.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  Future<bool> login(String username, String password) async {
    final baseUrl = dotenv.env['APP_URL'] ?? 'http://localhost:8000/api';
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({'email': username, 'password': password}),
      );

      debugPrint('Login Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        if (token != null) {
          await _saveToken(token);
          await getUser(); // Fetch and save user details

          // Update FCM token on backend after login
          final fcmToken = await NotificationService().getToken();
          await NotificationService().updateTokenOnBackend(fcmToken);

          return true;
        }
      } else {
        throw ApiException(
          ErrorHandler.getErrorMessage(response),
          statusCode: response.statusCode,
        );
      }
      return false;
    } on ApiException catch (_) {
      rethrow;
    } catch (e) {
      debugPrint('Login error: $e');
      throw ApiException(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<UserModel?> getUser() async {
    final token = await getToken();
    if (token == null) return null;

    final baseUrl = dotenv.env['APP_URL'] ?? 'http://localhost:8000/api';
    final url = Uri.parse('$baseUrl/user');

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

      debugPrint('Get User Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Handle response being [User] or User object
        dynamic userData;
        if (data is List && data.isNotEmpty) {
          userData = data[0];
        } else if (data is Map<String, dynamic>) {
          userData = data;
        }

        if (userData != null) {
          final user = UserModel.fromJson(userData);
          await _saveUser(user);
          return user;
        }
      } else {
        throw ApiException(
          ErrorHandler.getErrorMessage(response),
          statusCode: response.statusCode,
        );
      }
    } on ApiException catch (_) {
      rethrow;
    } catch (e) {
      debugPrint('Get User error: $e');
      throw ApiException(ErrorHandler.getErrorMessage(e));
    }
    return null;
  }

  Future<void> _saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  // Check if token is valid by fetching user.
  // Returns true if valid, false otherwise.
  Future<bool> checkAuth() async {
    try {
      final token = await getToken();
      if (token == null) return false;

      // We try to fetch the user. If we get a 401 or similar, the token is invalid.
      final user = await getUser();

      if (user != null) {
        // Update FCM token on backend after successful auth check
        final fcmToken = await NotificationService().getToken();
        NotificationService().updateTokenOnBackend(fcmToken);
      }

      return user != null;
    } catch (e) {
      debugPrint('Check auth error: $e');
      return false;
    }
  }

  Future<UserModel?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);

    final baseUrl = dotenv.env['APP_URL'] ?? 'http://localhost:8000/api';
    if (token != null) {
      try {
        await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'ngrok-skip-browser-warning': 'true',
          },
        );
      } catch (e) {
        debugPrint("Logout error: $e");
      }
    }

    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  // --- Forgot Password ---

  Future<bool> forgotPassword(String email) async {
    final baseUrl = dotenv.env['APP_URL'] ?? 'http://localhost:8000/api';
    final url = Uri.parse('$baseUrl/forgot-password');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw ApiException(
          ErrorHandler.getErrorMessage(response),
          statusCode: response.statusCode,
        );
      }
    } on ApiException catch (_) {
      rethrow;
    } catch (e) {
      throw ApiException(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<bool> resetPassword(
    String email,
    String otpCode,
    String password,
    String passwordConfirmation,
  ) async {
    final baseUrl = dotenv.env['APP_URL'] ?? 'http://localhost:8000/api';
    final url = Uri.parse('$baseUrl/reset-password');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({
          'email': email,
          'otp_code': otpCode,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw ApiException(
          ErrorHandler.getErrorMessage(response),
          statusCode: response.statusCode,
        );
      }
    } on ApiException catch (_) {
      rethrow;
    } catch (e) {
      throw ApiException(ErrorHandler.getErrorMessage(e));
    }
  }

  // --- Email Verification ---

  Future<bool> verifyEmailOtp(String otpCode) async {
    final token = await getToken();
    if (token == null) throw ApiException('User not authenticated');

    final baseUrl = dotenv.env['APP_URL'] ?? 'http://localhost:8000/api';
    final url = Uri.parse('$baseUrl/email/verify-otp');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({'otp_code': otpCode}),
      );

      if (response.statusCode == 200) {
        // Refresh user data to reflect verification status
        await getUser();
        return true;
      } else {
        throw ApiException(
          ErrorHandler.getErrorMessage(response),
          statusCode: response.statusCode,
        );
      }
    } on ApiException catch (_) {
      rethrow;
    } catch (e) {
      throw ApiException(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<bool> resendVerification() async {
    final token = await getToken();
    if (token == null) throw ApiException('User not authenticated');

    final baseUrl = dotenv.env['APP_URL'] ?? 'http://localhost:8000/api';
    final url = Uri.parse('$baseUrl/email/verification-notification');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw ApiException(
          ErrorHandler.getErrorMessage(response),
          statusCode: response.statusCode,
        );
      }
    } on ApiException catch (_) {
      rethrow;
    } catch (e) {
      throw ApiException(ErrorHandler.getErrorMessage(e));
    }
  }
}

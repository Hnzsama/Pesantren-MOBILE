import 'dart:async';
import 'dart:io' as io;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is ApiException) {
      return error.message;
    }

    if (!kIsWeb && error is io.SocketException) {
      return 'Tidak ada koneksi internet. Silakan periksa jaringan Anda.';
    }

    if (error is TimeoutException) {
      return 'Koneksi terputus. Silakan coba lagi nanti.';
    }

    if (error is http.Response) {
      try {
        final body = jsonDecode(error.body);
        if (body is Map<String, dynamic> && body['message'] != null) {
          return body['message'];
        }
      } catch (_) {
        // Fallback to default messages if parsing fails
      }

      switch (error.statusCode) {
        case 400:
          return 'Permintaan tidak valid.';
        case 401:
          return 'Sesi Anda telah berakhir. Silakan login kembali.';
        case 403:
          return 'Anda tidak memiliki akses ke fitur ini.';
        case 404:
          return 'Data tidak ditemukan.';
        case 422:
          return 'Data yang Anda masukkan tidak valid.';
        case 429:
          return 'Terlalu banyak permintaan. Silakan coba lagi nanti.';
        case 500:
          return 'Terjadi kesalahan pada server. Silakan coba beberapa saat lagi.';
        default:
          return 'Terjadi kesalahan yang tidak diketahui (${error.statusCode}).';
      }
    }

    return 'Terjadi kesalahan sistem. Silakan coba lagi.';
  }
}

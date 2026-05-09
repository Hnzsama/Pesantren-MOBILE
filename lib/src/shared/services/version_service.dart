import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UpdateInfo {
  final String latestVersion;
  final int latestBuildNumber;
  final String downloadUrl;
  final bool forceUpdate;

  UpdateInfo({
    required this.latestVersion,
    required this.latestBuildNumber,
    required this.downloadUrl,
    required this.forceUpdate,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      latestVersion: json['version'] ?? '1.0.0',
      latestBuildNumber: json['build_number'] ?? 1,
      downloadUrl: json['download_url'] ?? '',
      forceUpdate: json['force_update'] ?? false,
    );
  }
}

class VersionService {
  Future<PackageInfo> getPackageInfo() async {
    return await PackageInfo.fromPlatform();
  }

  Future<UpdateInfo?> checkForUpdate() async {
    final updateUrl = dotenv.env['UPDATE_URL'];
    if (updateUrl == null || updateUrl.isEmpty) {
      debugPrint('UPDATE_URL not found in .env');
      return null;
    }

    try {
      final response = await http.get(Uri.parse(updateUrl), headers: {
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final updateInfo = UpdateInfo.fromJson(data);
        
        final packageInfo = await getPackageInfo();
        final currentBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 0;

        if (updateInfo.latestBuildNumber > currentBuildNumber) {
          return updateInfo;
        }
      }
    } catch (e) {
      debugPrint('Error checking for update: $e');
    }
    return null;
  }
}

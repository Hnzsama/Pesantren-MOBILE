// ignore_for_file: constant_identifier_names

import 'package:flutter_dotenv/flutter_dotenv.dart';

enum SemesterType { GANJIL, GENAP }

class Semester {
  final String id;
  final String academicYearId;
  final SemesterType type;
  final String? startDate;

  const Semester({
    required this.id,
    required this.academicYearId,
    required this.type,
    this.startDate,
  });

  factory Semester.fromJson(Map<String, dynamic> json) {
    return Semester(
      id: json['id'],
      academicYearId: json['academic_year_id'],
      type: json['type'] == 'GANJIL' ? SemesterType.GANJIL : SemesterType.GENAP,
      startDate: json['start_date'],
    );
  }

  String get label =>
      type == SemesterType.GANJIL ? "Semester Ganjil" : "Semester Genap";
}

class AcademicYear {
  final String id;
  final String name; // e.g. "2024/2025"
  final bool isActive;
  final List<Semester> semesters;

  const AcademicYear({
    required this.id,
    required this.name,
    required this.isActive,
    required this.semesters,
  });

  factory AcademicYear.fromJson(Map<String, dynamic> json) {
    var semesterList =
        (json['semesters'] as List?)
            ?.map((s) => Semester.fromJson(s))
            .toList() ??
        [];

    return AcademicYear(
      id: json['id'],
      name: json['name'],
      isActive: json['is_active'] ?? false,
      semesters: semesterList,
    );
  }
}

class StudentReport {
  final String id;
  final String studentId;
  final String semesterId;
  final String? filePath;
  final List<String> fileUrls;
  final String? uploadedAt;
  final String? studentName;
  final String? semesterType;
  final String? academicYearName;

  const StudentReport({
    required this.id,
    required this.studentId,
    required this.semesterId,
    this.filePath,
    this.fileUrls = const [],
    this.uploadedAt,
    this.studentName,
    this.semesterType,
    this.academicYearName,
  });

  factory StudentReport.fromJson(Map<String, dynamic> json) {
    // Get all possible file sources safely
    final List<String> rawUrls = [];

    final singularUrl = json['file_url'];
    if (singularUrl != null && singularUrl is String) {
      rawUrls.add(singularUrl);
    }

    final filesArray = json['files'];
    if (filesArray != null && filesArray is List) {
      for (final item in filesArray) {
        if (item != null && item is String && !rawUrls.contains(item)) {
          rawUrls.add(item);
        }
      }
    }

    // Resolve all URLs
    final baseUrlRaw = dotenv.env['APP_URL'] ?? '';
    final baseUri = Uri.parse(baseUrlRaw);
    final rootUri = Uri(
      scheme: baseUri.scheme,
      host: baseUri.host,
      port: baseUri.port,
    );

    final List<String> finalUrls = rawUrls.map((url) {
      if (url.startsWith('http')) return url;
      return rootUri.resolve(url).toString();
    }).toList();

    return StudentReport(
      id: json['id']?.toString() ?? '',
      studentId: json['student']?['id']?.toString() ?? '',
      studentName: json['student']?['full_name'],
      semesterId: json['semester']?['id']?.toString() ?? '',
      semesterType: json['semester']?['type'],
      academicYearName: json['academic_year']?['name'],
      fileUrls: finalUrls,
      uploadedAt: json['uploaded_at'],
    );
  }

  // Helper to get the primary URL
  String? get fileUrl => fileUrls.isNotEmpty ? fileUrls.first : null;
}

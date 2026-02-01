import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pesantren_mobile/src/features/profile/models/school_model.dart';

class SantriModel {
  final String id;
  final String nama;
  final String? nis; // Added NIS field
  final String kelas;
  final String? photoUrl;
  final double uangSaku;
  final String kehadiranStatus; // "Hadir", "Izin", "Sakit", "Alpha"
  final double kehadiranPercentage;

  final String jenisKelamin; // "Laki-laki" or "Perempuan"
  final String? walletPin;
  final String departmentCode; // e.g. "MA", "MTS"
  final String? departmentName; // e.g. "Madrasah Ibtidaiyah"
  final double dailyCashLimit;
  final String? schoolId;
  final SchoolModel? school;

  const SantriModel({
    required this.id,
    required this.nama,
    this.nis,
    required this.kelas,
    this.photoUrl,
    required this.uangSaku,
    required this.kehadiranStatus,
    required this.kehadiranPercentage,
    this.jenisKelamin = 'Laki-laki',
    this.walletPin,
    this.departmentCode = 'MTS',
    this.departmentName,
    this.dailyCashLimit = 50000,
    this.schoolId,
    this.school,
  });

  factory SantriModel.fromJson(Map<String, dynamic> json) {
    String deptCode = 'MTS';
    String? deptName;
    String className = '-';

    // Parse Level & Department from nested objects if available
    // Check top-level 'level' object first (most reliable source based on sample JSON)
    if (json['level'] != null && json['level'] is Map) {
      final level = json['level'];
      // Use 'name' (e.g. "Kelas 6") or 'alias' (e.g. "MI 6")
      className = level['name'] ?? level['alias'] ?? '-';

      if (level['department'] != null && level['department'] is Map) {
        final dept = level['department'];
        deptCode = dept['code']?.toString() ?? 'MTS';
        deptName = dept['name']?.toString();
      }
    } else {
      // Fallback or multiple levels array handling (if applicable)
      if (className == '-') {
        className =
            json['class'] ??
            json['kelas'] ??
            json['level_id']?.toString() ??
            '-';
      }
    }

    // Fallback for department code
    if (deptCode == 'MTS') {
      if (json['departments'] != null && json['departments'] is Map) {
        deptCode = json['departments']['code']?.toString() ?? 'MTS';
      } else if (json['department'] != null && json['department'] is Map) {
        deptCode = json['department']['code']?.toString() ?? 'MTS';
      } else if (json['department_code'] != null) {
        deptCode = json['department_code'].toString();
      }
    }

    String? photoUrl = json['photo_url'];
    if (photoUrl != null && !photoUrl.startsWith('http')) {
      final baseUrl = dotenv.env['IMG_URL'] ?? '';
      if (baseUrl.isNotEmpty) {
        if (photoUrl.startsWith('/')) {
          photoUrl = '$baseUrl$photoUrl';
        } else {
          photoUrl = '$baseUrl/$photoUrl';
        }
      }
    }

    return SantriModel(
      id: json['id'].toString(),
      nama:
          json['name'] ??
          json['nama'] ??
          json['nama_santri'] ??
          json['student_name'] ??
          json['full_name'] ??
          'Unknown',
      nis: json['nis']?.toString(),
      kelas: className,
      photoUrl: photoUrl,
      uangSaku:
          double.tryParse(
            json['wallet_balance']?.toString() ??
                json['balance']?.toString() ??
                json['uang_saku']?.toString() ??
                json['saldo']?.toString() ??
                json['amount']?.toString() ??
                json['total_balance']?.toString() ??
                '0',
          ) ??
          0.0,
      kehadiranStatus: 'Hadir',
      kehadiranPercentage: 0.0,
      jenisKelamin:
          json['gender'] == 'P' ||
              json['jenis_kelamin'] == 'P' ||
              json['gender'] == 'Perempuan'
          ? 'Perempuan'
          : 'Laki-laki',
      walletPin: json['wallet_pin'],
      departmentCode: deptCode,
      departmentName: deptName,
      dailyCashLimit:
          double.tryParse(
            json['daily_limit']?.toString() ??
                json['daily_cash_limit']?.toString() ??
                '50000',
          ) ??
          50000,
      schoolId: json['school_id']?.toString(),
      school: json['school'] != null
          ? SchoolModel.fromJson(json['school'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'nis': nis,
      'kelas': kelas,
      'photo_url': photoUrl,
      'uang_saku': uangSaku,
      'jenis_kelamin': jenisKelamin,
      'wallet_pin': walletPin,
      'department_code': departmentCode,
      'department_name': departmentName,
      'daily_cash_limit': dailyCashLimit,
    };
  }

  SantriModel copyWith({
    String? id,
    String? nama,
    String? nis,
    String? kelas,
    String? photoUrl,
    double? uangSaku,
    String? kehadiranStatus,
    double? kehadiranPercentage,
    String? jenisKelamin,
    String? walletPin,
    String? departmentCode,
    String? departmentName,
    double? dailyCashLimit,
    String? schoolId,
    SchoolModel? school,
  }) {
    return SantriModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      nis: nis ?? this.nis,
      kelas: kelas ?? this.kelas,
      photoUrl: photoUrl ?? this.photoUrl,
      uangSaku: uangSaku ?? this.uangSaku,
      kehadiranStatus: kehadiranStatus ?? this.kehadiranStatus,
      kehadiranPercentage: kehadiranPercentage ?? this.kehadiranPercentage,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      walletPin: walletPin ?? this.walletPin,
      departmentCode: departmentCode ?? this.departmentCode,
      departmentName: departmentName ?? this.departmentName,
      dailyCashLimit: dailyCashLimit ?? this.dailyCashLimit,
      schoolId: schoolId ?? this.schoolId,
      school: school ?? this.school,
    );
  }
}

class MockData {
  static const List<SantriModel> santriList = [
    SantriModel(
      id: '1',
      nama: 'Ahmad Fulan',
      kelas: '10 MA',
      uangSaku: 150000,
      kehadiranStatus: 'Hadir',
      kehadiranPercentage: 95.0,
      jenisKelamin: 'Laki-laki',
      walletPin: '123456',
      dailyCashLimit: 100000,
    ),
    SantriModel(
      id: '2',
      nama: 'Siti Fulanah',
      kelas: '8 MTs',
      uangSaku: 50000,
      kehadiranStatus: 'Sakit',
      kehadiranPercentage: 88.5,
      jenisKelamin: 'Perempuan',
    ),
  ];
}

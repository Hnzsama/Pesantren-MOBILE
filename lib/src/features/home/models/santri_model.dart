import 'package:flutter_dotenv/flutter_dotenv.dart';

class SantriModel {
  final String id;
  final String nama;
  final String kelas;
  final String? photoUrl;
  final double uangSaku;
  final String kehadiranStatus; // "Hadir", "Izin", "Sakit", "Alpha"
  final double kehadiranPercentage;

  final String jenisKelamin; // "Laki-laki" or "Perempuan"
  final String? walletPin;
  final String departmentCode; // e.g. "MA", "MTS"
  final double dailyCashLimit;
  final String? schoolId;

  const SantriModel({
    required this.id,
    required this.nama,
    required this.kelas,
    this.photoUrl,
    required this.uangSaku,
    required this.kehadiranStatus,
    required this.kehadiranPercentage,
    this.jenisKelamin = 'Laki-laki',
    this.walletPin,
    this.departmentCode = 'MTS',
    this.dailyCashLimit = 50000,
    this.schoolId,
  });
  factory SantriModel.fromJson(Map<String, dynamic> json) {
    String deptCode = 'MTS';
    if (json['departments'] != null && json['departments'] is Map) {
      deptCode = json['departments']['code']?.toString() ?? 'MTS';
    } else if (json['department'] != null && json['department'] is Map) {
      deptCode = json['department']['code']?.toString() ?? 'MTS';
    } else if (json['department_code'] != null) {
      deptCode = json['department_code'].toString();
    }

    String? photoUrl = json['photo_url'];
    if (photoUrl != null && !photoUrl.startsWith('http')) {
      final baseUrl = dotenv.env['IMG_URL'] ?? '';
      if (baseUrl.isNotEmpty) {
        // Remove leading slash if both have it, or ensure one slash
        // Simple append for now assuming standard paths
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
      kelas:
          json['class'] ?? json['kelas'] ?? json['level_id']?.toString() ?? '-',
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
      kehadiranStatus:
          'Hadir', // This might need to be fetched separately or included in student object
      kehadiranPercentage: 0.0,
      jenisKelamin:
          json['gender'] == 'P' ||
              json['jenis_kelamin'] == 'P' ||
              json['gender'] == 'Perempuan'
          ? 'Perempuan'
          : 'Laki-laki',
      walletPin: json['wallet_pin'],
      departmentCode: deptCode,
      dailyCashLimit:
          double.tryParse(
            json['daily_limit']?.toString() ??
                json['daily_cash_limit']?.toString() ??
                '50000',
          ) ??
          50000,
      schoolId: json['school_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'kelas': kelas,
      'photo_url': photoUrl,
      'uang_saku': uangSaku,
      'jenis_kelamin': jenisKelamin,
      'wallet_pin': walletPin,
      'department_code': departmentCode,
      'daily_cash_limit': dailyCashLimit,
    };
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

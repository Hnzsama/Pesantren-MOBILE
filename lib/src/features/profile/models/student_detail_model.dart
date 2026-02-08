class StudentDetailModel {
  final String id;
  final String name;
  final String? nis;
  final String? photoUrl;
  final String status; // "ACTIVE", "INACTIVE", etc.
  final String? gender;
  final String? birthDate;
  final double? walletBalance;
  final double? dailyCashLimit;
  final bool? allowTransaction;
  final bool hasPin;
  final LevelModel? level;

  const StudentDetailModel({
    required this.id,
    required this.name,
    this.nis,
    this.photoUrl,
    required this.status,
    this.gender,
    this.birthDate,
    this.walletBalance,
    this.dailyCashLimit,
    this.allowTransaction,
    this.hasPin = false,
    this.level,
  });

  factory StudentDetailModel.fromJson(Map<String, dynamic> json) {
    return StudentDetailModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['full_name'] ?? 'Unknown',
      nis: json['nis']?.toString(),
      photoUrl: json['photo_url']?.toString(),
      status: json['status']?.toString() ?? 'ACTIVE',
      gender: json['gender']?.toString(),
      birthDate: json['birth_date']?.toString(),
      walletBalance: double.tryParse(json['wallet_balance']?.toString() ?? '0'),
      dailyCashLimit: double.tryParse(
        json['daily_cash_limit']?.toString() ?? '0',
      ),
      allowTransaction:
          json['allow_transaction'] == true ||
          json['allow_transaction']?.toString() == 'true',
      hasPin: json['has_pin'] == true || json['has_pin']?.toString() == 'true',
      level: json['level'] != null ? LevelModel.fromJson(json['level']) : null,
    );
  }

  // Helper getters
  String get levelName => level?.name ?? '-';
  String get displayStatus => status == 'ACTIVE' ? 'AKTIF' : status;
}

class LevelModel {
  final String id;
  final String name;

  const LevelModel({required this.id, required this.name});

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    return LevelModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '-',
    );
  }
}

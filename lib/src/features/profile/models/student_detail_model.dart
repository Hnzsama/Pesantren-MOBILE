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
    this.level,
  });

  factory StudentDetailModel.fromJson(Map<String, dynamic> json) {
    return StudentDetailModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['full_name'] ?? 'Unknown',
      nis: json['nis'],
      photoUrl: json['photo_url'],
      status: json['status'] ?? 'ACTIVE',
      gender: json['gender'],
      birthDate: json['birth_date'],
      walletBalance: double.tryParse(json['wallet_balance']?.toString() ?? '0'),
      dailyCashLimit: double.tryParse(
        json['daily_cash_limit']?.toString() ?? '0',
      ),
      allowTransaction: json['allow_transaction'],
      level: json['level'] != null ? LevelModel.fromJson(json['level']) : null,
    );
  }

  // Helper getters
  String get levelName => level?.name ?? '-';
  String get displayStatus => status == 'ACTIVE' ? 'AKTIF' : status;
}

class LevelModel {
  final int id;
  final String name;

  const LevelModel({required this.id, required this.name});

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    return LevelModel(id: json['id'] ?? 0, name: json['name'] ?? '-');
  }
}

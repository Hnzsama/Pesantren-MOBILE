import 'package:pesantren_mobile/src/features/home/models/santri_model.dart';

class StudentCardModel {
  final String id;
  final String studentId;
  final int issuedBy;
  final String cardNumber;
  final DateTime? issuedAt;
  final DateTime? expiresAt;
  final String status; // 'generated', 'request_print', 'printed'
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final SantriModel? student;

  const StudentCardModel({
    required this.id,
    required this.studentId,
    required this.issuedBy,
    required this.cardNumber,
    this.issuedAt,
    this.expiresAt,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.student,
  });

  factory StudentCardModel.fromJson(Map<String, dynamic> json) {
    return StudentCardModel(
      id: json['id']?.toString() ?? '',
      studentId: json['student_id']?.toString() ?? '',
      issuedBy: int.tryParse(json['issued_by']?.toString() ?? '0') ?? 0,
      cardNumber: json['card_number']?.toString() ?? '0000 0000 0000 0000',
      issuedAt: tryParseDateTime(json['issued_at']),
      expiresAt: tryParseDateTime(json['expires_at']),
      status: json['status']?.toString() ?? 'generated',
      createdAt: tryParseDateTime(json['created_at']),
      updatedAt: tryParseDateTime(json['updated_at']),
      student: json['student'] != null
          ? SantriModel.fromJson(json['student'])
          : null,
    );
  }

  bool get isPrinted => status == 'printed';
}

DateTime? tryParseDateTime(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

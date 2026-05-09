import 'package:flutter/material.dart';

enum PermissionStatus { pending, approved, rejected }

class PermissionModel {
  final String id;
  final String studentName;
  final String reason;
  final DateTime startDate;
  final DateTime endDate;
  final PermissionStatus status;
  final String? adminNote;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PermissionModel({
    required this.id,
    required this.studentName,
    required this.reason,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.adminNote,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    PermissionStatus parseStatus(String? statusStr) {
      switch (statusStr?.toLowerCase()) {
        case 'approved':
          return PermissionStatus.approved;
        case 'rejected':
          return PermissionStatus.rejected;
        case 'pending':
        default:
          return PermissionStatus.pending;
      }
    }

    return PermissionModel(
      id: json['id']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? 'Unknown',
      reason: json['reason']?.toString() ?? '',
      startDate: DateTime.tryParse(json['start_date']?.toString() ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date']?.toString() ?? '') ?? DateTime.now(),
      status: parseStatus(json['status']?.toString()),
      adminNote: json['admin_note']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    String statusToString() {
      switch (status) {
        case PermissionStatus.approved:
          return 'approved';
        case PermissionStatus.rejected:
          return 'rejected';
        case PermissionStatus.pending:
          return 'pending';
      }
    }

    return {
      'id': id,
      'student_name': studentName,
      'reason': reason,
      'start_date':
          '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}',
      'end_date':
          '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}',
      'status': statusToString(),
      'admin_note': adminNote,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper to get Color based on status
  Color get statusColor {
    switch (status) {
      case PermissionStatus.pending:
        return Colors.orange;
      case PermissionStatus.approved:
        return Colors.green;
      case PermissionStatus.rejected:
        return Colors.red;
    }
  }

  String get statusText {
    switch (status) {
      case PermissionStatus.pending:
        return "Menunggu";
      case PermissionStatus.approved:
        return "Disetujui";
      case PermissionStatus.rejected:
        return "Ditolak";
    }
  }
}

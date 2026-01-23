import 'package:flutter/material.dart';

enum PermissionStatus { pending, approved, rejected }

class PermissionModel {
  final String id;
  final String studentName; // Based on schema
  final String reason;
  final DateTime startDate;
  final DateTime endDate;
  final PermissionStatus status;
  final String? adminNote;
  final DateTime createdAt;

  const PermissionModel({
    required this.id,
    required this.studentName,
    required this.reason,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.adminNote,
    required this.createdAt,
  });

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

class MockPermissions {
  static final List<PermissionModel> data = [
    PermissionModel(
      id: '1',
      studentName: 'Ahmad Fulan',
      reason: 'Sakit Demam',
      startDate: DateTime.now().subtract(const Duration(days: 2)),
      endDate: DateTime.now().subtract(const Duration(days: 0)),
      status: PermissionStatus.approved,
      adminNote: 'Semoga lekas sembuh',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    PermissionModel(
      id: '2',
      studentName: 'Ahmad Fulan',
      reason: 'Acara Keluarga (Nikahan Kakak)',
      startDate: DateTime.now().add(const Duration(days: 5)),
      endDate: DateTime.now().add(const Duration(days: 7)),
      status: PermissionStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    PermissionModel(
      id: '3',
      studentName: 'Ahmad Fulan',
      reason: 'Pulang Kampung',
      startDate: DateTime.now().subtract(const Duration(days: 20)),
      endDate: DateTime.now().subtract(const Duration(days: 18)),
      status: PermissionStatus.rejected,
      adminNote: 'Belum waktunya liburan',
      createdAt: DateTime.now().subtract(const Duration(days: 22)),
    ),
  ];
}

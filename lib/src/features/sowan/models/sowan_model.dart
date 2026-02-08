import 'package:flutter/material.dart';

enum SowanStatus { pending, confirmed, completed }

class SowanModel {
  final String id;
  final String schoolId;
  final String guestName;
  final DateTime requestDate;
  final String topic;
  final SowanStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SowanModel({
    required this.id,
    required this.schoolId,
    required this.guestName,
    required this.requestDate,
    required this.topic,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SowanModel.fromJson(Map<String, dynamic> json) {
    SowanStatus parseStatus(String? statusStr) {
      switch (statusStr?.toLowerCase()) {
        case 'confirmed':
          return SowanStatus.confirmed;
        case 'completed':
          return SowanStatus.completed;
        case 'pending':
        default:
          return SowanStatus.pending;
      }
    }

    return SowanModel(
      id: json['id']?.toString() ?? '',
      schoolId: json['school_id']?.toString() ?? '',
      guestName: json['guest_name'] ?? 'Unknown',
      requestDate:
          DateTime.tryParse(json['request_date'] ?? '') ?? DateTime.now(),
      topic: json['topic'] ?? '',
      status: parseStatus(json['status']),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    String statusToString() {
      switch (status) {
        case SowanStatus.confirmed:
          return 'confirmed';
        case SowanStatus.completed:
          return 'completed';
        case SowanStatus.pending:
          return 'pending';
      }
    }

    return {
      'id': id,
      'school_id': schoolId,
      'guest_name': guestName,
      'request_date': requestDate.toIso8601String(),
      'topic': topic,
      'status': statusToString(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper to get Color based on status
  Color get statusColor {
    switch (status) {
      case SowanStatus.pending:
        return Colors.orange;
      case SowanStatus.confirmed:
        return Colors.blue;
      case SowanStatus.completed:
        return Colors.green;
    }
  }

  String get statusText {
    switch (status) {
      case SowanStatus.pending:
        return "Menunggu";
      case SowanStatus.confirmed:
        return "Dikonfirmasi";
      case SowanStatus.completed:
        return "Selesai";
    }
  }
}

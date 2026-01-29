import 'package:intl/intl.dart';

enum BillStatus { UNPAID, PAID, CANCELLED }

class BillCategory {
  final String id;
  final String name;
  final String? description;

  const BillCategory({required this.id, required this.name, this.description});

  factory BillCategory.fromJson(Map<String, dynamic> json) {
    return BillCategory(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Unknown',
      description: json['description'],
    );
  }
}

class BillEvent {
  final String id;
  final String title;
  final DateTime eventDate; // used for display date if event bill
  final double amount;

  const BillEvent({
    required this.id,
    required this.title,
    required this.eventDate,
    required this.amount,
  });

  factory BillEvent.fromJson(Map<String, dynamic> json) {
    return BillEvent(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Unknown Event',
      eventDate: DateTime.tryParse(json['event_date'] ?? '') ?? DateTime.now(),
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class StudentBill {
  final String id;
  final String studentId;
  final String title;
  final double amount;
  final BillStatus status;
  final DateTime dueDate;
  final DateTime? paidAt;
  final String? paymentMethod;

  final int adminFee;
  final int paymentFee;

  // Relations
  final BillCategory? category;
  final BillEvent? event;

  const StudentBill({
    required this.id,
    required this.studentId,
    required this.title,
    required this.amount,
    required this.status,
    required this.dueDate,
    this.paidAt,
    this.paymentMethod,
    this.category,
    this.event,
    this.adminFee = 0,
    this.paymentFee = 0,
  });

  factory StudentBill.fromJson(Map<String, dynamic> json) {
    BillStatus parsedStatus;
    final statusStr = json['status']?.toString().toUpperCase() ?? 'UNPAID';

    if (statusStr == 'PAID') {
      parsedStatus = BillStatus.PAID;
    } else if (statusStr == 'CANCELLED') {
      parsedStatus = BillStatus.CANCELLED;
    } else {
      parsedStatus = BillStatus.UNPAID;
    }

    return StudentBill(
      id: json['id']?.toString() ?? '',
      studentId: json['student_id']?.toString() ?? '',
      title: json['title'] ?? 'Tagihan',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      status: parsedStatus,
      dueDate: DateTime.tryParse(json['due_date'] ?? '') ?? DateTime.now(),
      paidAt: json['paid_at'] != null
          ? DateTime.tryParse(json['paid_at'])
          : null,
      paymentMethod: json['payment_method'],
      category: json['category'] != null
          ? BillCategory.fromJson(json['category'])
          : null,
      event: json['event'] != null ? BillEvent.fromJson(json['event']) : null,
      adminFee: (double.tryParse(json['admin_fee']?.toString() ?? '0') ?? 0)
          .toInt(),
      paymentFee: (double.tryParse(json['payment_fee']?.toString() ?? '0') ?? 0)
          .toInt(),
    );
  }

  // Helper Logic
  bool get isEventBill => event != null;

  String get displayLabel {
    if (isEventBill) return "Tagihan Event";
    return category?.name ?? "Tagihan Lainnya";
  }

  DateTime get displayDate {
    if (isEventBill && event != null) return event!.eventDate;
    return dueDate;
  }

  String get formattedAmount {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return currencyFormatter.format(amount);
  }

  String get displayStatus {
    switch (status) {
      case BillStatus.PAID:
        return 'Sudah Dibayar';
      case BillStatus.CANCELLED:
        return 'Dibatalkan';
      case BillStatus.UNPAID:
        return 'Belum Dibayar';
    }
  }
}

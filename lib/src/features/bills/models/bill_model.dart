import 'package:intl/intl.dart';

enum BillStatus { UNPAID, PAID, CANCELLED }

class BillCategory {
  final String id;
  final String name;
  final String? description;

  const BillCategory({required this.id, required this.name, this.description});
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
}

class StudentBill {
  final String id;
  final String studentId;
  final String title;
  final double amount;
  final BillStatus status;
  final DateTime dueDate;
  final DateTime? paidAt;

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
    this.category,
    this.event,
  });

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
}

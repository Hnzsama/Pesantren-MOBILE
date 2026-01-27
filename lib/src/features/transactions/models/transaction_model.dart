import 'package:intl/intl.dart';

class TransactionModel {
  final String id;
  final String invoiceCode;
  final String studentId;
  final String type; // 'CREDIT' (Income) or 'DEBIT' (Expense)
  final String category; // 'TOPUP', 'WITHDRAWAL', 'PURCHASE', 'DEPOSIT_TO_HQ'
  final double amount;
  final String description;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;

  const TransactionModel({
    required this.id,
    required this.invoiceCode,
    required this.studentId,
    required this.type,
    required this.category,
    required this.amount,
    required this.description,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id']?.toString() ?? '',
      invoiceCode: json['invoice_code'] ?? '',
      studentId: json['student_id']?.toString() ?? '',
      type: json['type'] ?? 'DEBIT',
      category: json['category'] ?? 'PURCHASE',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      description: json['description'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      status: json['status'] ?? 'UNPAID',
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  bool get isExpense => type == 'DEBIT';
  bool get isIncome => type == 'CREDIT';

  String get formattedDate {
    return DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(createdAt);
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

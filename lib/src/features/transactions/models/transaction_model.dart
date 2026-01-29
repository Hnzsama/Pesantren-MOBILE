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

  final String? snapToken;
  final int adminFee;
  final int paymentFee;
  final String? eventName;
  final DateTime? eventDate;

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
    this.snapToken,
    this.adminFee = 0,
    this.paymentFee = 0,
    this.eventName,
    this.eventDate,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id']?.toString() ?? '',
      invoiceCode: json['invoice_code'] ?? json['order_id'] ?? '',
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
      snapToken: json['snap_token'],
      adminFee: (double.tryParse(json['admin_fee']?.toString() ?? '0') ?? 0)
          .toInt(),
      paymentFee: (double.tryParse(json['payment_fee']?.toString() ?? '0') ?? 0)
          .toInt(),
      eventName: json['event_name'],
      eventDate: DateTime.tryParse(json['event_date']?.toString() ?? ''),
    );
  }

  bool get isExpense => type == 'DEBIT';
  bool get isIncome => type == 'CREDIT';

  double get grossAmount => amount + adminFee + paymentFee;

  String get formattedDate {
    return DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(createdAt);
  }

  String get formattedAmount {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    // If it's a TopUp or Bill Payment (Income/Expense with potential fee),
    // we should ideally show the Total user has to pay if it's Unpaid?
    // Actually, usually Amount is what affects the Balance.
    // Fee is extra.
    // But for History View, "Rp 51.000" is better than "Rp 50.000" if they paid 51k.
    // Let's show Gross Amount for display to match user expectation of "What I paid".
    // Or maybe show "Rp 50.000 + Rp 1.000 (Fee)"?
    // User complaint "nominalnya jadi tanpa admin lagi" suggests they want to see the Admin Fee included.

    // For now, let's stick to showing the stored amount (Base).
    // The user's issue was specifically about the PAYMENT PAGE (WebView) dropping the fee.
    // But displaying the total here helps debugging.

    return currencyFormatter.format(amount);
  }

  String get formattedTotalAmount {
    // New getter for total
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return currencyFormatter.format(grossAmount);
  }
}

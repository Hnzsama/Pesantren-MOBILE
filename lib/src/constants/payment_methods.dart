import 'package:flutter/material.dart';

class PaymentMethodConstants {
  static const List<Map<String, dynamic>> methods = [
    {
      'id': 0,
      'name': 'QRIS',
      'code': 'qris', // Will enable gopay + shopeepay for QRIS
      'desc': 'Scan QRIS (GoPay/ShopeePay/DANA)',
      'icon': Icons.qr_code_scanner,
      'color': Colors.blue,
      'fee_percent': 0.7, // 0.7% fee for QRIS
      'fee_flat': 0,
    },
    {
      'id': 1,
      'name': 'BCA Virtual Account',
      'code': 'bca_va',
      'desc': 'Virtual Account BCA',
      'icon': Icons.account_balance,
      'color': Colors.blue,
      'fee_percent': 0, // No percentage fee
      'fee_flat': 4000, // Flat Rp 4,000
    },
    {
      'id': 2,
      'name': 'Bank Syariah Indonesia (BSI)',
      'code': 'other_va', // BSI uses other_va
      'desc': 'Virtual Account BSI',
      'icon': Icons.account_balance,
      'color': Colors.teal,
      'fee_percent': 0,
      'fee_flat': 4000, // Flat Rp 4,000
    },
    {
      'id': 3,
      'name': 'Mandiri',
      'code': 'echannel', // Mandiri Bill Payment
      'desc': 'Mandiri Bill Payment',
      'icon': Icons.account_balance,
      'color': Colors.indigo,
      'fee_percent': 0,
      'fee_flat': 4000, // Flat Rp 4,000
    },
  ];

  static int findMethodIndex(String? code) {
    if (code == null) return 0;
    for (int i = 0; i < methods.length; i++) {
      if (methods[i]['code'] == code) return i;
    }
    return 0;
  }
}

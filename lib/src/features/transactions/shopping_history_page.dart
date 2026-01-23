import 'package:flutter/material.dart';
import 'package:pesantren_mobile/src/constants/app_colors.dart';
import 'package:pesantren_mobile/src/features/home/models/santri_model.dart';

class ShoppingHistoryPage extends StatefulWidget {
  final SantriModel activeSantri;
  final VoidCallback? onBack;

  const ShoppingHistoryPage({
    super.key,
    required this.activeSantri,
    this.onBack,
  });

  @override
  State<ShoppingHistoryPage> createState() => _ShoppingHistoryPageState();
}

class _ShoppingHistoryPageState extends State<ShoppingHistoryPage> {
  // Mock Data for Transactions
  final List<Map<String, dynamic>> _transactions = [
    {
      'title': 'Kantin Santri',
      'date': 'Hari ini, 10:00',
      'amount': -15000,
      'type': 'expense',
      'description': 'Makan Siang (Nasi Goreng + Es Teh)',
    },
    {
      'title': 'Koperasi Pesantren',
      'date': 'Hari ini, 07:30',
      'amount': -45000,
      'type': 'expense',
      'description': 'Buku Tulis, Pensil, Penghapus',
    },
    {
      'title': 'Top Up Deposit',
      'date': 'Kemarin, 14:20',
      'amount': 200000,
      'type': 'income',
      'description': 'Transfer Bank BCA',
    },
    {
      'title': 'Laundry',
      'date': 'Kemarin, 08:00',
      'amount': -20000,
      'type': 'expense',
      'description': 'Cuci Kering Lipat (3kg)',
    },
    {
      'title': 'Kantin Santri',
      'date': '22 Jan, 12:30',
      'amount': -12000,
      'type': 'expense',
      'description': 'Makan Siang',
    },
    {
      'title': 'Koperasi Pesantren',
      'date': '21 Jan, 16:00',
      'amount': -8000,
      'type': 'expense',
      'description': 'Snack Sore',
    },
    {
      'title': 'Top Up Deposit',
      'date': '20 Jan, 09:00',
      'amount': 500000,
      'type': 'income',
      'description': 'Transfer Bank Mandiri',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Fixed Pattern Background
          Positioned.fill(
            child: Opacity(
              opacity: 0.40,
              child: Image.asset('assets/background.jpeg', fit: BoxFit.cover),
            ),
          ),

          // 2. Main Content
          Container(), // Placeholder
        ],
      ),
    );
  }
}

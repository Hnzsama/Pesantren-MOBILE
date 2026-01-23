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
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

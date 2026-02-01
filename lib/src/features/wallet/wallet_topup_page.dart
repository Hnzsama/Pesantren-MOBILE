import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pesantren_mobile/src/constants/app_colors.dart';
import 'package:pesantren_mobile/src/features/home/models/santri_model.dart';
import 'package:intl/intl.dart';
// GlassContainer import removed
import 'package:pesantren_mobile/src/features/payment/services/transaction_service.dart';
import 'package:pesantren_mobile/src/features/payment/services/payment_service.dart';
import 'package:pesantren_mobile/src/features/auth/services/auth_service.dart';
import 'package:pesantren_mobile/src/features/transactions/models/transaction_model.dart';
import 'package:pesantren_mobile/src/features/transactions/pages/transaction_history_page.dart';
import 'package:pesantren_mobile/src/features/payment/models/payment_channel_model.dart';
import 'package:pesantren_mobile/src/features/payment/pages/payment_success_page.dart'; // Added

class WalletTopUpPage extends StatefulWidget {
  final SantriModel activeSantri;
  final VoidCallback? onBack;

  const WalletTopUpPage({super.key, required this.activeSantri, this.onBack});

  @override
  State<WalletTopUpPage> createState() => _WalletTopUpPageState();
}

class _WalletTopUpPageState extends State<WalletTopUpPage> {
  late SantriModel _activeSantri;
  int _selectedAmount = 50000;
  final TextEditingController _customAmountController = TextEditingController();
  final List<int> _presetAmounts = [
    20000,
    50000,
    100000,
    200000,
    500000,
    1000000,
  ];

  // Dynamic Payment Data
  List<PaymentChannel> _paymentChannels = [];
  int _globalAdminFee = 0;
  String? _selectedPaymentCode;
  bool _isLoadingChannels = true;
  bool _isSummaryExpanded = false;

  TransactionModel? _pendingTransaction;
  int _unpaidCount = 0;

  @override
  void initState() {
    super.initState();
    _activeSantri = widget.activeSantri;
    _fetchPaymentChannels();
    _checkPendingTransaction();

    _customAmountController.addListener(() {
      if (_customAmountController.text.isNotEmpty) {
        setState(() {
          _selectedAmount =
              int.tryParse(_customAmountController.text.replaceAll('.', '')) ??
              0;
        });
      }
    });
  }

  Future<void> _fetchPaymentChannels() async {
    try {
      final response = await TransactionService().getPaymentChannels();
      if (mounted) {
        setState(() {
          if (response != null) {
            _paymentChannels = response.channels;
            _globalAdminFee = response.adminFee;
            // Default select the first one if available
            if (_paymentChannels.isNotEmpty && _selectedPaymentCode == null) {
              _selectedPaymentCode = _paymentChannels.first.code;
            }
          }
          _isLoadingChannels = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching channels: $e");
      if (mounted) setState(() => _isLoadingChannels = false);
    }
  }

  Future<void> _checkPendingTransaction() async {
    try {
      final transactions = await TransactionService().getTransactions(
        studentId: _activeSantri.id,
        status: 'UNPAID', // Fetch all UNPAID
      );

      // Find if there is a pending topup that matches the current user intention?
      // Or just take the latest one?
      // Existing logic was finding one. Let's keep it simple: take the latest UNPAID TOPUP.

      final pending = transactions
          .where((t) => t.category == 'TOPUP' && t.status == 'UNPAID')
          .toList();

      // Sort by createdAt descending
      pending.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (mounted) {
        setState(() {
          _unpaidCount = transactions.length; // Count ALL unpaid transactions
          if (pending.isNotEmpty) {
            _pendingTransaction = pending.first;
            // Pre-select the method if possible
            if (_pendingTransaction != null &&
                _pendingTransaction!.paymentMethod.isNotEmpty &&
                _paymentChannels.isNotEmpty) {
              // Try to find matching channel code
              // This might be tricky if backend only stores name or method ID
              // Assuming paymentMethod stores code or name we can try to match
              _selectedPaymentCode = _pendingTransaction!.paymentMethod;
              // Reset amount to pending amount
              _selectedAmount = _pendingTransaction!.amount.toInt();
            }
          } else {
            _pendingTransaction = null;
          }
        });
      }
    } catch (e) {
      debugPrint("Error checking pending transactions: $e");
    }
  }

  IconData _getChannelIcon(String? code) {
    if (code == null) return Icons.payment;
    final c = code.toLowerCase();
    if (c.contains('qris')) return Icons.qr_code_scanner;
    if (c.contains('bsi')) return Icons.account_balance;
    if (c.contains('bca')) return Icons.credit_card;
    if (c.contains('mandiri')) return Icons.account_balance_wallet;
    if (c.contains('bri')) return Icons.savings;
    if (c.contains('bni')) return Icons.account_balance;
    if (c.contains('cimb')) return Icons.account_balance;
    if (c.contains('alfamart')) return Icons.store;
    if (c.contains('indomaret')) return Icons.store;
    return Icons.payment;
  }

  Color _getChannelColor(String? code) {
    if (code == null) return Colors.grey;
    final c = code.toLowerCase();
    if (c.contains('qris')) return Colors.black;
    if (c.contains('bsi')) return const Color(0xFF00A39D);
    if (c.contains('bca')) return const Color(0xFF005DAA);
    if (c.contains('mandiri')) return const Color(0xFF003D79);
    if (c.contains('bri')) return const Color(0xFF00529C);
    if (c.contains('bni')) return const Color(0xFFF15A23);
    if (c.contains('cimb')) return const Color(0xFFED1C24);
    if (c.contains('alfamart')) return const Color(0xFFD71920);
    if (c.contains('indomaret')) return const Color(0xFF005DAA);
    return Colors.blue;
  }

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    try {
      final authService = AuthService();
      final user = await authService.getUser(); // Fetch fresh user data
      if (user != null) {
        // Find the updated santri data from the user object
        final updatedSantri = user.students.firstWhere(
          (s) => s.id == _activeSantri.id,
          orElse: () => _activeSantri,
        );

        // Also check pending transactions
        await _checkPendingTransaction();

        if (mounted) {
          setState(() {
            _activeSantri = updatedSantri;
          });
        }
      }
    } catch (e) {
      debugPrint("Error refreshing data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildStickyBottomButton(),
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
          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  // ... existing properties
                  expandedHeight: 280,
                  pinned: true,
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(32),
                    ),
                  ),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: widget.onBack ?? () => Navigator.pop(context),
                  ),
                  actions: [
                    IconButton(
                      tooltip: "Riwayat Transaksi",
                      icon: Badge(
                        isLabelVisible: _unpaidCount > 0,
                        label: Text(_unpaidCount.toString()),
                        child: const Icon(Icons.history, color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TransactionHistoryPage(santri: _activeSantri),
                          ),
                        ).then((_) => _refreshData()); // Refresh when returning
                      },
                    ),
                  ],
                  centerTitle: true,
                  title: const Text(
                    "Isi Uang Saku",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(32),
                        ),
                      ),
                      child: SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Pending Transaction Alert
                            if (_pendingTransaction != null)
                              Container(
                                margin: const EdgeInsets.only(
                                  bottom: 16,
                                  left: 24,
                                  right: 24,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.orange.shade300,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.orange.shade800,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "Ada transaksi belum dibayar!",
                                        style: TextStyle(
                                          color: Colors.orange.shade900,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Premium Balance Card
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF007474), // AppColors.primary
                                    Color(0xFF004D4D), // Darker Teal
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF007474,
                                    ).withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    "Saldo Saat Ini",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    NumberFormat.currency(
                                      locale: 'id_ID',
                                      symbol: 'Rp ',
                                      decimalDigits: 0,
                                    ).format(_activeSantri.uangSaku),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CircleAvatar(
                                          radius: 10,
                                          backgroundColor: Colors.white,
                                          backgroundImage:
                                              _activeSantri.photoUrl != null
                                              ? NetworkImage(
                                                  _activeSantri.photoUrl!,
                                                )
                                              : null,
                                          child: _activeSantri.photoUrl == null
                                              ? const Icon(
                                                  Icons.person,
                                                  size: 14,
                                                  color: AppColors.primary,
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "${_activeSantri.nama} • ${_activeSantri.kelas}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: Stack(
              children: [
                // ... (keep background if any) ...
                SafeArea(
                  child: Column(
                    children: [
                      // Remove AbsorbPointer/Opacity to allow editing
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle("Pilih Nominal"),
                              const SizedBox(height: 16),
                              GridView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      mainAxisSpacing: 12,
                                      crossAxisSpacing: 12,
                                      childAspectRatio: 1.6,
                                    ),
                                itemCount: _presetAmounts.length,
                                itemBuilder: (context, index) {
                                  final amount = _presetAmounts[index];
                                  final isSelected = amount == _selectedAmount;
                                  return _buildNominalCard(amount, isSelected);
                                },
                              ),
                              const SizedBox(height: 24),

                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(color: Colors.grey.shade300),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text(
                                      "ATAU MASUKKAN MANUAL",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade500,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(color: Colors.grey.shade300),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: _customAmountController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center, // Centered
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                  decoration: InputDecoration(
                                    prefixText: "Rp ",
                                    prefixStyle: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.grey,
                                    ),
                                    hintText: "0",
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade300,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 20,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),

                              _buildSectionTitle("Metode Pembayaran"),
                              const SizedBox(height: 12),
                              // Render Payment Channels
                              if (_isLoadingChannels)
                                const Center(child: CircularProgressIndicator())
                              else if (_paymentChannels.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Center(
                                    child: Text(
                                      "Tidak ada metode pembayaran tersedia",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                )
                              else
                                ..._paymentChannels.map(
                                  (channel) =>
                                      _buildPaymentChannelCard(channel),
                                ),

                              const SizedBox(height: 32),

                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsiblePaymentSummary() {
    // Find selected channel
    PaymentChannel? channel;
    try {
      channel = _paymentChannels.firstWhere(
        (c) => c.code == _selectedPaymentCode,
      );
    } catch (_) {}

    if (channel == null) return const SizedBox.shrink();

    final feeAmount =
        channel.feeFlat + (_selectedAmount * channel.feePercent / 100).round();
    final totalFee = _globalAdminFee + feeAmount;
    final totalPayment = _selectedAmount + totalFee;

    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isSummaryExpanded = !_isSummaryExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Ringkasan Pembayaran",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                Icon(
                  _isSummaryExpanded
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_up,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
        if (_isSummaryExpanded) ...[
          const SizedBox(height: 8),
          _buildSummaryRow("Nominal Topup", _selectedAmount),
          if (_globalAdminFee > 0)
            _buildSummaryRow("Biaya Aplikasi", _globalAdminFee),
          _buildSummaryRow("Biaya Layanan", feeAmount),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Pembayaran",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                "Rp $totalPayment",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildSummaryRow(String label, int amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(
            "Rp $amount",
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildNominalCard(int amount, bool isSelected) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedAmount = amount;
          _customAmountController.clear();
        });
      },
      borderRadius: BorderRadius.circular(30), // Pill shape
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        alignment: Alignment.center,
        child: Text(
          NumberFormat.compactCurrency(
            locale: 'id_ID',
            symbol: '',
            decimalDigits: 0,
          ).format(amount),
          // "${(amount / 1000).toInt()}k", // Previous format
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildStickyBottomButton() {
    int displayTotal = _selectedAmount;
    if (_selectedPaymentCode != null) {
      try {
        final channel = _paymentChannels.firstWhere(
          (c) => c.code == _selectedPaymentCode,
        );
        final feeAmount =
            channel.feeFlat +
            (_selectedAmount * channel.feePercent / 100).round();
        displayTotal += _globalAdminFee + feeAmount;
      } catch (_) {}
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_selectedPaymentCode != null) ...[
              _buildCollapsiblePaymentSummary(),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _selectedPaymentCode == null
                    ? null
                    : () async {
                        // 1. Show Loading
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Memproses Pembayaran..."),
                            backgroundColor: AppColors.primary,
                            duration: Duration(seconds: 1),
                          ),
                        );

                        // 2. Auto-Cancel Pending if exists
                        if (_pendingTransaction != null) {
                          debugPrint(
                            "Auto-cancelling pending transaction: ${_pendingTransaction!.id}",
                          );
                          final cancelSuccess = await TransactionService()
                              .cancelTransaction(_pendingTransaction!.id);

                          if (!cancelSuccess) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Gagal memperbarui transaksi sebelumnya",
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                            return;
                          }
                          setState(() => _pendingTransaction = null);
                        }

                        // 3. Create New Transaction
                        final orderId =
                            "TOPUP-${DateTime.now().millisecondsSinceEpoch}";

                        // Get selected channel details
                        final channel = _paymentChannels.firstWhere(
                          (c) => c.code == _selectedPaymentCode,
                          orElse: () => _paymentChannels.first,
                        );

                        // Calculate fee
                        final baseAmount = _selectedAmount;
                        final feePercent = channel.feePercent; // double
                        final feeFlat = channel.feeFlat; // int
                        final percentFee = (baseAmount * feePercent / 100)
                            .round();
                        final paymentFee = feeFlat + percentFee;
                        final totalFee = _globalAdminFee + paymentFee;

                        debugPrint(
                          "[Payment] Base: $baseAmount, ChannelFee: $paymentFee, Global: $_globalAdminFee, TotalFee: $totalFee",
                        );

                        try {
                          // 4. Fetch Snap Token
                          final responseData = await TransactionService()
                              .getSnapToken(
                                amount: baseAmount,
                                adminFee: _globalAdminFee,
                                paymentFee: paymentFee,
                                orderId: orderId,
                                studentId: _activeSantri.id,
                                paymentType: channel.code,
                              );

                          if (responseData != null &&
                              responseData.containsKey('snap_token')) {
                            final token = responseData['snap_token'];

                            // 5. Start WebView Payment
                            if (mounted) {
                              final result = await PaymentService()
                                  .startPayment(context, token);
                              await _refreshData();

                              if (mounted && result == true) {
                                // On Web, show instruction
                                if (kIsWeb) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Jendela pembayaran dibuka. Silakan selesaikan pembayaran dan refresh halaman.",
                                      ),
                                      backgroundColor: Colors.blue,
                                      duration: Duration(seconds: 4),
                                    ),
                                  );
                                  return;
                                }

                                // Mobile: Fetch latest transaction to show receipt
                                try {
                                  final transactions =
                                      await TransactionService()
                                          .getTransactions(
                                            studentId: _activeSantri.id,
                                            page: 1,
                                          );
                                  if (transactions.isNotEmpty) {
                                    // Optional: check status?
                                    // For now, on mobile, user usually returns after finishing.
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PaymentSuccessPage(
                                          transaction: transactions.first,
                                          studentName: _activeSantri.nama,
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  debugPrint(
                                    "Error fetching latest transaction: $e",
                                  );
                                }
                              }
                            }
                          } else {
                            throw Exception(
                              "Gagal mendapatkan token pembayaran",
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  e.toString().replaceAll('Exception: ', ''),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: AppColors.primary.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Bayar Sekarang",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Rp ${(displayTotal / 1000).toInt()}k",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentChannelCard(PaymentChannel channel) {
    final bool isSelected = _selectedPaymentCode == channel.code;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => setState(() => _selectedPaymentCode = channel.code),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.05)
                : Colors.white, // Tinted background
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey.shade200,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50, // Fixed width container
                height: 50,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Icon(
                  _getChannelIcon(channel.code),
                  color: _getChannelColor(channel.code),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      channel.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600, // Reduced weight slightly
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                    // Optional: Fee info could go here
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: AppColors.primary)
              else
                Icon(Icons.circle_outlined, color: Colors.grey.shade300),
            ],
          ),
        ),
      ),
    );
  }
}

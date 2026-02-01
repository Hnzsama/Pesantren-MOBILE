import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pesantren_mobile/src/constants/app_colors.dart';
import 'package:pesantren_mobile/src/features/home/models/santri_model.dart';
import 'package:pesantren_mobile/src/features/payment/services/payment_service.dart';
import 'package:pesantren_mobile/src/features/payment/services/transaction_service.dart';
import 'package:pesantren_mobile/src/features/transactions/models/transaction_model.dart';
// WalletTopUpPage import removed
import 'package:pesantren_mobile/src/features/payment/models/payment_channel_model.dart';
import 'package:pesantren_mobile/src/features/payment/pages/payment_success_page.dart'; // Added
import 'package:intl/intl.dart';

class TransactionHistoryPage extends StatefulWidget {
  final SantriModel santri;

  const TransactionHistoryPage({super.key, required this.santri});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  final TransactionService _transactionService = TransactionService();
  final PaymentService _paymentService = PaymentService();

  late Future<List<TransactionModel>> _transactionsFuture;
  List<PaymentChannel> _paymentChannels = []; // Dynamic Channels
  int _globalAdminFee = 0; // Dynamic Global Fee
  bool _isLoadingChannels = true;

  String? _selectedStatus; // null = All, 'UNPAID', 'PAID', 'CANCELLED'

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _transactionsFuture = _transactionService.getTransactions(
        studentId: widget.santri.id,
        status: _selectedStatus,
      );
    });
    _fetchPaymentChannels();
  }

  Future<void> _fetchPaymentChannels() async {
    try {
      final data = await _transactionService.getPaymentChannels();
      if (mounted && data != null) {
        setState(() {
          _paymentChannels = data.channels;
          _globalAdminFee = data.adminFee;
          _isLoadingChannels = false;
        });
      } else {
        if (mounted) setState(() => _isLoadingChannels = false);
      }
    } catch (e) {
      debugPrint("Error fetching payment channels: $e");
      if (mounted) {
        setState(() => _isLoadingChannels = false);
      }
    }
  }

  void _onFilterChanged(String? status) {
    if (_selectedStatus != status) {
      _selectedStatus = status;
      _loadData();
    }
  }

  Future<void> _handleRetry(TransactionModel transaction) async {
    // Show Payment Selector Modal directly here for better UX
    await _showPaymentSelector(transaction);
  }

  Future<void> _showPaymentSelector(TransactionModel transaction) async {
    // If channels not loaded, try fetching again?
    if (_paymentChannels.isEmpty) {
      await _fetchPaymentChannels();
      if (_paymentChannels.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Gagal memuat metode pembayaran")),
          );
        }
        return;
      }
    }

    // Default to first channel or try to match current transaction method?
    // Since payment method codes might differ, we default to the first one available or let user choose.
    // Let's default to the first one.
    String selectedCode = _paymentChannels.first.code;
    int currentAmount = transaction.amount.toInt();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final PaymentChannel selectedChannel = _paymentChannels.firstWhere(
            (c) => c.code == selectedCode,
            orElse: () => _paymentChannels.first,
          );

          // Calculate fees dynamically
          final feeAmount =
              selectedChannel.feeFlat +
              (currentAmount * selectedChannel.feePercent / 100).round();
          final totalFee = _globalAdminFee + feeAmount;
          final totalPay = currentAmount + totalFee;

          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Pilih Metode Pembayaran",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                if (_isLoadingChannels)
                  const Center(child: CircularProgressIndicator())
                else
                  Expanded(
                    child: ListView.separated(
                      itemCount: _paymentChannels.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final channel = _paymentChannels[index];
                        final isSelected = selectedCode == channel.code;
                        return InkWell(
                          onTap: () {
                            setModalState(() {
                              selectedCode = channel.code;
                            });
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.grey.shade200,
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              color: isSelected
                                  ? AppColors.primary.withOpacity(0.05)
                                  : Colors.white,
                            ),
                            child: Row(
                              children: [
                                // Placeholder for Icon, or use image from URL if available in future
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary.withOpacity(0.1)
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.payment, // Generic icon
                                    color: isSelected
                                        ? AppColors.primary
                                        : Colors.grey,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        channel.name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle,
                                    color: AppColors.primary,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16),
                // Summary Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Nominal",
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            NumberFormat.currency(
                              locale: 'id_ID',
                              symbol: 'Rp ',
                              decimalDigits: 0,
                            ).format(currentAmount),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      if (_globalAdminFee > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Biaya Aplikasi",
                              style: TextStyle(color: Colors.grey),
                            ),
                            Text(
                              "+ Rp $_globalAdminFee",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Biaya Layanan",
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            "+ Rp $feeAmount",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total Bayar",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Rp ${NumberFormat('#,###', 'id_ID').format(totalPay)}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close modal
                      _processPayment(
                        transaction,
                        selectedChannel,
                        _globalAdminFee,
                        feeAmount,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Bayar Sekarang",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _processPayment(
    TransactionModel oldTransaction,
    PaymentChannel method,
    int adminFee,
    int paymentFee,
  ) async {
    // 1. Cancel Old Transaction
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Memperbarui transaksi...'),
        duration: Duration(seconds: 1),
      ),
    );

    await _transactionService.cancelTransaction(oldTransaction.id);

    // 2. Create New Transaction
    try {
      final orderId = "RETRY-${DateTime.now().millisecondsSinceEpoch}";
      final responseData = await _transactionService.getSnapToken(
        amount: oldTransaction.amount.toInt(),
        adminFee: adminFee,
        paymentFee: paymentFee,
        orderId: orderId,
        studentId: widget.santri.id,
        paymentType: method.code,
      );

      if (responseData != null && responseData.containsKey('snap_token')) {
        final token = responseData['snap_token'];
        if (mounted) {
          final result = await _paymentService.startPayment(context, token);
          if (result == true) {
            // On Web, show instruction
            if (kIsWeb) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Jendela pembayaran dibuka. Silakan selesaikan pembayaran dan refresh riwayat.",
                  ),
                  backgroundColor: Colors.blue,
                  duration: Duration(seconds: 4),
                ),
              );
              // Refresh immediately so user sees the new pending transaction
              _loadData();
              return;
            }

            // Fetch the new transaction to show receipt
            // Since retry creates a new transaction, we need to fetch the latest one
            try {
              // Short delay to ensure backend processes callback/creation
              await Future.delayed(const Duration(seconds: 2));
              final latestTrx = await _transactionService.getTransactions(
                studentId: widget.santri.id,
                page: 1,
              );

              if (mounted && latestTrx.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentSuccessPage(
                      transaction: latestTrx.first,
                      studentName: widget.santri.nama,
                    ),
                  ),
                );
              }
            } catch (e) {
              debugPrint("Error fetching latest transaction: $e");
            }
          }
          _loadData(); // Refresh list
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Future<void> _handleCancel(TransactionModel transaction) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Batalkan Transaksi?"),
        content: const Text(
          "Apakah Anda yakin ingin membatalkan transaksi ini?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Tidak"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "Ya, Batalkan",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _transactionService.cancelTransaction(
        transaction.id,
      );
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaksi dibatalkan'),
              backgroundColor: Colors.green,
            ),
          );
          _loadData();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal membatalkan transaksi'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

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
          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 190,
                  pinned: true,
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(32),
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
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 20,
                            left: 24,
                            right: 24,
                            bottom: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Daftar Tagihan & TopUp",
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.7,
                                            ),
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          widget.santri.nama,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  CircleAvatar(
                                    backgroundColor: Colors.white.withOpacity(
                                      0.2,
                                    ),
                                    radius: 24,
                                    child: const Icon(
                                      Icons.history,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Filter Chips
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    _buildFilterChip("Semua", null),
                                    const SizedBox(width: 8),
                                    _buildFilterChip("Menunggu", "UNPAID"),
                                    const SizedBox(width: 8),
                                    _buildFilterChip("Berhasil", "PAID"),
                                    const SizedBox(width: 8),
                                    _buildFilterChip("Gagal", "CANCELLED"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: const Text(
                    "Riwayat Transaksi",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  centerTitle: true,
                ),
              ];
            },
            body: RefreshIndicator(
              onRefresh: () async {
                _loadData();
                await _transactionsFuture;
              },
              child: FutureBuilder<List<TransactionModel>>(
                future: _transactionsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  final data = snapshot.data ?? [];

                  if (data.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return _buildTransactionCard(data[index]);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeRow(String label, int amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
          Text(
            NumberFormat.currency(
              locale: 'id_ID',
              symbol: 'Rp ',
              decimalDigits: 0,
            ).format(amount),
            style: TextStyle(fontSize: 11, color: Colors.grey.shade800),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? status) {
    final isSelected = _selectedStatus == status;
    return GestureDetector(
      onTap: () => _onFilterChanged(status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.history, size: 64, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              const Text(
                "Belum ada riwayat transaksi",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionCard(TransactionModel trx) {
    final bool isUnpaid = trx.status == 'UNPAID';
    final Color statusColor = _getStatusColor(trx.status);
    final String statusText = trx.status == 'PAID'
        ? 'Berhasil'
        : (trx.status == 'UNPAID' ? 'Menunggu' : 'Gagal');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: trx.category == 'TOPUP'
                        ? Colors.blue.shade50
                        : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    trx.category == 'TOPUP'
                        ? Icons.account_balance_wallet
                        : Icons.receipt_long,
                    color: trx.category == 'TOPUP'
                        ? Colors.blue
                        : Colors.orange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // 2. Main Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              trx.category == 'TOPUP'
                                  ? 'Isi Uang Saku'
                                  : 'Pembayaran Tagihan',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        trx.formattedDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Breakdown for TopUp with fees
                      if (trx.category == 'TOPUP' &&
                          (trx.adminFee > 0 || trx.paymentFee > 0)) ...[
                        const SizedBox(height: 8),
                        _buildFeeRow("Nominal", trx.amount.toInt()),
                        if (trx.adminFee > 0)
                          _buildFeeRow("Biaya Admin", trx.adminFee),
                        if (trx.paymentFee > 0)
                          _buildFeeRow("Biaya Layanan", trx.paymentFee),
                        Divider(
                          height: 12,
                          color: Colors.grey.withOpacity(0.2),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              trx.formattedTotalAmount,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: trx.category == 'TOPUP'
                                    ? Colors.blue
                                    : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Text(
                          trx.formattedTotalAmount,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: trx.category == 'TOPUP'
                                ? Colors.blue
                                : Colors.orange,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. Action Buttons (Only if Unpaid)
          if (isUnpaid) ...[
            Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => _handleCancel(trx),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 36),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        "Batalkan",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 24,
                    color: Colors.grey.withOpacity(0.2),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () => _handleRetry(trx),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 36),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        "Lanjut Bayar",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (trx.status == 'PAID') ...[
            Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaymentSuccessPage(
                          transaction: trx,
                          studentName: widget.santri.nama,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.print, size: 16),
                  label: const Text(
                    "Cetak Struk",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PAID':
        return Colors.green;
      case 'UNPAID':
        return Colors.orange;
      case 'CANCELLED':
      case 'EXPIRED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

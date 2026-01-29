import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pesantren_mobile/src/constants/app_colors.dart';
import 'package:pesantren_mobile/src/features/bills/models/bill_model.dart';
import 'package:pesantren_mobile/src/features/bills/service/bill_service.dart';
import 'package:pesantren_mobile/src/features/payment/services/transaction_service.dart';
import 'package:pesantren_mobile/src/features/payment/models/payment_channel_model.dart';
import 'package:pesantren_mobile/src/features/payment/services/payment_service.dart';
import 'package:pesantren_mobile/src/shared/widgets/glass_container.dart';
import 'package:pesantren_mobile/src/features/home/models/santri_model.dart';
import 'package:pesantren_mobile/src/features/bills/payment_history_page.dart';
import 'package:pesantren_mobile/src/features/transactions/models/transaction_model.dart';
import 'package:pesantren_mobile/src/features/payment/pages/payment_success_page.dart';

class BillDetailPage extends StatefulWidget {
  final StudentBill bill;
  final SantriModel? activeSantri; // Added activeSantri for navigation
  // Callback when payment is successful (to refresh list)
  final VoidCallback? onPaymentSuccess;

  const BillDetailPage({
    super.key,
    required this.bill,
    this.activeSantri,
    this.onPaymentSuccess,
  });

  @override
  State<BillDetailPage> createState() => _BillDetailPageState();
}

class _BillDetailPageState extends State<BillDetailPage> {
  final BillService _billService = BillService();
  final PaymentService _paymentService = PaymentService();
  final TransactionService _transactionService =
      TransactionService(); // Added TransactionService

  bool _isProcessing = false;
  bool _isLoadingChannels = true; // Loading state for channels

  // Dynamic Payment Data
  List<PaymentChannel> _paymentChannels = [];
  int _globalAdminFee = 0;
  String? _selectedPaymentCode; // Select by code instead of ID

  @override
  void initState() {
    super.initState();
    _fetchPaymentChannels();
  }

  Future<void> _fetchPaymentChannels() async {
    try {
      final response = await _transactionService.getPaymentChannels();
      if (mounted) {
        setState(() {
          if (response != null) {
            _paymentChannels = response.channels;
            _globalAdminFee = response.adminFee;
            // Default select the first one if available
            if (_paymentChannels.isNotEmpty) {
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

  Future<void> _handlePayment() async {
    if (_selectedPaymentCode == null) return;

    setState(() => _isProcessing = true);

    try {
      // Calculate Fees
      final selectedChannel = _paymentChannels.firstWhere(
        (c) => c.code == _selectedPaymentCode,
      );

      final baseAmount = widget.bill.amount;
      final feePercent = selectedChannel.feePercent;
      final feeFlat = selectedChannel.feeFlat;
      final percentFee = (baseAmount * feePercent / 100).round();

      // Separate fees
      final paymentFee = feeFlat + percentFee;

      final result = await _billService.payBill(
        widget.bill.id,
        paymentType: selectedChannel.code,
        adminFee: _globalAdminFee,
        paymentFee: paymentFee,
        studentId: widget.bill.studentId,
      );

      if (result.containsKey('snap_token')) {
        final token = result['snap_token'];
        if (mounted) {
          final paymentResult = await _paymentService.startPayment(
            context,
            token,
          );

          if (paymentResult == true && mounted) {
            // On Web, we can't confirm payment status immediately
            if (kIsWeb) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Jendela pembayaran dibuka. Silakan selesaikan pembayaran dan cek status secara berkala.",
                  ),
                  backgroundColor: Colors.blue,
                  duration: Duration(seconds: 4),
                ),
              );
              // Optionally refresh
              if (widget.onPaymentSuccess != null) widget.onPaymentSuccess!();
              return;
            }

            if (widget.onPaymentSuccess != null) {
              widget.onPaymentSuccess!();
            }

            // Construct TransactionModel for Receipt locally to ensure accuracy
            final transaction = TransactionModel(
              id: result['bill_id'] ?? widget.bill.id,
              invoiceCode: result['order_id'] ?? '',
              studentId: widget.bill.studentId,
              type: 'DEBIT',
              category: widget.bill.isEventBill ? 'EVENT' : 'BILL',
              amount: widget.bill.amount,
              description: widget.bill.title,
              paymentMethod: selectedChannel.name,
              status: 'PAID',
              createdAt: DateTime.now(),
              adminFee: _globalAdminFee,
              paymentFee:
                  (selectedChannel.feeFlat +
                          (widget.bill.amount *
                                  selectedChannel.feePercent /
                                  100)
                              .round())
                      .toInt(),
              eventName: widget.bill.event?.title,
              eventDate: widget.bill.event?.eventDate,
            );

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentSuccessPage(
                  transaction: transaction,
                  studentName: widget.activeSantri?.nama,
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bill = widget.bill;
    final isUnpaid = bill.status == BillStatus.UNPAID;

    // Calculate current fee for display
    int totalFee = 0;
    int channelFee = 0;
    int totalAmount = bill.amount.toInt();
    PaymentChannel? selectedChannel;

    if (_selectedPaymentCode != null && _paymentChannels.isNotEmpty) {
      try {
        selectedChannel = _paymentChannels.firstWhere(
          (c) => c.code == _selectedPaymentCode,
        );
        final baseAmount = bill.amount;
        final feePercent = selectedChannel.feePercent;
        final feeFlat = selectedChannel.feeFlat;
        final percentFee = (baseAmount * feePercent / 100).round();

        channelFee = feeFlat + percentFee;
        totalFee = _globalAdminFee + channelFee;
        totalAmount = baseAmount.toInt() + totalFee;
      } catch (e) {
        // Fallback if not found
      }
    }

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Detail Tagihan",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          if (widget.activeSantri != null)
            IconButton(
              onPressed: () {
                // Navigate to PaymentHistoryPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PaymentHistoryPage(activeSantri: widget.activeSantri!),
                  ),
                );
              },
              icon: const Icon(Icons.history, color: Colors.white),
              tooltip: "Riwayat Pembayaran",
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Bill Card Info
            GlassContainer(
              borderRadius: BorderRadius.circular(20),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.receipt_long,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      "Total Tagihan",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      bill.formattedAmount,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildDetailRow("Judul", bill.title),
                  const SizedBox(height: 12),
                  _buildDetailRow("Kategori", bill.displayLabel),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    "Jatuh Tempo",
                    DateFormat('d MMMM yyyy', 'id_ID').format(bill.dueDate),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    "Status",
                    bill.displayStatus,
                    valueColor: bill.status == BillStatus.PAID
                        ? Colors.green
                        : (bill.status == BillStatus.CANCELLED
                              ? Colors.grey
                              : Colors.orange),
                    fontWeight: FontWeight.bold,
                  ),

                  if (bill.category?.description != null &&
                      bill.category!.description!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      "Deskripsi",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bill.category!.description!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),

            if (isUnpaid) ...[
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Metode Pembayaran",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              if (_isLoadingChannels)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_paymentChannels.isEmpty)
                const Center(
                  child: Text("Tidak ada metode pembayaran tersedia"),
                )
              else
                ..._paymentChannels.map(
                  (channel) => _buildPaymentChannelCard(channel),
                ),
            ],

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: isUnpaid
          ? Container(
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
                child: SingleChildScrollView(
                  // Handling overflow
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Fee Summary
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Tagihan",
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            bill.formattedAmount,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Breakdown: Admin Fee vs Channel Fee
                      if (_globalAdminFee > 0) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Expanded(
                              child: Text(
                                "Biaya Aplikasi",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            Text(
                              "+ ${currencyFormatter.format(_globalAdminFee)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],

                      if (channelFee > 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                "Biaya Layanan (${selectedChannel?.name ?? 'Metode'})",
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "+ ${currencyFormatter.format(channelFee)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      // Optional: Breakdown Global vs Channel Fee? No, keeping it simple as "Biaya Admin"
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total Bayar",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            currencyFormatter.format(totalAmount),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      ElevatedButton(
                        onPressed:
                            (_isProcessing || _selectedPaymentCode == null)
                            ? null
                            : _handlePayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: _isProcessing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Bayar Sekarang",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }

  IconData _getChannelIcon(String code) {
    if (code == 'qris' || code == 'gopay') return Icons.qr_code_scanner;
    if (code.contains('va') || code.contains('bank'))
      return Icons.account_balance;
    if (code == 'echannel') return Icons.account_balance_wallet;
    return Icons.payment;
  }

  Color _getChannelColor(String code) {
    if (code == 'qris' || code == 'gopay') return Colors.blue;
    if (code.contains('bca')) return Colors.blue.shade800;
    if (code.contains('bsi') || code.contains('syariah')) return Colors.teal;
    if (code.contains('mandiri')) return Colors.indigo;
    return Colors.grey;
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getChannelColor(channel.code).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getChannelIcon(channel.code),
                  color: _getChannelColor(channel.code),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      channel.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Optional: Show fee info?
                    if (channel.feePercent > 0)
                      Text(
                        "Admin: ${channel.feePercent}%" +
                            (channel.feeFlat > 0
                                ? " + Rp ${channel.feeFlat}"
                                : ""),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      )
                    else
                      Text(
                        "Admin: Rp ${channel.feeFlat}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
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

  Widget _buildDetailRow(
    String label,
    String value, {
    Color? valueColor,
    FontWeight? fontWeight,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: valueColor ?? AppColors.textPrimary,
              fontSize: 14,
              fontWeight: fontWeight ?? FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

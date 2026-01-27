import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pesantren_mobile/src/constants/app_colors.dart';
import 'package:pesantren_mobile/src/features/home/models/santri_model.dart';
import 'package:pesantren_mobile/src/shared/widgets/glass_container.dart';
import 'package:pesantren_mobile/src/features/payment/services/transaction_service.dart';
import 'package:pesantren_mobile/src/features/payment/services/payment_service.dart';
import 'package:pesantren_mobile/src/features/auth/services/auth_service.dart';

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

  int _selectedPaymentMethod = 0; // 0: QRIS, 1: VA BSI, 2: VA Mandiri

  // Payment Methods with Midtrans codes and fees
  final List<Map<String, dynamic>> _paymentMethods = [
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

  @override
  void initState() {
    super.initState();
    _activeSantri = widget.activeSantri;
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
                  expandedHeight: 280, // Increased height for better spacing
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
                            // Premium Balance Card
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.15),
                                    Colors.white.withOpacity(0.05),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                ),
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
                                    "Rp ${_activeSantri.uangSaku.toInt()}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
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
                                                  size: 12,
                                                  color: AppColors.primary,
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "${_activeSantri.nama} • ${_activeSantri.kelas}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
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
                    centerTitle: true,
                    title: const Text(
                      "Isi Uang Saku",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: SingleChildScrollView(
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
                          crossAxisCount: 3, // Changed to 3 columns
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

                  _buildSectionTitle("Atau Masukkan Manual"),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _customAmountController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        prefixText: "Rp ",
                        prefixStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        hintText: "0",
                        hintStyle: TextStyle(color: Colors.grey.shade300),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  _buildSectionTitle("Metode Pembayaran"),
                  const SizedBox(height: 12),
                  // Render Payment Methods
                  ..._paymentMethods.map(
                    (method) => _buildPaymentMethodCard(method),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyBottomButton() {
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
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () async {
              // 1. Show Loading
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Memproses Pembayaran..."),
                  backgroundColor: AppColors.primary,
                  duration: Duration(seconds: 1),
                ),
              );

              // 2. Mock Order ID (Unique)
              final orderId = "TOPUP-${DateTime.now().millisecondsSinceEpoch}";

              // 3. Get selected payment method and calculate fee
              final selectedMethod = _paymentMethods[_selectedPaymentMethod];
              final paymentCode = (selectedMethod['code'] as String?) ?? 'qris';

              // Calculate fee based on payment method
              final baseAmount = _selectedAmount;
              final feePercent =
                  (selectedMethod['fee_percent'] as num?)?.toDouble() ?? 0.0;
              final feeFlat =
                  (selectedMethod['fee_flat'] as num?)?.toInt() ?? 0;
              final percentFee = (baseAmount * feePercent / 100).round();
              final totalFee = feeFlat + percentFee;
              // final totalAmount = baseAmount + totalFee; // No longer summing here for API

              print("[Payment] Base: Rp ${baseAmount}, Fee: Rp ${totalFee}");

              // 4. Fetch Snap Token with segregated amount and fee
              final responseData = await TransactionService().getSnapToken(
                amount: baseAmount, // Send only the topup nominal
                adminFee: totalFee, // Send fee separately
                orderId: orderId,
                studentId: _activeSantri.id,
                paymentType: paymentCode,
              );

              if (responseData != null &&
                  responseData.containsKey('snap_token')) {
                final token = responseData['snap_token'];
                final transactionId = responseData['transaction_id'];

                // 4. Start WebView Payment (new implementation)
                try {
                  // ignore: unused_local_variable
                  final result = await PaymentService().startPayment(
                    context,
                    token,
                  );

                  // 5. Verify Transaction Status with Backend
                  // Regardless of what webview says, we trust the backend
                  if (transactionId != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Memeriksa status pembayaran..."),
                        duration: Duration(seconds: 1),
                      ),
                    );

                    final transaction = await TransactionService()
                        .getTransactionById(transactionId);

                    // Refresh data after payment returns
                    await _refreshData();

                    if (mounted) {
                      if (transaction?.status == 'PAID') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Pembayaran BERHASIL! Saldo bertambah.",
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                        // Optional: Navigate back or clear form
                      } else if (transaction?.status == 'CANCELLED' ||
                          transaction?.status == 'EXPIRED') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Pembayaran Gagal atau Dibatalkan"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } else {
                        // UNPAID or PENDING
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Menunggu Pembayaran..."),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    }
                  } else {
                    // Fallback if no transaction_id (should not happen based on doc)
                    await _refreshData();
                  }
                } catch (e) {
                  // Show error message
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Error: ${e.toString()}"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Gagal mendapatkan token pembayaran"),
                    backgroundColor: Colors.red,
                  ),
                );
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Lanjut Pembayaran",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Rp ${(_selectedAmount / 1000).toInt()}k",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
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
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade200,
            width: isSelected ? 0 : 1,
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
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Center(
          child: Text(
            "${(amount / 1000).toInt()}k",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(Map<String, dynamic> method) {
    final bool isSelected = _selectedPaymentMethod == method['id'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => setState(() => _selectedPaymentMethod = method['id']),
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
                  color: (method['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  method['icon'] as IconData,
                  color: method['color'] as Color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method['name'] as String,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      method['desc'] as String,
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
}

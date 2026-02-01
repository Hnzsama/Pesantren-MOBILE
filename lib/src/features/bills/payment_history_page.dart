import 'package:flutter/material.dart';

import 'package:pesantren_mobile/src/constants/app_colors.dart';
import 'package:pesantren_mobile/src/features/bills/models/bill_model.dart';
import 'package:pesantren_mobile/src/features/bills/service/bill_service.dart';
import 'package:pesantren_mobile/src/features/bills/widgets/bill_card.dart';
import 'package:pesantren_mobile/src/features/home/models/santri_model.dart';
import 'package:pesantren_mobile/src/features/transactions/models/transaction_model.dart';
import 'package:pesantren_mobile/src/features/payment/pages/payment_success_page.dart';

/// Page for displaying paid bill history.
/// Filters only bills with BillStatus.PAID.
class PaymentHistoryPage extends StatefulWidget {
  final SantriModel activeSantri;
  final VoidCallback? onBack;

  const PaymentHistoryPage({
    super.key,
    required this.activeSantri,
    this.onBack,
  });

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BillService _billService = BillService();

  // State
  late Future<List<StudentBill>> _billsFuture;

  @override
  void initState() {
    super.initState();
    // 2 Tabs: General, Event
    _tabController = TabController(length: 2, vsync: this);
    _loadBills();
  }

  @override
  void didUpdateWidget(covariant PaymentHistoryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeSantri.id != widget.activeSantri.id) {
      _loadBills();
    }
  }

  void _loadBills() {
    setState(() {
      _billsFuture = _billService.getBills(widget.activeSantri.id);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Theme Constants matching Home
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Fixed Pattern Background
          Positioned.fill(
            child: Opacity(
              opacity: 0.40,
              child: Image.asset(
                'assets/background.jpeg',
                fit: BoxFit.cover,
                // No color tint
              ),
            ),
          ),

          // 2. Main Content
          FutureBuilder<List<StudentBill>>(
            future: _billsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              final allBills = snapshot.data ?? [];

              final generalBills = allBills
                  .where((b) => b.status == BillStatus.PAID && !b.isEventBill)
                  .toList();
              final eventBills = allBills
                  .where((b) => b.status == BillStatus.PAID && b.isEventBill)
                  .toList();

              generalBills.sort((a, b) => b.dueDate.compareTo(a.dueDate));
              eventBills.sort((a, b) => b.displayDate.compareTo(a.displayDate));

              return NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      expandedHeight: 250, // Matched Bills Page
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
                                top: 20, // Reduced padding
                                left: 24,
                                right: 24,
                                bottom: 60,
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
                                              "Riwayat Pembayaran",
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(
                                                  0.7,
                                                ),
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              widget.activeSantri.nama,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20, // Reduced from 22
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      CircleAvatar(
                                        backgroundColor: Colors.white
                                            .withOpacity(0.2),
                                        radius: 24,
                                        child: const Icon(
                                          Icons.history,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  // Placeholder for Balance or just spacing since no Total here
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.1),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.check_circle_outline,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Semua tagihan lunas",
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.9,
                                            ),
                                            fontWeight: FontWeight.w500,
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
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          if (widget.onBack != null) {
                            widget.onBack!();
                          } else {
                            Navigator.pop(context);
                          }
                        },
                      ),
                      title: const Text(
                        "Arsip Keuangan",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      centerTitle: true,
                      bottom: PreferredSize(
                        preferredSize: const Size.fromHeight(60),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: TabBar(
                            controller: _tabController,
                            labelColor: AppColors.accent,
                            unselectedLabelColor: Colors.white.withOpacity(0.7),
                            indicatorColor: AppColors.accent,
                            indicatorSize: TabBarIndicatorSize.label,
                            indicatorWeight: 4,
                            dividerColor: Colors.transparent,
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            tabs: const [
                              Tab(text: "RIWAYAT UMUM"),
                              Tab(text: "RIWAYAT EVENT"),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ];
                },
                body: Container(
                  // Transparent to show background
                  color: Colors.transparent,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildList(
                        generalBills,
                        "Belum ada riwayat pembayaran umum.",
                      ),
                      _buildList(
                        eventBills,
                        "Belum ada riwayat pembayaran event.",
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<StudentBill> bills, String emptyMessage) {
    if (bills.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
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
              child: const Icon(
                Icons.history_edu,
                size: 48,
                color: Color(0xFF10B981),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(
                color: Color(0xFF065F46),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bills.length,
      itemBuilder: (context, index) {
        return BillCard(
          bill: bills[index],
          onPay: () {},
          onPrint: () => _handlePrint(bills[index]),
        );
      },
    );
  }

  void _handlePrint(StudentBill bill) {
    // Map StudentBill to TransactionModel
    final transaction = TransactionModel(
      id: bill.id,
      invoiceCode: '',
      studentId: bill.studentId,
      type: 'DEBIT',
      category: bill.isEventBill ? 'EVENT' : 'BILL',
      amount: bill.amount,
      description: bill.isEventBill
          ? (bill.event?.title ?? 'Event')
          : (bill.category?.name ?? 'Tagihan'),
      paymentMethod: bill.paymentMethod ?? 'MANUAL',
      status: 'PAID',
      createdAt: bill.paidAt ?? DateTime.now(),
      adminFee: bill.adminFee,
      paymentFee: bill.paymentFee,
      eventName: bill.event?.title,
      eventDate: bill.event?.eventDate,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentSuccessPage(
          transaction: transaction,
          studentName: widget.activeSantri.nama,
        ),
      ),
    );
  }
}

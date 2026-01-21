import 'package:flutter/material.dart';

import 'package:pesantren_mobile/src/constants/app_colors.dart';
import 'package:pesantren_mobile/src/features/bills/models/bill_model.dart';
import 'package:pesantren_mobile/src/features/bills/service/bill_service.dart';
import 'package:pesantren_mobile/src/features/bills/widgets/bill_card.dart';
import 'package:pesantren_mobile/src/features/home/models/santri_model.dart';

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
    const bgEmerald50 = Color(0xFFECFDF5);

    return Scaffold(
      backgroundColor: bgEmerald50, // Match Home Background
      body: FutureBuilder<List<StudentBill>>(
        future: _billsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final allBills = snapshot.data ?? [];

          // 1. Filter: PAID Only
          // 2. Split: General vs Event
          final generalBills = allBills
              .where((b) => b.status == BillStatus.PAID && !b.isEventBill)
              .toList();
          final eventBills = allBills
              .where((b) => b.status == BillStatus.PAID && b.isEventBill)
              .toList();

          // Optional: Sort by date descending (Newest first)
          generalBills.sort((a, b) => b.dueDate.compareTo(a.dueDate));
          eventBills.sort((a, b) => b.displayDate.compareTo(a.displayDate));

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight:
                      220, // Shorter than Bills Page (No Total Amount)
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
                            top: 60,
                            left: 24,
                            right: 24,
                            bottom: 60,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Header Title & Context
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Riwayat Pembayaran",
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        widget.activeSantri.nama,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
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
                              // No Total Amount Section
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
              color: bgEmerald50,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: General History
                  _buildList(
                    generalBills,
                    "Belum ada riwayat pembayaran umum.",
                  ),

                  // Tab 2: Event History
                  _buildList(eventBills, "Belum ada riwayat pembayaran event."),
                ],
              ),
            ),
          );
        },
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
          onPay: () {
            // No Action for History
          },
        );
      },
    );
  }
}

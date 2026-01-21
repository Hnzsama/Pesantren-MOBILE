import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pesantren_mobile/src/constants/app_colors.dart';
import 'package:pesantren_mobile/src/features/bills/models/bill_model.dart';
import 'package:pesantren_mobile/src/features/bills/service/bill_service.dart';
import 'package:pesantren_mobile/src/features/bills/widgets/bill_card.dart';
import 'package:pesantren_mobile/src/features/home/models/santri_model.dart';

/// Page for displaying unpaid bills (General and Event).
/// Uses a custom SliverAppBar to match the Home design.
class BillsListPage extends StatefulWidget {
  final SantriModel activeSantri;
  final VoidCallback? onBack; // Optional custom back behavior

  const BillsListPage({super.key, required this.activeSantri, this.onBack});

  @override
  State<BillsListPage> createState() => _BillsListPageState();
}

class _BillsListPageState extends State<BillsListPage>
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
  void didUpdateWidget(covariant BillsListPage oldWidget) {
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

          // 1. Filter: Unpaid Only
          // 2. Split: General vs Event
          final generalBills = allBills
              .where((b) => b.status == BillStatus.UNPAID && !b.isEventBill)
              .toList();
          final eventBills = allBills
              .where((b) => b.status == BillStatus.UNPAID && b.isEventBill)
              .toList();

          final totalUnpaid = (generalBills + eventBills).fold<double>(
            0,
            (sum, bill) => sum + bill.amount,
          );

          final currencyFormatter = NumberFormat.currency(
            locale: 'id_ID',
            symbol: 'Rp ',
            decimalDigits: 0,
          );

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 300, // Increased to fix overflow
                  pinned: true,
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  scrolledUnderElevation:
                      0, // Prevent elevation change on scroll
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
                          // Fixed overlap by increasing bottom padding (clears TabBar)
                          padding: const EdgeInsets.only(
                            top: 60,
                            left: 24,
                            right: 24,
                            bottom:
                                70, // Increased to 70 to clear TabBar and push text up
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Santri Context
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Tagihan Aktif",
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
                                          fontSize: 22, // Slightly larger
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
                                      Icons.person,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12), // Reduced spacing
                              // Total Summary
                              Text(
                                "Total Kewajiban",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currencyFormatter.format(totalUnpaid),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28, // Reduced from 36
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Courier',
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
                    "Rincian Keuangan",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  centerTitle: true,
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(
                      60,
                    ), // Increased to fit tabs comfortably
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: AppColors.accent,
                        unselectedLabelColor: Colors.white.withOpacity(0.7),
                        indicatorColor: AppColors.accent,
                        indicatorSize: TabBarIndicatorSize.label,
                        indicatorWeight: 4,
                        dividerColor:
                            Colors.transparent, // Remove the unwanted line
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        tabs: const [
                          Tab(text: "TAGIHAN UMUM"),
                          Tab(text: "TAGIHAN EVENT"),
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
                  // Tab 1: General Bills
                  _buildList(generalBills, "Belum ada tagihan umum."),

                  // Tab 2: Event Bills
                  _buildList(eventBills, "Belum ada tagihan event."),
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
                Icons.assignment_turned_in_outlined,
                size: 48,
                color: Color(0xFF10B981),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(
                color: Color(0xFF065F46), // textEmerald800
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Bayar tagihan: ${bills[index].title}")),
            );
          },
        );
      },
    );
  }
}

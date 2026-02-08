import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pesantren_mobile/src/constants/app_colors.dart';
import 'package:pesantren_mobile/src/features/bills/models/bill_model.dart';
import 'package:pesantren_mobile/src/features/bills/service/bill_service.dart';
import 'package:pesantren_mobile/src/features/bills/widgets/bill_card.dart';
import 'package:pesantren_mobile/src/features/bills/payment_history_page.dart';
import 'package:pesantren_mobile/src/features/bills/bill_detail_page.dart';
import 'package:pesantren_mobile/src/features/home/models/santri_model.dart';
import 'package:pesantren_mobile/src/shared/utils/error_handler.dart';

/// Page for displaying unpaid bills (General and Event).
/// Uses a custom SliverAppBar to match the Home design.
class BillsListPage extends StatefulWidget {
  final SantriModel activeSantri;
  final VoidCallback? onBack; // Optional custom back behavior
  final VoidCallback? onViewHistory;

  const BillsListPage({
    super.key,
    required this.activeSantri,
    this.onBack,
    this.onViewHistory,
  });

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
    return Scaffold(
      backgroundColor: Colors.white, // Changed from bgEmerald50
      body: Stack(
        children: [
          // 1. Fixed Pattern Background
          Positioned.fill(
            child: Opacity(
              opacity: 0.40, // More visible pattern
              child: Image.asset(
                'assets/background.jpeg',
                fit: BoxFit.cover,
                // Removed color tint to match Home Page white/silhouette style
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
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          ErrorHandler.getErrorMessage(snapshot.error),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadBills,
                          child: const Text("Coba Lagi"),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final allBills = snapshot.data ?? [];

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
                      expandedHeight: 260, // Reduced from 280
                      pinned: true,
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      scrolledUnderElevation: 0,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(32),
                        ),
                      ),
                      actions: [
                        IconButton(
                          onPressed: () {
                            _loadBills();
                          },
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          tooltip: "Refresh Data",
                        ),
                      ],
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
                                top: 20, // Reduced from 60
                                left: 24,
                                right: 24,
                                bottom: 70,
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
                                              "Tagihan Aktif",
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
                                          Icons.person,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "Total Kewajiban",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Typography Update: Matched BalanceSection
                                  Text(
                                    currencyFormatter
                                        .format(totalUnpaid)
                                        .replaceAll(
                                          'Rp ',
                                          'Rp ',
                                        ), // Formatting tweak if needed
                                    style: const TextStyle(
                                      fontSize: 28, // Reduced from 30
                                      fontWeight: FontWeight.w800, // Extra bold
                                      color: Colors.white,
                                      letterSpacing: -1.0, // Tighter spacing
                                      shadows: [
                                        Shadow(
                                          color: Colors.black26,
                                          offset: Offset(0, 4),
                                          blurRadius: 10,
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
                        "Rincian Keuangan",
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
                              Tab(text: "TAGIHAN UMUM"),
                              Tab(text: "TAGIHAN EVENT"),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildList(generalBills, "Belum ada tagihan umum."),
                    _buildList(eventBills, "Belum ada tagihan event."),
                  ],
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
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: 400,
          child: Center(
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
                    color: Color(0xFF065F46),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 200,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      if (widget.onViewHistory != null) {
                        widget.onViewHistory!();
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentHistoryPage(
                              activeSantri: widget.activeSantri,
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      "Riwayat Tagihan",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: bills.length + 1, // +1 for the button
      separatorBuilder: (context, index) {
        if (index == bills.length - 1) {
          return const SizedBox(height: 24); // Before button
        }
        return const SizedBox(height: 16);
      },
      itemBuilder: (context, index) {
        if (index == bills.length) {
          // Last item: button
          return Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    if (widget.onViewHistory != null) {
                      widget.onViewHistory!();
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentHistoryPage(
                            activeSantri: widget.activeSantri,
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    "Riwayat Tagihan",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          );
        }

        // Regular bill card
        return BillCard(
          bill: bills[index],
          onPay: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BillDetailPage(
                  bill: bills[index],
                  activeSantri: widget.activeSantri,
                  onPaymentSuccess: () {
                    // Refresh current list if payment was successful
                    _loadBills();
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

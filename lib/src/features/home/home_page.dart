import 'package:flutter/material.dart';
import 'package:pesantren_mobile/src/constants/app_colors.dart';
import 'package:pesantren_mobile/src/features/home/models/santri_model.dart';
import 'package:pesantren_mobile/src/features/home/widgets/home_widgets.dart';
import 'package:pesantren_mobile/src/features/home/widgets/new_home_widgets.dart';
import 'package:pesantren_mobile/src/features/achievements/achievements_page.dart';
import 'package:pesantren_mobile/src/features/bills/bills_list_page.dart';
import 'package:pesantren_mobile/src/features/reports/student_report_page.dart';
import 'package:pesantren_mobile/src/features/activities/activities_page.dart';
import 'package:pesantren_mobile/src/features/kajian/kajian_page.dart';
import 'package:pesantren_mobile/src/features/bills/payment_history_page.dart';
import 'package:pesantren_mobile/src/features/transactions/shopping_history_page.dart';
import 'package:pesantren_mobile/src/features/profile/profile_page.dart';
import 'package:pesantren_mobile/src/features/permissions/permissions_page.dart';
import 'package:pesantren_mobile/src/features/wallet/wallet_topup_page.dart';

// ... existing imports ...
import 'package:pesantren_mobile/src/shared/widgets/glass_bottom_nav.dart';
import 'package:pesantren_mobile/src/shared/widgets/glass_container.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // State Management
  late SantriModel _activeSantri;
  bool _isLoadingContent = false;
  int _navIndex = 0;

  // Navigation State
  bool _showPaymentHistory = false;
  Widget? _currentHomeSubPage;

  @override
  void initState() {
    super.initState();
    // Initialize with first mock data
    _activeSantri = MockData.santriList.first;
    _loadContent(); // Simulate fetching content
  }

  Future<void> _loadContent() async {
    setState(() => _isLoadingContent = true);
    await Future.delayed(const Duration(seconds: 1)); // Mock API delay
    if (mounted) setState(() => _isLoadingContent = false);
  }

  void _switchSantri(SantriModel santri) {
    setState(() {
      _activeSantri = santri;
    });
    Navigator.pop(context); // Close bottom sheet
    _loadContent(); // Refresh content for new santri

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Beralih ke profil: ${santri.nama}")),
    );
  }

  void _showSantriSwitcher() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Pilih Santri",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...MockData.santriList.map(
                (santri) => ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(santri.nama),
                  subtitle: Text(santri.kelas),
                  trailing: _activeSantri.id == santri.id
                      ? const Icon(Icons.check_circle, color: AppColors.primary)
                      : null,
                  onTap: () => _switchSantri(santri),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showAllMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                  child: Opacity(
                    opacity: 0.40,
                    child: Image.asset(
                      'assets/background.jpeg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  const SizedBox(height: 16),
                  // Gripper
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Semua Menu",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 4,
                      mainAxisSpacing: 24,
                      crossAxisSpacing: 12,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        MenuIcon(
                          label: "Rapor",
                          icon: Icons.school,
                          backgroundColor: const Color(0xFFF3E5F5),
                          iconColor: const Color(0xFF9C27B0),
                          onTap: () {
                            Navigator.pop(context);
                            _navigateTo(
                              StudentReportPage(
                                activeSantri: _activeSantri,
                                onBack: () =>
                                    setState(() => _currentHomeSubPage = null),
                              ),
                            );
                          },
                        ),
                        MenuIcon(
                          label: "Prestasi",
                          icon: Icons.emoji_events,
                          backgroundColor: const Color(0xFFFFF3E0),
                          iconColor: const Color(0xFFFF9800),
                          onTap: () {
                            Navigator.pop(context);
                            _navigateTo(
                              AchievementsPage(
                                activeSantri: _activeSantri,
                                onBack: () =>
                                    setState(() => _currentHomeSubPage = null),
                              ),
                            );
                          },
                        ),
                        MenuIcon(
                          label: "Tagihan",
                          icon: Icons.receipt_long,
                          backgroundColor: const Color(0xFFE8F5E9),
                          iconColor: const Color(0xFF4CAF50),
                          onTap: () {
                            Navigator.pop(context);
                            setState(() => _navIndex = 2); // Go to Bills Tab
                          },
                        ),
                        MenuIcon(
                          label: "Riwayat",
                          icon: Icons.history,
                          backgroundColor: const Color(0xFFE3F2FD),
                          iconColor: const Color(0xFF2196F3),
                          onTap: () {
                            Navigator.pop(context);
                            setState(() {
                              _navIndex = 2;
                              _showPaymentHistory = true;
                            });
                          },
                        ),
                        MenuIcon(
                          label: "Perizinan",
                          icon: Icons.mail_outline,
                          backgroundColor: const Color(0xFFFCE4EC), // Pink 50
                          iconColor: const Color(0xFFE91E63), // Pink
                          onTap: () {
                            Navigator.pop(context);
                            _navigateTo(
                              PermissionsPage(
                                activeSantri: _activeSantri,
                                onBack: () =>
                                    setState(() => _currentHomeSubPage = null),
                              ),
                            );
                          },
                        ),
                        MenuIcon(
                          label: "Jadwal",
                          icon: Icons.calendar_today,
                          backgroundColor: const Color(0xFFE0F2F1),
                          iconColor: const Color(0xFF009688),
                          onTap: () {
                            Navigator.pop(context);
                            _navigateTo(
                              ActivitiesPage(
                                onBack: () =>
                                    setState(() => _currentHomeSubPage = null),
                              ),
                            );
                          },
                        ),
                        MenuIcon(
                          label: "Kajian",
                          icon: Icons.menu_book,
                          backgroundColor: const Color(0xFFFFEBEE), // Red 50
                          iconColor: const Color(0xFFF44336), // Red
                          onTap: () {
                            Navigator.pop(context);
                            _navigateTo(
                              KajianPage(
                                onBack: () =>
                                    setState(() => _currentHomeSubPage = null),
                              ),
                            );
                          },
                        ),
                        MenuIcon(
                          label: "Uang Saku",
                          icon: Icons.account_balance_wallet,
                          backgroundColor: const Color(0xFFE0F7FA), // Cyan 50
                          iconColor: const Color(0xFF00BCD4), // Cyan
                          onTap: () {
                            Navigator.pop(context);
                            _navigateTo(
                              WalletTopUpPage(
                                activeSantri: _activeSantri,
                                onBack: () =>
                                    setState(() => _currentHomeSubPage = null),
                              ),
                            );
                          },
                        ),
                        MenuIcon(
                          label: "Berita",
                          icon: Icons.newspaper,
                          backgroundColor: const Color(0xFFE8EAF6),
                          iconColor: const Color(0xFF3F51B5),
                          onTap: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Menu Berita akan segera hadir"),
                              ),
                            );
                          },
                        ),
                        MenuIcon(
                          label: "Tutup",
                          icon: Icons.close,
                          backgroundColor: Colors.grey[100]!,
                          iconColor: Colors.grey[600]!,
                          onTap: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        if (_navIndex == 0 && _currentHomeSubPage != null) {
          setState(() => _currentHomeSubPage = null); // Back to Dashboard
          return;
        }

        if (_navIndex == 2 && _showPaymentHistory) {
          setState(() => _showPaymentHistory = false); // Back to Bills List
          return;
        }

        // If at root of tabs, allow exit or move to home tab?
        // Standard: if not at home tab, go to home tab.
        if (_navIndex != 0) {
          setState(() => _navIndex = 0);
          return;
        }

        // If at home tab root, exit app
        if (context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        extendBody: true,
        bottomNavigationBar: GlassBottomNav(
          selectedIndex: _navIndex,
          onItemTapped: (index) {
            setState(() => _navIndex = index);
          },
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_navIndex == 1) {
      return ActivitiesPage(onBack: () => setState(() => _navIndex = 0));
    }

    if (_navIndex == 2) {
      return _showPaymentHistory
          ? PaymentHistoryPage(
              activeSantri: _activeSantri,
              onBack: () => setState(() => _showPaymentHistory = false),
            )
          : BillsListPage(
              activeSantri: _activeSantri,
              onViewHistory: () => setState(() => _showPaymentHistory = true),
              onBack: () => setState(() => _navIndex = 0),
            );
    }

    if (_navIndex == 3) {
      return ProfilePage(
        activeSantri: _activeSantri,
        onBack: () => setState(() => _navIndex = 0),
      );
    }

    if (_currentHomeSubPage != null) {
      return _currentHomeSubPage!;
    }

    // Dashboard
    return Stack(
      children: [
        // 1. Fixed Background Gradient (Top Layer)
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primaryDark,
                Color(0xFF003300), // Slightly darker green
              ],
            ),
          ),
        ),

        // Pattern Overlay
        Positioned(
          top: 0,
          right: 0,
          left: 0,
          height: 400,
          child: Opacity(
            opacity: 0.1,
            child: Image.asset(
              'assets/background.jpeg', // Corrected asset path
              fit: BoxFit.cover,
              color: Colors.white, // Tint white for dark bg
            ),
          ),
        ),

        SafeArea(
          bottom: false, // Allow white container to extend behind bottom nav
          child: Column(
            children: [
              // === TOP SECTION (Fixed Height roughly) ===
              const HomeGreeting(),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: BalanceSection(balance: _activeSantri.uangSaku),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    margin: const EdgeInsets.only(right: 20),
                    child: Material(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        onTap: () => _navigateTo(
                          WalletTopUpPage(
                            activeSantri: _activeSantri,
                            onBack: () =>
                                setState(() => _currentHomeSubPage = null),
                          ),
                        ),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // === BOTTOM SECTION (Expanded Floating Panel) ===
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                    // Removed large shadow for cleaner look
                  ),
                  child: Stack(
                    children: [
                      // Background Silhouette (Subtle)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(32),
                          ),
                          child: Opacity(
                            opacity: 0.40,
                            child: Image.asset(
                              'assets/background.jpeg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                      // Content
                      SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 30, 20, 100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Menu Grid
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 4,
                              mainAxisSpacing: 16, // Reduced spacing
                              crossAxisSpacing: 12,
                              padding: EdgeInsets.zero,
                              children: [
                                MenuIcon(
                                  label: "Rapor",
                                  icon: Icons.school,
                                  backgroundColor: const Color(
                                    0xFFF3E5F5,
                                  ), // Purple 50
                                  iconColor: const Color(0xFF9C27B0), // Purple
                                  onTap: () => _navigateTo(
                                    StudentReportPage(
                                      activeSantri: _activeSantri,
                                      onBack: () => setState(
                                        () => _currentHomeSubPage = null,
                                      ),
                                    ),
                                  ),
                                ),
                                MenuIcon(
                                  label: "Prestasi",
                                  icon: Icons.emoji_events,
                                  backgroundColor: const Color(
                                    0xFFFFF3E0,
                                  ), // Orange 50
                                  iconColor: const Color(0xFFFF9800), // Orange
                                  onTap: () => _navigateTo(
                                    AchievementsPage(
                                      activeSantri: _activeSantri,
                                      onBack: () => setState(
                                        () => _currentHomeSubPage = null,
                                      ),
                                    ),
                                  ),
                                ),
                                MenuIcon(
                                  label: "Kajian",
                                  icon: Icons.menu_book,
                                  backgroundColor: const Color(
                                    0xFFFFEBEE,
                                  ), // Red 50
                                  iconColor: const Color(0xFFF44336), // Red
                                  onTap: () => _navigateTo(
                                    KajianPage(
                                      onBack: () => setState(
                                        () => _currentHomeSubPage = null,
                                      ),
                                    ),
                                  ),
                                ),
                                MenuIcon(
                                  label: "Lainnya",
                                  icon: Icons.grid_view,
                                  backgroundColor: const Color(
                                    0xFFE3F2FD,
                                  ), // Blue 50
                                  iconColor: const Color(0xFF2196F3), // Blue
                                  onTap: _showAllMenu,
                                ),
                              ],
                            ),

                            const SizedBox(height: 20), // Tighter
                            // 2. Student Card (Floating)
                            // Wrapped in Container to control height if needed
                            SantriCardCarousel(
                              santriList: MockData.santriList,
                              activeSantri: _activeSantri,
                              onSantriChanged: (santri) {
                                if (_activeSantri.id != santri.id) {
                                  setState(() => _activeSantri = santri);
                                  _loadContent();
                                }
                              },
                              onSwitchTap: _showSantriSwitcher,
                            ),

                            const SizedBox(height: 24),

                            // 3. Transaction History (New)
                            Row(
                              children: [
                                const Icon(
                                  Icons.receipt_long,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "Riwayat Belanja",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () => _navigateTo(
                                    ShoppingHistoryPage(
                                      activeSantri: _activeSantri,
                                      onBack: () => setState(
                                        () => _currentHomeSubPage = null,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    "Lihat Semua",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary.withOpacity(0.8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildTransactionList(),

                            const SizedBox(height: 24),

                            // 4. News Section (New)
                            Row(
                              children: [
                                const Icon(
                                  Icons.newspaper,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "Informasi Pesantren",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildNewsSection(),

                            const SizedBox(height: 100), // Bottom cushion
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _navigateTo(Widget page) {
    setState(() => _currentHomeSubPage = page);
  }

  Widget _buildTransactionList() {
    final transactions = [
      {
        'title': 'Kantin Santri',
        'date': 'Today, 10:00',
        'amount': -15000,
        'icon': Icons.fastfood,
        'color': Colors.orange,
      },
      {
        'title': 'Koperasi Buku',
        'date': 'Yesterday, 14:30',
        'amount': -45000,
        'icon': Icons.menu_book,
        'color': Colors.blue,
      },
      {
        'title': 'Laundry',
        'date': '22 Jan, 08:00',
        'amount': -20000,
        'icon': Icons.local_laundry_service,
        'color': Colors.teal,
      },
    ];

    return Column(
      children: transactions.map((tx) {
        final amount = tx['amount'] as int;
        final isExpense = amount < 0;

        return GlassContainer(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(20),
          width: double.infinity,
          height: null,
          opacity: 0.8,
          shadows: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          child: Row(
            children: [
              // Icon Container
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (tx['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16), // Rounded square
                ),
                child: Icon(
                  tx['icon'] as IconData,
                  color: tx['color'] as Color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx['title'] as String,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tx['date'] as String,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Amount
              Text(
                "Rp ${amount.abs()}",
                style: TextStyle(
                  color: isExpense
                      ? const Color(0xFFFF5252) // Softer Red
                      : const Color(0xFF43A047), // Natural Green
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNewsSection() {
    final news = [
      {
        'title': 'Penerimaan Santri Baru 2026/2027',
        'desc': 'Gelombang 1 telah dibuka. Segera daftarkan putra-putri Anda.',
        'color': Colors.blue,
        'icon': Icons.app_registration,
        'date': '2 Hari lalu',
      },
      {
        'title': 'Kajian Akbar Bulanan',
        'desc': 'Bersama KH. Ahmad Dahlan di Masjid Utama.',
        'color': Colors.green,
        'icon': Icons.mosque,
        'date': '5 Hari lalu',
      },
    ];

    return SizedBox(
      height: 120, // Reduced height
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        itemCount: news.length,
        separatorBuilder: (c, i) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final item = news[index];
          final color = item['color'] as Color;

          return GlassContainer(
            width: 280,
            padding: const EdgeInsets.all(12),
            borderRadius: BorderRadius.circular(24),
            opacity: 0.8,
            shadows: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
            child: Row(
              children: [
                // Gradient Icon Container
                Container(
                  width: 60, // Reduced size
                  height: 60, // Reduced size
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      colors: [color.withOpacity(0.1), color.withOpacity(0.25)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Icon(item['icon'] as IconData, color: color, size: 32),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "PENGUMUMAN",
                          style: TextStyle(
                            fontSize: 9,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['title'] as String,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          height: 1.2,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['date'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

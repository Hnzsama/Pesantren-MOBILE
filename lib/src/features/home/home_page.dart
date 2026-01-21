import 'package:flutter/material.dart';
import 'package:pesantren_mobile/src/constants/app_colors.dart';
import 'package:pesantren_mobile/src/features/home/models/santri_model.dart';
import 'package:pesantren_mobile/src/features/home/widgets/home_widgets.dart';
import 'package:pesantren_mobile/src/features/bills/bills_list_page.dart';
import 'package:pesantren_mobile/src/features/bills/payment_history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // State Management
  late SantriModel _activeSantri;
  bool _isLoadingContent = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 1. Header with Switcher
          SantriHeader(
            santriList: MockData.santriList,
            activeSantri: _activeSantri,
            onSantriChanged: (santri) {
              // Avoid redundant rebuilds if the santri is the same
              if (_activeSantri.id != santri.id) {
                // We don't perform a full "switch" (which closes modal/shows snackbar)
                // Just update the active santri state quietly for the swipe
                setState(() => _activeSantri = santri);
                _loadContent();
              }
            },
            onSwitchTap: _showSantriSwitcher,
          ),

          // Wrapped in Expanded to take remaining space
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.05, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: SingleChildScrollView(
                // Key forces the widget to be replaced (and thus animated) when santri changes
                key: ValueKey<String>(_activeSantri.id),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // 2. Quick Stats Cards
                    SizedBox(
                      height: 140,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: [
                          DashboardCard(
                            title: "Kehadiran",
                            value: "${_activeSantri.kehadiranPercentage}%",
                            subtitle: _activeSantri.kehadiranStatus,
                            icon: Icons.access_time_filled,
                            iconColor: _activeSantri.kehadiranStatus == 'Sakit'
                                ? Colors.orange
                                : AppColors.primary,
                          ),
                          const SizedBox(width: 16),
                          DashboardCard(
                            title: "Uang Saku",
                            value: "Rp ${_activeSantri.uangSaku.toInt()}",
                            subtitle: "Saldo Aktif",
                            icon: Icons.account_balance_wallet,
                            iconColor: AppColors.accentDark,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 3. Main Menu
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "Menu Utama",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: [
                        MenuIcon(
                          label: "Rapor",
                          icon: Icons.school,
                          onTap: () {},
                        ),
                        MenuIcon(
                          label: "Prestasi",
                          icon: Icons.emoji_events,
                          onTap: () {},
                        ),
                        MenuIcon(
                          label: "Tagihan",
                          icon: Icons.receipt_long,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    BillsListPage(activeSantri: _activeSantri),
                              ),
                            );
                          },
                        ),
                        MenuIcon(
                          label: "Riwayat",
                          icon: Icons.history,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PaymentHistoryPage(
                                  activeSantri: _activeSantri,
                                ),
                              ),
                            );
                          },
                        ),
                        MenuIcon(
                          label: "Perizinan",
                          icon: Icons.mail_outline,
                          onTap: () {},
                        ),
                        MenuIcon(
                          label: "Jadwal",
                          icon: Icons.calendar_today,
                          onTap: () {},
                        ),
                        MenuIcon(
                          label: "Kajian",
                          icon: Icons.menu_book,
                          onTap: () {},
                        ),
                        MenuIcon(
                          label: "Lainnya",
                          icon: Icons.grid_view,
                          onTap: () {},
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 4. Information Section
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "Informasi Terbaru",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _isLoadingContent
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : _buildInfoList(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 2,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.image, color: Colors.grey),
            ),
            title: Text(
              index == 0
                  ? "Pengumuman Libur Semester"
                  : "Jadwal Kajian Bulanan",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: const Text(
              "20 Januari 2026",
              style: TextStyle(fontSize: 12),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          ),
        );
      },
    );
  }
}

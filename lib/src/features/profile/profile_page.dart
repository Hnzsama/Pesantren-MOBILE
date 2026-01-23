import 'package:flutter/material.dart';
import 'package:pesantren_mobile/src/constants/app_colors.dart';
import 'package:pesantren_mobile/src/features/home/models/santri_model.dart';
import 'package:pesantren_mobile/src/shared/widgets/glass_container.dart';

class ProfilePage extends StatelessWidget {
  final SantriModel activeSantri;
  final VoidCallback? onBack; // Standardized back callback

  const ProfilePage({super.key, required this.activeSantri, this.onBack});

  @override
  Widget build(BuildContext context) {
    // Mock Data based on Schema
    final mockParent = {
      'name': 'H. Abdullah',
      'relation': 'Ayah Kandung',
      'phone': '+62 812-3456-7890',
      'email': 'abdullah@example.com',
    };

    final mockSchool = {
      'name': 'Pondok Pesantren Al-Hidayah',
      'address': 'Jl. Raya Pesantren No. 123, Kota Santri',
      'phone': '(021) 1234567',
    };

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
                  expandedHeight: 330,
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            // Profile Avatar
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.2),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 45,
                                backgroundColor: Colors.white,
                                backgroundImage: activeSantri.photoUrl != null
                                    ? NetworkImage(activeSantri.photoUrl!)
                                    : null,
                                child: activeSantri.photoUrl == null
                                    ? const Icon(
                                        Icons.person,
                                        size: 45,
                                        color: AppColors.primary,
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Name & Class
                            Text(
                              activeSantri.nama,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                "${activeSantri.kelas} • ${activeSantri.id.padLeft(4, '0')}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Header Stats
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildHeaderStat(
                                  "Sisa Saldo",
                                  "Rp ${(activeSantri.uangSaku / 1000).toStringAsFixed(0)}rb",
                                ),
                                Container(
                                  height: 30,
                                  width: 1,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                  color: Colors.white.withOpacity(0.3),
                                ),
                                _buildHeaderStat(
                                  "Limit Harian",
                                  "Rp ${(activeSantri.dailyCashLimit / 1000).toStringAsFixed(0)}rb",
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // No leading back button if it's a main tab, but defined just in case
                  leading: onBack != null
                      ? IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: onBack,
                        )
                      : null,
                  title: const Text(
                    "Profil Santri",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  centerTitle: true,
                ),
              ];
            },
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // SECTION: Status Akademik (Students Table)
                  _buildSectionTitle("Status Akademik"),
                  const SizedBox(height: 12),
                  GlassContainer(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    borderRadius: BorderRadius.circular(24),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          Icons.verified_user,
                          "Status",
                          "AKTIF",
                          valueColor: const Color(0xFF10B981),
                        ),
                        const Divider(height: 24, thickness: 0.5),
                        _buildInfoRow(
                          Icons.school,
                          "Jenjang",
                          "Madrasah Aliayah",
                        ),
                        const Divider(height: 24, thickness: 0.5),
                        _buildInfoRow(
                          Icons.date_range,
                          "Tahun Masuk",
                          "2023/2024",
                        ),
                        const Divider(height: 24, thickness: 0.5),
                        _buildInfoRow(
                          Icons.account_balance_wallet,
                          "Sisa Uang Saku",
                          "Rp ${activeSantri.uangSaku}",
                          valueColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // SECTION: Wali Santri (Users Table)
                  _buildSectionTitle("Data Wali Santri"),
                  const SizedBox(height: 12),
                  GlassContainer(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    borderRadius: BorderRadius.circular(24),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          Icons.person_outline,
                          "Nama Wali",
                          mockParent['name']!,
                        ),
                        const Divider(height: 24, thickness: 0.5),
                        _buildInfoRow(
                          Icons.people_outline,
                          "Hubungan",
                          "Ayah Kandung",
                        ),
                        const Divider(height: 24, thickness: 0.5),
                        _buildInfoRow(
                          Icons.phone_android,
                          "Nomor HP",
                          mockParent['phone']!,
                        ),
                        const Divider(height: 24, thickness: 0.5),
                        _buildInfoRow(
                          Icons.email_outlined,
                          "Email",
                          mockParent['email']!,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // SECTION: Sekolah (Schools Table)
                  _buildSectionTitle("Informasi Sekolah"),
                  const SizedBox(height: 12),
                  GlassContainer(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    borderRadius: BorderRadius.circular(24),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          Icons.location_city,
                          "Nama Sekolah",
                          mockSchool['name']!,
                        ),
                        const Divider(height: 24, thickness: 0.5),
                        _buildInfoRow(
                          Icons.map,
                          "Alamat",
                          mockSchool['address']!,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // SECTION: Pengaturan Keuangan (Financial Settings)
                  _buildSectionTitle("Pengaturan Keuangan"),
                  const SizedBox(height: 12),
                  GlassContainer(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    borderRadius: BorderRadius.circular(24),
                    child: Column(
                      children: [
                        _buildSettingsRow(
                          context,
                          icon: Icons.savings_outlined,
                          title: "Limit Harian",
                          value: "Rp ${activeSantri.dailyCashLimit.toInt()}",
                          onTap: () => _showLimitDialog(context),
                        ),
                        const Divider(height: 24, thickness: 0.5),
                        _buildSettingsRow(
                          context,
                          icon: Icons.password,
                          title: "PIN Kartu",
                          value: activeSantri.walletPin != null
                              ? "****** (Diatur)"
                              : "Belum Diatur",
                          onTap: () => _showPinDialog(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // LOGOUT BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Logout pressed")),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFEBEE), // Red 50
                        foregroundColor: const Color(0xFFD32F2F), // Red 700
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout),
                          SizedBox(width: 12),
                          Text(
                            "Keluar Aplikasi",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  const Text(
                    "Versi Aplikasi v1.0.0",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
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

  Widget _buildHeaderStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
    int maxLines = 1,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  color: valueColor ?? AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.orange, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  void _showLimitDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            const SizedBox(height: 20),
            const Text(
              "Atur Limit Harian",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Batas maksimal jajan santri per hari menggunakan Smart Card.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            TextField(
              decoration: InputDecoration(
                labelText: "Nominal Limit (Rp)",
                prefixText: "Rp ",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              keyboardType: TextInputType.number,
              controller: TextEditingController(
                text: "${activeSantri.dailyCashLimit.toInt()}",
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Limit harian berhasil disimpan"),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text("Simpan Perubahan"),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showPinDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(height: 20),
              const Text(
                "Ubah PIN Kartu",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "PIN digunakan untuk konfirmasi pembayaran di kantin.",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "PIN Baru (6 Digit)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("PIN berhasil diperbarui")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text("Simpan PIN Baru"),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

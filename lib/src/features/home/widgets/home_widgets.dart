import 'package:flutter/material.dart';
import 'package:pesantren_mobile/src/constants/app_colors.dart';
import 'package:pesantren_mobile/src/features/home/models/santri_model.dart';

class SantriHeader extends StatelessWidget {
  final SantriModel santri;
  final VoidCallback onSwitchTap;

  const SantriHeader({
    super.key,
    required this.santri,
    required this.onSwitchTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Assalamualaikum,",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Wali Santri",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              CircleAvatar(
                backgroundColor: AppColors.accent,
                radius: 20,
                child: const Icon(Icons.person, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Santri Card
          StudentIdCard(santri: santri, onSwitchTap: onSwitchTap),
        ],
      ),
    );
  }
}

class StudentIdCard extends StatelessWidget {
  final SantriModel santri;
  final VoidCallback onSwitchTap;

  const StudentIdCard({
    super.key,
    required this.santri,
    required this.onSwitchTap,
  });

  @override
  Widget build(BuildContext context) {
    // Colors from HTML/Tailwind config
    const bgEmerald50 = Color(0xFFECFDF5);
    const bgEmerald100 = Color(0xFFD1FAE5);
    const textEmerald800 = Color(0xFF065F46);
    const textEmerald600 = Color(0xFF059669);
    const textEmerald500 = Color(0xFF10B981); // Adjusted for visibility
    const textEmerald700 = Color(0xFF047857);

    return Container(
      width: double.infinity,
      height: 240, // Increased height to prevent overflow with larger logo
      decoration: BoxDecoration(
        color: bgEmerald50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bgEmerald50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background Decorations
          Positioned.fill(
            child: Stack(
              children: [
                // Middle Accent (Skewed)
                Positioned(
                  top: 0,
                  right: 80, // Approximate percentage
                  bottom: 0,
                  width: 60,
                  child: Transform(
                    transform: Matrix4.skewX(-0.2), // -12 deg approx
                    child: Container(color: bgEmerald100.withOpacity(0.6)),
                  ),
                ),
                // Right Layer (Cover)
                Positioned(
                  top: 0,
                  right: -40,
                  bottom: 0,
                  width: 150,
                  child: Transform(
                    transform: Matrix4.skewX(-0.2),
                    child: Container(color: bgEmerald50),
                  ),
                ),
                // Glassy Line
                Positioned(
                  top: 0,
                  right: 80,
                  bottom: 0,
                  width: 1,
                  child: Transform(
                    transform: Matrix4.skewX(-0.2),
                    child: Container(color: Colors.white.withOpacity(0.4)),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // LEFT COLUMN: Photo and NIS
                Column(
                  children: [
                    // Photo Container
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(
                          width: 88,
                          height: 108,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFF9FAFB), Color(0xFFF3F4F6)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: santri.photoUrl != null
                              ? Image.network(
                                  santri.photoUrl!,
                                  fit: BoxFit.cover,
                                )
                              : Center(
                                  child: Text(
                                    santri.nama.isNotEmpty
                                        ? santri.nama[0].toUpperCase()
                                        : "?",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                        ),
                        // NIS Badge (Floating)
                        Transform.translate(
                          offset: const Offset(0, 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: bgEmerald100.withOpacity(0.8),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                            child: Text(
                              "123456", // Todo: Add NIS to model or use placeholder
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: textEmerald700,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Footer
                    Column(
                      children: [
                        Text(
                          "KARTU TANDA SANTRI",
                          style: TextStyle(
                            fontSize: 7,
                            fontWeight: FontWeight.bold,
                            color: textEmerald800.withOpacity(0.6),
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          "Berlaku selama menjadi santri",
                          style: TextStyle(
                            fontSize: 6,
                            color: textEmerald600.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // RIGHT COLUMN: Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "KARTU SANTRI",
                                style: TextStyle(
                                  color: textEmerald800,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  letterSpacing: 0.5,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                "PONDOK PESANTREN",
                                style: TextStyle(
                                  color: textEmerald500,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                          // Logo Asset
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: Image.asset(
                              'assets/logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8), // Tightened spacing
                      // Data Fields
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("NAMA LENGKAP"),
                          Text(
                            santri.nama,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF111827), // Gray-900
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4), // Reduced spacing
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel("JENJANG"),
                                    Text(
                                      santri
                                          .kelas, // Using kelas as jenjang placeholder
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel("JENIS KELAMIN"),
                                    Text(
                                      santri.jenisKelamin,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Spacer(), // Push barcode to bottom
                      const SizedBox(height: 8), // Tightened bottom spacing
                      // Barcode & Ganti Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Barcode visual (Full width simulation)
                          Expanded(
                            child: SizedBox(
                              height: 32, // Slightly reduced
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: List.generate(36, (index) {
                                  // Randomize bar width slightly for realism
                                  final isThick =
                                      (index * 7 + 3) % 4 == 0 ||
                                      index % 5 == 0;
                                  return Container(
                                    width: isThick ? 2.5 : 1,
                                    height: 32,
                                    margin: EdgeInsets.symmetric(
                                      horizontal: isThick ? 1.5 : 1,
                                    ),
                                    color: Colors.black87,
                                  );
                                }),
                              ),
                            ),
                          ),
                          // Ganti Button
                          InkWell(
                            onTap: onSwitchTap,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: const Row(
                                children: [
                                  Text(
                                    "Ganti",
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 14,
                                    color: AppColors.primary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
          ),
          const Spacer(),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 11,
                color: (iconColor ?? AppColors.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class MenuIcon extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const MenuIcon({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

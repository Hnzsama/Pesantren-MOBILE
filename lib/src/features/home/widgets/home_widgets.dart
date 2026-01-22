import 'package:flutter/material.dart';
import 'package:pesantren_mobile/src/constants/app_colors.dart';
import 'package:pesantren_mobile/src/features/home/models/santri_model.dart';
import 'package:pesantren_mobile/src/shared/animations/scale_button.dart';

class SantriHeader extends StatefulWidget {
  final List<SantriModel> santriList;
  final SantriModel activeSantri;
  final ValueChanged<SantriModel> onSantriChanged;
  final VoidCallback onSwitchTap;

  const SantriHeader({
    super.key,
    required this.santriList,
    required this.activeSantri,
    required this.onSantriChanged,
    required this.onSwitchTap,
  });

  @override
  State<SantriHeader> createState() => _SantriHeaderState();
}

class _SantriHeaderState extends State<SantriHeader> {
  late PageController _pageController;
  // Track scroll position to animate stacking
  double _currentPage = 0.0;

  @override
  void initState() {
    super.initState();
    final initialIndex = widget.santriList.indexWhere(
      (s) => s.id == widget.activeSantri.id,
    );
    _currentPage = (initialIndex != -1 ? initialIndex : 0).toDouble();
    _pageController =
        PageController(
          initialPage: initialIndex != -1 ? initialIndex : 0,
          viewportFraction: 0.85,
        )..addListener(() {
          setState(() {
            _currentPage = _pageController.page ?? 0.0;
          });
        });
  }

  @override
  void didUpdateWidget(SantriHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeSantri.id != widget.activeSantri.id) {
      final index = widget.santriList.indexWhere(
        (s) => s.id == widget.activeSantri.id,
      );
      if (index != -1 && _pageController.hasClients) {
        if (_pageController.page?.round() != index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 20),
      // Extend background to cover the stacked cards if needed,
      // but simpler to just let them overflow if clipped correctly.
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
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
                    const Text(
                      "Wali Santri",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  radius: 22,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Stacked Card Carousel
          SizedBox(
            height: 220,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.santriList.length,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) {
                widget.onSantriChanged(widget.santriList[index]);
              },
              itemBuilder: (context, index) {
                // Determine transform based on position relative to current page
                double relativePosition = index - _currentPage;

                // Center zoom effect
                double scale = (1 - (relativePosition.abs() * 0.2)).clamp(
                  0.85,
                  1.0,
                );

                return Center(
                  child: Transform.scale(
                    scale: Curves.easeOut.transform(scale),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: StudentIdCard(
                        santri: widget.santriList[index],
                        onSwitchTap: widget.onSwitchTap,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Page Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.santriList.length, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage.round() == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage.round() == index
                      ? Colors.white
                      : Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
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
    // Keep original emerald colors
    const bgEmerald50 = Color(0xFFECFDF5);
    const bgEmerald100 = Color(0xFFD1FAE5);
    const textEmerald800 = Color(0xFF065F46); // Dark Green Text
    const textEmerald600 = Color(0xFF059669);

    // Simulate "Credit Card" Layout
    // ISO/IEC 7810 ID-1 standard: 85.60 × 53.98 mm
    // Aspect Ratio: 8.56 / 5.398 ≈ 1.585
    return AspectRatio(
      aspectRatio: 85.60 / 53.98,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: bgEmerald50,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Background Pattern (Waves)
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: bgEmerald100.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -30,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: bgEmerald100.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Card Content
            Padding(
              padding: const EdgeInsets.all(20.0), // Reduced from 24
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header: Logo Left, Badge Right
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Small Logo
                      Image.asset('assets/logo.png', width: 60, height: 60),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "PESANTREN ID",
                              style: TextStyle(
                                color: textEmerald800,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            Text(
                              "Kartu Tanda Santri Elektronik",
                              style: TextStyle(
                                color: textEmerald600,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // "Active" Badge or similar
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 4),
                          ],
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.verified, size: 14, color: Colors.blue),
                            SizedBox(width: 4),
                            Text(
                              "Active",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // 2. Big Number (Like Credit Card)
                  // Minimized size/spacing to fit 1 line
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "1000  4633  3308  ${santri.id.padLeft(4, '0')}",
                      style: const TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 18, // Reduced from 22
                        fontWeight: FontWeight.bold,
                        color: textEmerald800,
                        letterSpacing: 1.5, // Reduced from 2.0
                        shadows: [
                          Shadow(
                            blurRadius: 1,
                            color: Colors.white,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  // 3. Bottom Info: Name & School
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "NAMA SANTRI",
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: textEmerald600,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            santri.nama.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: textEmerald800,
                            ),
                          ),
                          Text(
                            santri.kelas,
                            style: const TextStyle(
                              fontSize: 12,
                              color: textEmerald600,
                            ),
                          ),
                        ],
                      ),
                      // QR/Barcode Icon (Larger)
                      Icon(
                        Icons.qr_code_2,
                        size: 64, // Increased from 40
                        color: textEmerald800.withOpacity(0.8),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ... (existing imports)

// ... (SantriHeader and other widgets remain unchanged)

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
    // Wrap with ScaleButton for feedback, even though it's not clickable by default in the mockup
    // If it's intended to be clickable, we add onTap.
    // Assuming these cards might be clickable later for details.
    return ScaleButton(
      onTap: () {
        // Placeholder for future navigation
      },
      child: Container(
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
              child: Icon(
                icon,
                color: iconColor ?? AppColors.primary,
                size: 20,
              ),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
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
      ),
    );
  }
}

class MenuIcon extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? iconColor;

  const MenuIcon({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleButton(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12), // Reduced padding slightly
            decoration: BoxDecoration(
              color: backgroundColor ?? AppColors.background,
              borderRadius: BorderRadius.circular(
                16,
              ), // Rounded square/squircle
            ),
            child: Icon(icon, color: iconColor ?? AppColors.primary, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class InfoSlider extends StatefulWidget {
  const InfoSlider({super.key});

  @override
  State<InfoSlider> createState() => _InfoSliderState();
}

class _InfoSliderState extends State<InfoSlider> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  // Mock Data
  final List<Map<String, dynamic>> _infoList = [
    {
      "title": "Penerimaan Santri Baru",
      "desc": "Gelombang 1 Tahun Ajaran 2026/2027 telah dibuka.",
      "color": Colors.blue,
      "icon": Icons.school,
    },
    {
      "title": "Kajian Bulanan",
      "desc": "Bersama KH. Ahmad Dahlan, Sabtu ini di Masjid Utama.",
      "color": Colors.green,
      "icon": Icons.mosque,
    },
    {
      "title": "Jaga Kesehatan",
      "desc": "Cuaca sedang tidak menentu, jangan lupa minum vitamin.",
      "color": Colors.orange,
      "icon": Icons.health_and_safety,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Auto-slide every 5 seconds
    Future.delayed(const Duration(seconds: 5), _autoSlide);
  }

  void _autoSlide() {
    if (!mounted) return;
    if (_controller.hasClients) {
      final nextPage = (_currentIndex + 1) % _infoList.length;
      _controller.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
    Future.delayed(const Duration(seconds: 5), _autoSlide);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 100, // Compact height
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemCount: _infoList.length,
            itemBuilder: (context, index) {
              final info = _infoList[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (info['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (info['color'] as Color).withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (info['color'] as Color).withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(info['icon'], color: info['color']),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            info['title'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            info['desc'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
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
        ),
        const SizedBox(height: 8),
        // Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_infoList.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentIndex == index ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentIndex == index
                    ? AppColors.primary
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

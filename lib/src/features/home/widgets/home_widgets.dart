import 'package:flutter/material.dart';
import 'package:pesantren_mobile/src/constants/app_colors.dart';
import 'package:pesantren_mobile/src/features/home/models/santri_model.dart';
import 'package:pesantren_mobile/src/features/home/models/student_card_model.dart';
import 'package:pesantren_mobile/src/shared/animations/scale_button.dart';
import 'package:pesantren_mobile/src/shared/widgets/glass_container.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
      padding: const EdgeInsets.only(
        top: 40,
        bottom: 16,
      ), // Reduced padding (was 50, 20)
      // Extend background to cover the stacked cards if needed,
      // but simpler to just let them overflow if clipped correctly.
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
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
            height: 190, // Reduced height (was 220)
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

class StudentIdCardLegacy extends StatelessWidget {
  final SantriModel santri;
  final VoidCallback onSwitchTap;

  const StudentIdCardLegacy({
    super.key,
    required this.santri,
    required this.onSwitchTap,
  });

  @override
  Widget build(BuildContext context) {
    // Premium Green Palette
    const accentGreen = Color(0xFF43A047);
    const textDark = Color(0xFF1B5E20);

    // ISO/IEC 7810 ID-1 aspect ratio
    return AspectRatio(
      aspectRatio: 85.60 / 53.98,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          // 3D Volume Effect: Stronger Gradient + Border Bevel
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              const Color(0xFFE8F5E9),
              const Color(0xFFA5D6A7), // Darker end for volume
            ],
            stops: const [0.0, 0.45, 1.0],
          ),
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        child: Stack(
          children: [
            // Depth/Texture Pattern
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.4),
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Content Container
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo with 3D touch
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/logo_sandigi.png',
                          width: 42,
                          height: 42,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "PESANTREN ID",
                              style: TextStyle(
                                color: textDark,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            Text(
                              "Kartu Tanda Santri Elektronik",
                              style: TextStyle(
                                color: accentGreen,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Active Badge (Pill)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.blueAccent, Colors.blue],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_user,
                              size: 10,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4),
                            Text(
                              "Active",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // CARD NUMBER
                  Text(
                    "1000  4633  3308  8899",
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                      letterSpacing: 2.2,
                      shadows: [
                        Shadow(
                          color: Colors.white.withOpacity(0.8),
                          offset: const Offset(1, 1),
                          blurRadius: 1,
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // FOOTER INFO
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "NAMA SANTRI",
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: accentGreen.withOpacity(0.8),
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            santri.nama.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: textDark,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                "KELAS ${santri.kelas.split(' ').first}",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: textDark.withOpacity(0.7),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: accentGreen,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                santri.departmentCode,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: textDark.withOpacity(0.7),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // QR Code
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(Icons.qr_code_2, size: 44, color: textDark),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Optional: Slight Gloss Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white.withOpacity(0.1), Colors.transparent],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StudentIdCard extends StatelessWidget {
  final SantriModel santri;
  final StudentCardModel? card; // Added
  final VoidCallback onSwitchTap;

  const StudentIdCard({
    super.key,
    required this.santri,
    this.card, // Added
    required this.onSwitchTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine if card is active (printed)
    final bool isPrinted = card?.status == 'printed';

    // ISO/IEC 7810 ID-1 aspect ratio
    Widget cardContent = AspectRatio(
      aspectRatio: 85.60 / 53.98,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // 1. Background Gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                ),
              ),

              // 2. Geometric Shapes (Curves)
              CustomPaint(
                size: Size.infinite,
                painter: CardBackgroundPainter(),
              ),

              // 3. Content (Responsive)
              LayoutBuilder(
                builder: (context, constraints) {
                  final h = constraints.maxHeight;
                  final w = constraints.maxWidth;

                  // Scale factors
                  final double padding =
                      w * 0.035; // Reduced Padding (Requested)
                  final double logoSize = h * 0.18; // Smaller Logo (Requested)
                  final double rightLogoSize =
                      logoSize; // Symmetric (Requested)

                  final double headerSize = h * 0.09;
                  final double subHeaderSize = h * 0.05;
                  final double numSize = h * 0.08;
                  final double qrSize = h * 0.25;

                  final String nisDisplay = santri.nis ?? santri.id;

                  // Theme Colors (Dark Teal Theme)
                  const Color textDark = Colors.white; // White for dark bg
                  const Color textMuted = Colors.white70; // White 70%

                  return Padding(
                    padding: EdgeInsets.fromLTRB(
                      padding,
                      padding * 0.8,
                      padding,
                      padding,
                    ), // Reduced top padding
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // ROW 1: Header (Left: Sandigi/App, Right: School/Dynamic)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment
                              .center, // Ensure vertical center alignment
                          children: [
                            // LEFT: Logo + School Name (App/Provider)
                            Row(
                              children: [
                                SizedBox(
                                  height: logoSize,
                                  width: logoSize, // Keep aspect ratio
                                  child: Image.asset(
                                    'assets/logo_sandigi.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                SizedBox(width: w * 0.02),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min, // Compact
                                  children: [
                                    Text(
                                      "PONDOK PESANTREN",
                                      style: TextStyle(
                                        color: textMuted,
                                        fontSize: subHeaderSize * 0.7,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      "SANDIGI",
                                      style: TextStyle(
                                        color: textDark,
                                        fontSize: subHeaderSize * 1.2,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // RIGHT: Dynamic School Logo (from JSON)
                            // If logoPath exists, show it. Otherwise fallback to BankSyariah style or similar.
                            if (santri.school?.logoPath != null)
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "PONDOK PESANTREN",
                                        style: TextStyle(
                                          color: textMuted,
                                          fontSize: subHeaderSize * 0.7,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Container(
                                        constraints: BoxConstraints(
                                          maxWidth: w * 0.35,
                                        ), // Limit width to prevent overflow
                                        child: Text(
                                          santri.school?.name ?? "SEKOLAH",
                                          style: TextStyle(
                                            color: textDark,
                                            fontSize: subHeaderSize * 1.2,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                          textAlign: TextAlign.right,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: w * 0.02),
                                  Container(
                                    height: rightLogoSize,
                                    width: rightLogoSize,
                                    alignment: Alignment.centerRight,
                                    child: Image.network(
                                      santri.school!.logoPath!,
                                      fit: BoxFit.contain,
                                      errorBuilder: (ctx, _, __) => Icon(
                                        Icons.broken_image,
                                        color: textMuted,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            else
                              // Fallback (BankSyariah)
                              Row(
                                children: [
                                  Icon(
                                    Icons.account_balance,
                                    color: textMuted,
                                    size: rightLogoSize * 0.8,
                                  ),
                                  SizedBox(width: w * 0.01),
                                  Text(
                                    "BankSyariah",
                                    style: TextStyle(
                                      color: textMuted,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic,
                                      fontSize: rightLogoSize * 0.5,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),

                        const Spacer(
                          flex: 3,
                        ), // Push Center Content Down slightly
                        // ROW 2: "KARTU SANTRI" (Centered)
                        Text(
                          "KARTU SANTRI",
                          style: TextStyle(
                            color: textMuted.withOpacity(
                              0.8,
                            ), // Dark Muted Green
                            fontSize:
                                subHeaderSize *
                                1.3, // Increased size (Requested)
                            letterSpacing: 3.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        SizedBox(height: h * 0.01),

                        // ROW 3: Card Number
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            (card?.cardNumber ?? "XXXX  XXXX  XXXX  XXXX")
                                .replaceAllMapped(
                                  RegExp(r".{4}"),
                                  (match) => "${match.group(0)} ",
                                ),
                            style: TextStyle(
                              fontFamily: 'Courier',
                              fontSize:
                                  numSize * 1.1, // Reduced size (Requested)
                              color: textDark, // Dark Green
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.white.withOpacity(
                                    0.5,
                                  ), // Light shadow for depth
                                  offset: const Offset(1, 1),
                                  blurRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const Spacer(flex: 4), // Push Bottom Content Down
                        // ROW 4: Bottom Info
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // QR Code (Dynamic)
                            Container(
                              padding: const EdgeInsets.all(2),
                              color: Colors.white,
                              width: qrSize,
                              height: qrSize,
                              child: Center(
                                child: QrImageView(
                                  data: card?.cardNumber ?? nisDisplay,
                                  version: QrVersions.auto,
                                  size: qrSize * 0.9,
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ),

                            SizedBox(width: w * 0.03),

                            // Name and NIS (Bottom Left)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      santri.nama.toUpperCase(),
                                      style: TextStyle(
                                        color: textDark, // Updated to Dark Text
                                        fontSize: subHeaderSize * 1.2,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "NIS $nisDisplay",
                                    style: TextStyle(
                                      color: textMuted, // Updated to Muted Text
                                      fontSize: subHeaderSize * 0.9,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Valid Thru (Bottom Right)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "Valid Thru",
                                  style: TextStyle(
                                    color: textMuted, // Updated to Muted Text
                                    fontSize: subHeaderSize * 0.7,
                                  ),
                                ),
                                Text(
                                  "18/30",
                                  style: TextStyle(
                                    color: textDark, // Updated to Dark Text
                                    fontSize: subHeaderSize * 1.2,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: h * 0.01),
                                Icon(
                                  Icons.flutter_dash,
                                  color: Colors.redAccent.withOpacity(0.8),
                                  size: headerSize,
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Raise elements slightly from bottom
                        SizedBox(height: h * 0.02),
                      ],
                    ),
                  );
                },
              ),

              // Status Overlay for non-printed cards
              if (!isPrinted)
                Container(
                  color: Colors.black.withOpacity(0.1),
                  alignment: Alignment.center,
                ),
            ],
          ),
        ),
      ),
    );

    if (!isPrinted) {
      return ColorFiltered(
        colorFilter: const ColorFilter.matrix(
          [
            0.2126,
            0.7152,
            0.0722,
            0,
            0,
            0.2126,
            0.7152,
            0.0722,
            0,
            0,
            0.2126,
            0.7152,
            0.0722,
            0,
            0,
            0,
            0,
            0,
            1,
            0,
          ], // Grayscale filter
        ),
        child: Opacity(opacity: 0.8, child: cardContent),
      );
    }

    return cardContent;
  }
}

// Custom Painter for the background curves
class CardBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
          .withOpacity(0.3) // Subtle white overlay
      ..style = PaintingStyle.fill;

    // 1. Top Right Large Circle/Oval
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.1),
      size.width * 0.5,
      paint,
    );

    // 2. Bottom Left Large Circle/Oval
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.9),
      size.width * 0.45,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
      child: GlassContainer(
        width: double.infinity, // Fill available width (Expanded)
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(20),
        blur: 10,
        opacity: 0.95, // Almost opaque for "card" feel
        shadows: [
          // Glow effect matching the icon color
          BoxShadow(
            color: (iconColor ?? AppColors.primary).withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
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
            width: 52, // Slightly reduced
            height: 52,
            decoration: BoxDecoration(
              color:
                  backgroundColor?.withOpacity(0.9) ??
                  AppColors.background, // Less transparent
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.black.withOpacity(0.05),
                width: 1,
              ), // Subtle border
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2), // Light shadow
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                icon,
                color: iconColor ?? AppColors.primary,
                size: 26,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color:
                  AppColors.textPrimary, // Dark text for visibility on white bg
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
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
          height: 120, // Increased height to prevent clipping
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

import 'package:flutter/material.dart';
import 'package:pesantren_mobile/src/constants/app_colors.dart';
import 'package:pesantren_mobile/src/features/home/models/santri_model.dart';
import 'package:pesantren_mobile/src/features/home/models/student_card_model.dart';
import 'package:pesantren_mobile/src/features/home/widgets/home_widgets.dart';

class HomeGreeting extends StatelessWidget {
  final String parentName;

  const HomeGreeting({super.key, this.parentName = "Wali Santri"});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Assalamualaikum,",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  parentName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: const CircleAvatar(
              backgroundColor: Colors.white24,
              radius: 22,
              child: Icon(Icons.notifications_outlined, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class BalanceSection extends StatefulWidget {
  final double balance;

  const BalanceSection({super.key, required this.balance});

  @override
  State<BalanceSection> createState() => _BalanceSectionState();
}

class _BalanceSectionState extends State<BalanceSection> {
  bool _isHidden = false;

  void _toggleHide() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _isHidden
                    ? "Rp ••••••••"
                    : "Rp ${widget.balance.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                style: const TextStyle(
                  fontSize: 28, // Reduced size
                  fontWeight: FontWeight.w800, // Extra bold
                  color: Colors.white,
                  letterSpacing: -0.5, // Tighter spacing
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
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _toggleHide,
            child: Row(
              mainAxisSize:
                  MainAxisSize.min, // Only take necessary width for tap
              children: [
                Icon(
                  _isHidden
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.white70,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  "Saldo Uang Saku",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.8),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SantriCardCarousel extends StatefulWidget {
  final List<SantriModel> santriList;
  final SantriModel activeSantri;
  final Map<String, StudentCardModel> studentCards; // Added
  final ValueChanged<SantriModel> onSantriChanged;
  final VoidCallback onSwitchTap;

  const SantriCardCarousel({
    super.key,
    required this.santriList,
    required this.activeSantri,
    this.studentCards = const {}, // Added default empty
    required this.onSantriChanged,
    required this.onSwitchTap,
  });

  @override
  State<SantriCardCarousel> createState() => _SantriCardCarouselState();
}

class _SantriCardCarouselState extends State<SantriCardCarousel> {
  late PageController _pageController;
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
          viewportFraction: 1.0, // Full width to align with menu grid edges
        )..addListener(() {
          if (mounted) {
            setState(() {
              _currentPage = _pageController.page ?? 0.0;
            });
          }
        });
  }

  @override
  void didUpdateWidget(SantriCardCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeSantri.id != widget.activeSantri.id) {
      final index = widget.santriList.indexWhere(
        (s) => s.id == widget.activeSantri.id,
      );
      if (index != -1 && _pageController.hasClients) {
        if ((_pageController.page ?? 0).round() != index) {
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
    return Column(
      children: [
        SizedBox(
          height: 240, // Increased height to allow AspectRatio to expand width
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.santriList.length,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              widget.onSantriChanged(widget.santriList[index]);
            },
            itemBuilder: (context, index) {
              double relativePosition = index - _currentPage;
              double scale = (1 - (relativePosition.abs() * 0.2)).clamp(
                0.85,
                1.0,
              );
              return Center(
                child: Transform.scale(
                  scale: Curves.easeOut.transform(scale),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0.0,
                    ), // Removed inner padding for better alignment
                    child: StudentIdCard(
                      santri: widget.santriList[index],
                      card: widget.studentCards[widget.santriList[index].id],
                      onSwitchTap: widget.onSwitchTap,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.santriList.length, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage.round() == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage.round() == index
                      ? AppColors.primary
                      : AppColors.primary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

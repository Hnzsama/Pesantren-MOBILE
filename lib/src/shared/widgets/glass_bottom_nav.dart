import 'package:flutter/material.dart';
import 'package:pesantren_mobile/src/shared/widgets/glass_container.dart';
import 'package:pesantren_mobile/src/constants/app_colors.dart';

class GlassBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const GlassBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Increased bottom padding to 30 to raise it up ("kurang naik")
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
      // Ensure the bottom nav floats above everything
      child: GlassContainer(
        height: 60, // Reduced from 70 ("terlalu besar")
        borderRadius: BorderRadius.circular(30),
        blur: 15,
        opacity: 0.9,
        color: Colors.white,
        shadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.home_filled, "Home", 0),
            _buildNavItem(Icons.assignment, "Akademik", 1),
            _buildNavItem(Icons.chat_bubble, "Pesan", 2),
            _buildNavItem(Icons.person, "Profil", 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.grey.shade400,
              size: 24, // Reduced from 26
            ),
          ],
        ),
      ),
    );
  }
}

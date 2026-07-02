import 'package:flutter/material.dart';
import 'package:hey_hood/core/constants/app_colors.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: darkBg,
        border: Border(
          top: BorderSide(
            color: Color(0xFF1F1F1F),
            width: 1,
          ),
        ),
      ),
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_filled, "Hood"),
            _buildNavItem(1, Icons.explore_outlined, "Explore"),
            _buildCenterAddButton(context),
            _buildNavItem(3, Icons.notifications_none_outlined, "Alerts"),
            _buildNavItem(4, Icons.people_outline, "KYH"),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = currentIndex == index;
    final color = isSelected ? saffron : muted;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: AnimatedScale(
          scale: isSelected ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterAddButton(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () => onTap(2),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(
            color: saffron,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x3FFF9933),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.add,
            color: Colors.black,
            size: 28,
          ),
        ),
      ),
    );
  }
}

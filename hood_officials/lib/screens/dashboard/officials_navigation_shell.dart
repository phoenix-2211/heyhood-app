import 'package:flutter/material.dart';
import 'package:hood_officials/core/constants/app_colors.dart';
import 'package:hood_officials/core/widgets/bottom_nav_officials.dart';
import 'package:hood_officials/screens/dashboard/officials_dashboard_screen.dart';
import 'package:hood_officials/screens/alerts/officials_alerts_screen.dart';
import 'package:hood_officials/screens/post/officials_post_container.dart';

class OfficialsNavigationShell extends StatefulWidget {
  const OfficialsNavigationShell({super.key});

  @override
  State<OfficialsNavigationShell> createState() => _OfficialsNavigationShellState();
}

class _OfficialsNavigationShellState extends State<OfficialsNavigationShell> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      OfficialsDashboardScreen(
        onAlertsSelected: () {
          setState(() {
            _currentIndex = 2;
          });
        },
      ),
      const SizedBox.shrink(), // Placeholder for center button action
      const OfficialsAlertsScreen(),
    ];
  }

  void _onTabSelected(int index) {
    if (index == 1) {
      _showPostSheet();
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _showPostSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        clipBehavior: Clip.antiAlias,
        child: const OfficialsPostContainer(initialTab: 0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex == 1 ? 0 : _currentIndex, // Safe fallback
            children: _pages,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomNavOfficials(
              currentIndex: _currentIndex,
              onTap: _onTabSelected,
            ),
          ),
        ],
      ),
    );
  }
}

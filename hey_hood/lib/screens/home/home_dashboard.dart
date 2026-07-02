import 'package:flutter/material.dart';
import 'package:hey_hood/core/widgets/bottom_nav_bar.dart';
import 'package:hey_hood/screens/home/hood_home_screen.dart';
import 'package:hey_hood/screens/explore/explore_screen.dart';
import 'package:hey_hood/screens/alerts/alerts_screen.dart';
import 'package:hey_hood/screens/kyh/kyh_screen.dart';
import 'package:hey_hood/screens/report/report_issue_modal.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HoodHomeScreen(),
    const ExploreScreen(),
    const SizedBox.shrink(), // Placeholder for center button action
    const AlertsScreen(),
    const KyhScreen(),
  ];

  void _onTabSelected(int index) {
    if (index == 2) {
      _showReportIssueModal();
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _showReportIssueModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ReportIssueModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex == 2 ? 0 : _currentIndex, // Safe fallback
            children: _pages,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomNavBar(
              currentIndex: _currentIndex,
              onTap: _onTabSelected,
            ),
          ),
        ],
      ),
    );
  }
}

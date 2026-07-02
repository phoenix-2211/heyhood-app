import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hood_officials/core/constants/app_colors.dart';
import 'package:hood_officials/screens/post/resolve_issue_screen.dart';

class OfficialsAlertsScreen extends StatefulWidget {
  const OfficialsAlertsScreen({super.key});

  @override
  State<OfficialsAlertsScreen> createState() => _OfficialsAlertsScreenState();
}

class _OfficialsAlertsScreenState extends State<OfficialsAlertsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Escalations', 'Deadlines', 'New Issues', 'Messages'];

  // Mock notifications list
  List<Map<String, dynamic>> get _notifications {
    final list = [
      {
        'id': '1',
        'type': 'New Issues',
        'title': 'New Issue Assigned',
        'time': '2m ago',
        'desc': 'Sewage overflow reported at 4th Block Adyar. Immediate inspection required due to high traffic area.',
        'ticket': 'ISSUE-40921',
        'icon': Icons.assignment,
        'borderColor': saffron,
        'iconColor': saffron,
        'actionLabel': 'Accept',
        'isToday': true,
      },
      {
        'id': '2',
        'type': 'Deadlines',
        'title': 'Deadline in 18 hours',
        'time': '45m ago',
        'desc': 'Pothole repair on 80 Feet Road must be resolved by tomorrow morning to avoid weekend congestion penalties.',
        'icon': Icons.schedule,
        'borderColor': amber,
        'iconColor': amber,
        'actionLabel': 'Resolve Now',
        'secondaryActionLabel': 'Extend',
        'isToday': true,
      },
      {
        'id': '3',
        'type': 'Escalations',
        'title': 'Issue Escalated to You',
        'time': '2h ago',
        'desc': 'Streetlight failure in Ward 170 was unresolved for >48h. Citizens have started a public petition.',
        'icon': Icons.arrow_upward,
        'borderColor': danger,
        'iconColor': danger,
        'actionLabel': 'View Issue',
        'isToday': true,
      },
      {
        'id': '4',
        'type': 'Other',
        'title': 'Accountability Score Updated',
        'time': '4h ago',
        'desc': 'Your score dropped from 71 to 64 due to two overdue pending tasks in the sanitation department.',
        'icon': Icons.shield,
        'borderColor': amber,
        'iconColor': amber,
        'badgeLabel': 'Score: 64',
        'isToday': true,
      },
      {
        'id': '5',
        'type': 'Messages',
        'title': 'Message from District Collector',
        'time': '5h ago',
        'desc': 'Please prioritize the water supply issue in the HSR layout region before the evening meeting.',
        'icon': Icons.chat_bubble,
        'borderColor': green,
        'iconColor': green,
        'actionLabel': 'Reply',
        'isToday': true,
      },
      {
        'id': '6',
        'type': 'Other',
        'title': 'Resolution Verified',
        'time': '6h ago',
        'desc': 'Residents confirmed your resolution for the park maintenance request. Excellent work.',
        'icon': Icons.check_circle,
        'borderColor': green,
        'iconColor': green,
        'badgeLabel': 'Score: 69 ↑',
        'isToday': true,
      },
      // Yesterday Section
      {
        'id': '7',
        'type': 'Other',
        'title': 'Weekly Performance Summary',
        'desc': 'Your weekly summary is now available for review. 12 issues resolved.',
        'icon': Icons.description,
        'isToday': false,
      },
      {
        'id': '8',
        'type': 'Other',
        'title': 'System Maintenance',
        'desc': 'The Hood Officials portal will be offline for maintenance from 02:00 to 04:00 AM.',
        'icon': Icons.settings,
        'isToday': false,
      },
    ];

    if (_selectedFilter == 'All') return list;
    return list.where((item) => item['type'] == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final todayAlerts = _notifications.where((n) => n['isToday'] == true).toList();
    final yesterdayAlerts = _notifications.where((n) => n['isToday'] == false).toList();

    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        backgroundColor: lightBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Alerts',
          style: GoogleFonts.hankenGrotesk(
            color: navy,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All alerts marked read')),
              );
            },
            child: Text(
              'Mark all read',
              style: GoogleFonts.hankenGrotesk(
                color: saffron,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Horizontal scrollable filter pills
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE5E2E1))),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(
                      filter,
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : navy,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      }
                    },
                    selectedColor: saffron,
                    backgroundColor: lightSurface,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide.none,
                    ),
                  ),
                );
              },
            ),
          ),

          // 2. Alert Notification Cards
          Expanded(
            child: _notifications.isEmpty
                ? Center(
                    child: Text(
                      'No notifications found',
                      style: GoogleFonts.hankenGrotesk(color: muted),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    children: [
                      if (todayAlerts.isNotEmpty) ...[
                        Text(
                          'Today',
                          style: GoogleFonts.hankenGrotesk(
                            color: muted,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...todayAlerts.map((n) => _buildAlertCard(n)),
                        const SizedBox(height: 24),
                      ],
                      if (yesterdayAlerts.isNotEmpty) ...[
                        Text(
                          'Yesterday',
                          style: GoogleFonts.hankenGrotesk(
                            color: muted,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Opacity(
                          opacity: 0.7,
                          child: Column(
                            children: yesterdayAlerts.map((n) => _buildAlertCard(n)).toList(),
                          ),
                        ),
                      ],
                      const SizedBox(height: 80), // spacer for bottom nav bar
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> data) {
    final hasActions = data['actionLabel'] != null;
    final hasSecondaryAction = data['secondaryActionLabel'] != null;
    final hasBadge = data['badgeLabel'] != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: lightBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E2E1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left color border strip
              if (data['borderColor'] != null)
                Container(
                  width: 4,
                  color: data['borderColor'] as Color,
                ),
              
              // Main content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Alert Icon
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: (data['iconColor'] as Color? ?? navy).withOpacity(0.1),
                        child: Icon(
                          data['icon'] as IconData,
                          color: data['iconColor'] as Color? ?? navy,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Text block
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    data['title'] as String,
                                    style: GoogleFonts.hankenGrotesk(
                                      color: navy,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (data['time'] != null)
                                  Text(
                                    data['time'] as String,
                                    style: GoogleFonts.hankenGrotesk(
                                      color: muted,
                                      fontSize: 10,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data['desc'] as String,
                              style: GoogleFonts.hankenGrotesk(
                                color: muted,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                            
                            // Bottom row (Actions, badges, ticket IDs)
                            if (hasActions || hasBadge || data['ticket'] != null) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  if (data['ticket'] != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: lightSurface,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        data['ticket'] as String,
                                        style: GoogleFonts.hankenGrotesk(
                                          color: navy,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  
                                  if (hasBadge)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: (data['iconColor'] as Color? ?? saffron).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        data['badgeLabel'] as String,
                                        style: GoogleFonts.hankenGrotesk(
                                          color: data['iconColor'] as Color? ?? saffron,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),

                                  if (hasActions) ...[
                                    if (data['ticket'] != null || hasBadge) const Spacer() else const SizedBox.shrink(),
                                    ElevatedButton(
                                      onPressed: () {
                                        if (data['actionLabel'] == 'Accept') {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => const ResolveIssueScreen(
                                                prefilledIssueId: 'ISSUE-40921',
                                              ),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Clicked: ${data['actionLabel']}')),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: data['iconColor'] as Color? ?? saffron,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(
                                        data['actionLabel'] as String,
                                        style: GoogleFonts.hankenGrotesk(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],

                                  if (hasSecondaryAction) ...[
                                    const SizedBox(width: 8),
                                    OutlinedButton(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Clicked: ${data['secondaryActionLabel']}')),
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: data['iconColor'] as Color? ?? saffron,
                                        side: BorderSide(color: data['iconColor'] as Color? ?? saffron),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(
                                        data['secondaryActionLabel'] as String,
                                        style: GoogleFonts.hankenGrotesk(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

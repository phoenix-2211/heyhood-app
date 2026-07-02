import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hood_officials/core/constants/app_colors.dart';
import 'package:hood_officials/screens/post/resolve_issue_screen.dart';
import 'package:hood_officials/screens/profile/officials_settings_screen.dart';
import 'package:hood_officials/services/firestore_service.dart';
import 'package:hood_officials/models/models.dart' as model;

class OfficialsDashboardScreen extends StatefulWidget {
  final VoidCallback? onAlertsSelected;
  const OfficialsDashboardScreen({super.key, this.onAlertsSelected});

  @override
  State<OfficialsDashboardScreen> createState() => _OfficialsDashboardScreenState();
}

class _OfficialsDashboardScreenState extends State<OfficialsDashboardScreen> {
  // Mock State for issue assignment
  bool _isAssignedCard1 = false;
  bool _isAssignedCard2 = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        backgroundColor: lightBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const OfficialsSettingsScreen(),
                  ),
                );
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE5E2E1)),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://lh3.googleusercontent.com/aida/AP1WRLvRj7hL0cDhfToOkr6TY-ALHME_0JVdK06Z0WlMYKkeESV-KPetJMKUHP6iewGx7F-yjF-J58rU9UnWVRbPomcyuBc40s2rp4t3s6zOV_MEhT7_hAHCSoitULBwpJGr4s_9rZmzJPECn2_3M47aPmzU-VQfo2e_T9Znxh44rki83W1MVVve3w2gIZZOL8QWrtd7vRaZLAvbXg3qWARzcEkxYR_O7NZ4mvkcNfkJsyBhPXa-gJFvxW6vygDB',
                    ),
                    fit: BoxFit.cover,
                    onError: _handleImageError,
                  ),
                ),
                child: const Icon(Icons.person, color: Colors.grey, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Good morning,',
                    style: GoogleFonts.hankenGrotesk(
                      color: muted,
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Text(
                    ''+FirestoreService.currentOfficialName+'',
                    style: GoogleFonts.hankenGrotesk(
                      color: navy,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Notifications with Badge count "3"
          GestureDetector(
            onTap: widget.onAlertsSelected,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: Icon(Icons.notifications_none_outlined, color: navy, size: 26),
                ),
                Positioned(
                  top: 10,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: danger,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '3',
                      style: GoogleFonts.hankenGrotesk(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: navy),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const OfficialsSettingsScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<List<model.Issue>>(
        stream: FirestoreService().getIssuesByWard(FirestoreService.currentWardId),
        builder: (context, snapshot) {
          final issues = snapshot.data ?? [];
          final assigned = issues.where((i) => i.status == 'Notified' || i.status == 'In Progress' || i.status == 'Posted').length;
          final resolved = issues.where((i) => i.status == 'Resolved').length;
          final inProgress = issues.where((i) => i.status == 'In Progress').length;
          final now = DateTime.now();
          final overdue = issues.where((i) => i.status != 'Resolved' && i.resolutionDeadline != null && i.resolutionDeadline!.isBefore(now)).length;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Identity Strip
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: lightSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E2E1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              FirestoreService.currentOfficialRole,
                              style: GoogleFonts.hankenGrotesk(
                                color: navy,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              FirestoreService.currentWardName + ' · Ward ' + FirestoreService.currentWardId.split('-').last,
                              style: GoogleFonts.hankenGrotesk(
                                color: muted,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: saffron,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'GOVERNANCE',
                                style: GoogleFonts.hankenGrotesk(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                '${issues.length}',
                                style: GoogleFonts.hankenGrotesk(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2. Bento Stats Grid
                  Text(
                    'Your Dashboard',
                    style: GoogleFonts.hankenGrotesk(
                      color: navy,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: [
                  _buildStatCard('Assigned', assigned.toString(), Colors.black87),
                  _buildStatCard(
                    'Resolved', 
                    resolved.toString(), 
                    green, 
                    trendLabel: 'Live status',
                  ),
                  _buildStatCard('In Progress', inProgress.toString(), navy),
                  _buildStatCard('Overdue', overdue.toString(), danger),
                ],
              ),
              const SizedBox(height: 24),

              // 3. Urgent New Issues
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'New Urgent Issues',
                    style: GoogleFonts.hankenGrotesk(
                      color: navy,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onAlertsSelected,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View All',
                          style: GoogleFonts.hankenGrotesk(
                            color: saffron,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Icon(Icons.arrow_forward, color: saffron, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Dynamic Urgent Issues List
              ...(() {
                final urgentIssues = issues.where((i) => i.status != 'Resolved').toList();
                if (urgentIssues.isEmpty) {
                  return [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(
                        child: Text(
                          'No pending issues in your ward.',
                          style: GoogleFonts.hankenGrotesk(color: muted, fontSize: 14),
                        ),
                      ),
                    )
                  ];
                }
                return urgentIssues.map((issue) {
                  IconData categoryIcon = Icons.report_problem;
                  final cat = issue.category.toLowerCase();
                  if (cat.contains('road')) {
                    categoryIcon = Icons.edit_road;
                  } else if (cat.contains('sewag') || cat.contains('drain')) {
                    categoryIcon = Icons.water_damage_outlined;
                  } else if (cat.contains('water')) {
                    categoryIcon = Icons.opacity;
                  } else if (cat.contains('elect') || cat.contains('power')) {
                    categoryIcon = Icons.bolt;
                  }

                  String timeLabel = 'just now';
                  if (issue.createdAt != null) {
                    final diff = DateTime.now().difference(issue.createdAt!);
                    if (diff.inDays > 0) {
                      timeLabel = '${diff.inDays}d ago';
                    } else if (diff.inHours > 0) {
                      timeLabel = '${diff.inHours}h ago';
                    } else {
                      timeLabel = '${diff.inMinutes}m ago';
                    }
                  }

                  String deadlineLabel = 'No deadline';
                  if (issue.resolutionDeadline != null) {
                    deadlineLabel = 'Resolve by: ' + issue.resolutionDeadline!.toString().split(' ').first;
                  }

                  final isAssigned = issue.assignedTo == FirestoreService.currentOfficialId;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _buildUrgentIssueCard(
                      ticketId: issue.issueId,
                      title: issue.title,
                      category: issue.category,
                      categoryIcon: categoryIcon,
                      timeLabel: timeLabel,
                      supportCount: '${issue.supportCount} supporting',
                      deadlineLabel: deadlineLabel,
                      isEmergency: issue.status == 'Notified' || issue.status == 'Posted',
                      isAssigned: isAssigned,
                      onAssign: () async {
                        if (!isAssigned) {
                          await FirestoreService().assignIssue(issue.issueId, FirestoreService.currentOfficialId);
                        }
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ResolveIssueScreen(
                              prefilledIssueId: issue.issueId,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }).toList();
              })(),
              const SizedBox(height: 24),

              // Active Problem Tags & Critical Attention layout (2 Columns / Stack depending on width)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Active Problem Tags
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Active Problem Tags',
                          style: GoogleFonts.hankenGrotesk(
                            color: navy,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: lightSurface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE5E2E1)),
                          ),
                          child: Column(
                            children: [
                              _buildTagRow('Sewage', '7', danger),
                              const SizedBox(height: 8),
                              _buildTagRow('Road', '6', saffron),
                              const SizedBox(height: 8),
                              _buildTagRow('Electricity', '4', saffron),
                              const SizedBox(height: 8),
                              _buildTagRow('Water', '3', saffron),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Critical Attention
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Critical Attention',
                          style: GoogleFonts.hankenGrotesk(
                            color: navy,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: lightBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: danger.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'HH-KA-151-2026-00842',
                                style: GoogleFonts.hankenGrotesk(
                                  color: muted,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Clogged Drainage Repair',
                                style: GoogleFonts.hankenGrotesk(
                                  color: navy,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.alarm, color: danger, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Due in 18 hours',
                                    style: GoogleFonts.hankenGrotesk(
                                      color: danger,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 32,
                                child: ElevatedButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Deadline extension requested (mock)')),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: saffron,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  child: Text(
                                    'Extend',
                                    style: GoogleFonts.hankenGrotesk(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 100), // Account for bottom navigation height
            ],
          ),
        ),
      );
    },
  ),
);
}

  static void _handleImageError(Object exception, StackTrace? stackTrace) {}

  Widget _buildStatCard(String label, String value, Color valueColor, {String? trendLabel}) {
    return Container(
      decoration: BoxDecoration(
        color: lightBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E2E1)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.hankenGrotesk(
              color: muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: GoogleFonts.hankenGrotesk(
                  color: valueColor,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (trendLabel != null) ...[
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    trendLabel,
                    style: GoogleFonts.hankenGrotesk(
                      color: green,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTagRow(String tag, String count, Color countColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          tag,
          style: GoogleFonts.hankenGrotesk(
            color: navy,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: countColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            count,
            style: GoogleFonts.hankenGrotesk(
              color: countColor,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUrgentIssueCard({
    required String ticketId,
    required String title,
    required String category,
    required IconData categoryIcon,
    required String timeLabel,
    required String supportCount,
    required String deadlineLabel,
    required bool isEmergency,
    required bool isAssigned,
    required VoidCallback onAssign,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: lightBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E2E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: lightSurface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        ticketId,
                        style: GoogleFonts.hankenGrotesk(
                          color: muted,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (isEmergency)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: danger.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'EMERGENCY',
                          style: GoogleFonts.hankenGrotesk(
                            color: danger,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: saffron.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'HIGH SEVERITY',
                          style: GoogleFonts.hankenGrotesk(
                            color: saffron,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: GoogleFonts.hankenGrotesk(
                    color: navy,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(categoryIcon, color: muted, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          category,
                          style: GoogleFonts.hankenGrotesk(color: muted, fontSize: 11),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.schedule, color: muted, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          timeLabel,
                          style: GoogleFonts.hankenGrotesk(color: muted, fontSize: 11),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.group, color: muted, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          supportCount,
                          style: GoogleFonts.hankenGrotesk(color: muted, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.event_available, color: danger, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      deadlineLabel,
                      style: GoogleFonts.hankenGrotesk(
                        color: danger,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Action Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onAssign,
              style: ElevatedButton.styleFrom(
                backgroundColor: saffron,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                ),
              ),
              child: Text(
                isAssigned ? 'Issue Accepted ✓' : 'Accept & Assign to Me',
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hey_hood/core/constants/app_colors.dart';
import 'package:hey_hood/services/firestore_service.dart';
import 'package:hey_hood/models/models.dart' as model;

class AlertItem {
  final String id;
  final IconData icon;
  final Color indicatorColor;
  final String title;
  final String description;
  final String timeCategory; // 'TODAY' or 'YESTERDAY'
  final String alertType; // 'Ward', 'Official', 'Scheme', 'Escalation', 'Traffic'
  final bool hasProofPhoto;
  final String? tagText;
  final Color? tagColor;
  bool isRead;

  AlertItem({
    required this.id,
    required this.icon,
    required this.indicatorColor,
    required this.title,
    required this.description,
    required this.timeCategory,
    required this.alertType,
    this.hasProofPhoto = false,
    this.tagText,
    this.tagColor,
    this.isRead = false,
  });
}

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  String _selectedFilter = 'All';
  bool _showOnlyUnread = false;

  final Set<String> _readAlertIds = {};

  void _markAllAsRead() {
    setState(() {
      // Since it is client-side, we add all read alerts to the set
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All alerts marked as read.'), backgroundColor: green),
    );
  }

  void _toggleFilterOption() {
    setState(() {
      _showOnlyUnread = !_showOnlyUnread;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_showOnlyUnread ? 'Showing unread alerts only' : 'Showing all alerts'),
        backgroundColor: saffron,
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'Notice Published':
        return Icons.campaign;
      case 'Status Update':
        return Icons.trending_up;
      case 'Issue Resolved':
        return Icons.check_circle;
      case 'Trending Wish':
        return Icons.star;
      default:
        return Icons.info_outline;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'Notice Published':
        return green;
      case 'Status Update':
        return amber;
      case 'Issue Resolved':
        return green;
      case 'Trending Wish':
        return Colors.blue;
      default:
        return saffron;
    }
  }

  String _getAlertTypeForType(String type) {
    switch (type) {
      case 'Notice Published':
        return 'Official';
      case 'Status Update':
        return 'Escalation';
      case 'Issue Resolved':
        return 'Ward';
      case 'Trending Wish':
        return 'Scheme';
      default:
        return 'Ward';
    }
  }

  List<AlertItem> _mapAlerts(List<model.Alert> liveAlerts) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    List<AlertItem> mapped = liveAlerts.map((alert) {
      final alertDate = alert.createdAt ?? now;
      final isToday = DateTime(alertDate.year, alertDate.month, alertDate.day).isAtSameMomentAs(today);
      final isRead = alert.read || _readAlertIds.contains(alert.alertId);
      
      return AlertItem(
        id: alert.alertId,
        icon: _getIconForType(alert.type),
        indicatorColor: _getColorForType(alert.type),
        title: alert.title,
        description: alert.description,
        timeCategory: isToday ? 'TODAY' : 'YESTERDAY',
        alertType: _getAlertTypeForType(alert.type),
        isRead: isRead,
        tagText: alert.type,
        tagColor: _getColorForType(alert.type),
      );
    }).toList();

    if (_showOnlyUnread) {
      mapped = mapped.where((item) => !item.isRead).toList();
    }

    if (_selectedFilter == 'All') return mapped;

    if (_selectedFilter == 'Your Ward') {
      return mapped.where((item) => item.alertType == 'Ward').toList();
    } else if (_selectedFilter == 'Official') {
      return mapped.where((item) => item.alertType == 'Official').toList();
    } else if (_selectedFilter == 'Schemes') {
      return mapped.where((item) => item.alertType == 'Scheme').toList();
    } else if (_selectedFilter == 'Escalations') {
      return mapped.where((item) => item.alertType == 'Escalation').toList();
    }

    return mapped;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<model.Alert>>(
      stream: FirestoreService().getAlerts(FirestoreService.currentUserId),
      builder: (context, snapshot) {
        final liveAlerts = snapshot.data ?? [];
        final alerts = _mapAlerts(liveAlerts);
        
        // If snapshot is empty, populate a default first alert so the screen is never completely blank
        final finalAlerts = alerts.isNotEmpty ? alerts : [
          AlertItem(
            id: 'default-1',
            icon: Icons.check_circle,
            indicatorColor: green,
            title: 'Welcome to Hey Hood',
            description: 'Start exploring your neighborhood and supporting wishes!',
            timeCategory: 'TODAY',
            alertType: 'Ward',
            isRead: false,
          )
        ];

        final todayAlerts = finalAlerts.where((item) => item.timeCategory == 'TODAY').toList();
        final yesterdayAlerts = finalAlerts.where((item) => item.timeCategory == 'YESTERDAY').toList();

        return Scaffold(
          backgroundColor: darkBg,
          appBar: AppBar(
            backgroundColor: Colors.black.withOpacity(0.4),
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Text(
              'Alerts',
              style: GoogleFonts.hankenGrotesk(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.tune, color: _showOnlyUnread ? saffron : Colors.white70),
                onPressed: _toggleFilterOption,
              ),
              IconButton(
                icon: const Icon(Icons.mark_as_unread, color: Colors.white70),
                onPressed: _markAllAsRead,
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filter Scroll Bar
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildFilterChip('All'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Your Ward'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Official'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Schemes'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Escalations'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (todayAlerts.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TODAY',
                          style: GoogleFonts.hankenGrotesk(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...todayAlerts.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: _buildAlertCard(item),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                if (yesterdayAlerts.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'YESTERDAY',
                          style: GoogleFonts.hankenGrotesk(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...yesterdayAlerts.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: _buildAlertCard(item),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],

                if (alerts.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 80.0),
                      child: Text(
                        'No alerts matching selected filter.',
                        style: GoogleFonts.inter(color: Colors.white30),
                      ),
                    ),
                  ),

                const SizedBox(height: 120),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label) {
    bool isActive = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? saffron.withOpacity(0.15) : Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive ? saffron : Colors.white.withOpacity(0.08),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.hankenGrotesk(
                color: isActive ? saffron : Colors.white.withOpacity(0.6),
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlertCard(AlertItem item) {
    return GestureDetector(
      onTap: () {
        setState(() {
          item.isRead = true;
        });
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: darkSurface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                item.title,
                style: GoogleFonts.hankenGrotesk(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.description,
                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  if (item.tagText != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (item.tagColor ?? saffron).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.tagText!.toUpperCase(),
                        style: GoogleFonts.hankenGrotesk(
                          color: item.tagColor ?? saffron,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close', style: TextStyle(color: saffron)),
                ),
              ],
            );
          },
        );
      },
      child: Opacity(
        opacity: item.isRead ? 0.6 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: darkSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: item.isRead ? Colors.transparent : Colors.white.withOpacity(0.08),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: item.indicatorColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: item.indicatorColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!item.isRead)
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: saffron,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.description,
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.tagText != null || item.hasProofPhoto) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (item.tagText != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: (item.tagColor ?? saffron).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item.tagText!.toUpperCase(),
                                style: GoogleFonts.hankenGrotesk(
                                  color: item.tagColor ?? saffron,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          if (item.hasProofPhoto) ...[
                            if (item.tagText != null) const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: green.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.image, color: green, size: 10),
                                  const SizedBox(width: 4),
                                  Text(
                                    'PROOF ATTACHED',
                                    style: GoogleFonts.hankenGrotesk(
                                      color: green,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
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
    );
  }
}

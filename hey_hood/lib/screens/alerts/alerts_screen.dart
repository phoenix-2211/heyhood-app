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

  final List<AlertItem> _staticAlerts = [
    AlertItem(
      id: 'static-1',
      icon: Icons.check_circle,
      indicatorColor: green,
      title: 'Issue Resolved',
      description: 'Sewage overflow on 4th Block marked resolved by Ward Councillor Ramesh Kumar',
      timeCategory: 'TODAY',
      alertType: 'Ward',
      isRead: false,
      hasProofPhoto: true,
    ),
    AlertItem(
      id: 'static-2',
      icon: Icons.trending_up,
      indicatorColor: amber,
      title: 'Escalated to MLA',
      description: 'Pothole issue on 80 Feet Road unresolved for 7 days. Auto escalated to MLA Suresh Patel.',
      timeCategory: 'TODAY',
      alertType: 'Escalation',
      isRead: false,
      tagText: 'DAY 7 — NO RESPONSE',
      tagColor: const Color(0xFFEF4444),
    ),
    AlertItem(
      id: 'static-3',
      icon: Icons.campaign,
      indicatorColor: green,
      title: 'New Notice • Ward 151',
      description: 'Water supply disruption on 28 June 6AM to 2PM. Plan accordingly. — BBMP Ward Office',
      timeCategory: 'TODAY',
      alertType: 'Official',
      isRead: false,
      tagText: 'OFFICIAL POST',
      tagColor: const Color(0xFF10B981),
    ),
    AlertItem(
      id: 'static-4',
      icon: Icons.star,
      indicatorColor: Colors.blue,
      title: 'New Scheme in your area',
      description: 'PM Awas Yojana Urban — You may be eligible based on your ward. Tap to check criteria.',
      timeCategory: 'TODAY',
      alertType: 'Scheme',
      isRead: false,
      tagText: 'STATE SCHEME',
      tagColor: const Color(0xFF3B82F6),
    ),
    AlertItem(
      id: 'static-5',
      icon: Icons.back_hand,
      indicatorColor: Colors.amber,
      title: 'Your issue is gaining support',
      description: 'Broken streetlight near school supported now has 50 people supporting.',
      timeCategory: 'TODAY',
      alertType: 'Ward',
      isRead: false,
      tagText: '50 SUPPORTING',
      tagColor: const Color(0xFFF59E0B),
    ),
    AlertItem(
      id: 'static-6',
      icon: Icons.warning_amber_rounded,
      indicatorColor: Colors.amber,
      title: 'Heavy Traffic Alert',
      description: 'Congestion reported near Central Square due to protest march. Seek alternate routes.',
      timeCategory: 'YESTERDAY',
      alertType: 'Escalation',
      isRead: true,
    ),
    AlertItem(
      id: 'static-7',
      icon: Icons.autorenew,
      indicatorColor: green,
      title: 'Garbage Collection Complete',
      description: 'Morning sweep and collection in Block B has been completed for today.',
      timeCategory: 'YESTERDAY',
      alertType: 'Ward',
      isRead: true,
    ),
  ];

  void _markAllAsRead() {
    setState(() {
      for (var alert in _staticAlerts) {
        alert.isRead = true;
      }
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
      
      final String? tagText = alert.tag.isNotEmpty ? alert.tag : null;
      Color tagColor = _getColorForType(alert.type);
      if (tagText != null) {
        final t = tagText.toUpperCase();
        if (t.contains('NO RESPONSE') || t.contains('ALERT')) {
          tagColor = const Color(0xFFEF4444); // Red/pink
        } else if (t.contains('OFFICIAL') || t.contains('COMPLETE')) {
          tagColor = const Color(0xFF10B981); // Emerald Green
        } else if (t.contains('SCHEME')) {
          tagColor = const Color(0xFF3B82F6); // Blue
        } else if (t.contains('SUPPORTING') || t.contains('TRENDING')) {
          tagColor = const Color(0xFFF59E0B); // Amber/Yellow
        }
      }

      return AlertItem(
        id: alert.alertId,
        icon: _getIconForType(alert.type),
        indicatorColor: _getColorForType(alert.type),
        title: alert.title,
        description: alert.description,
        timeCategory: isToday ? 'TODAY' : 'YESTERDAY',
        alertType: _getAlertTypeForType(alert.type),
        isRead: isRead,
        tagText: tagText,
        tagColor: tagColor,
        hasProofPhoto: alert.type == 'Issue Resolved',
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
    // Filter the static alerts list
    List<AlertItem> alerts = _staticAlerts;
    if (_showOnlyUnread) {
      alerts = alerts.where((item) => !item.isRead).toList();
    }
    
    if (_selectedFilter == 'Your Ward') {
      alerts = alerts.where((item) => item.alertType == 'Ward').toList();
    } else if (_selectedFilter == 'Official') {
      alerts = alerts.where((item) => item.alertType == 'Official').toList();
    } else if (_selectedFilter == 'Schemes') {
      alerts = alerts.where((item) => item.alertType == 'Scheme').toList();
    } else if (_selectedFilter == 'Escalations') {
      alerts = alerts.where((item) => item.alertType == 'Escalation').toList();
    }

    final todayAlerts = alerts.where((item) => item.timeCategory == 'TODAY').toList();
    final yesterdayAlerts = alerts.where((item) => item.timeCategory == 'YESTERDAY').toList();

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

  void _showProofPhotoDialog(AlertItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: darkSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Resolution Proof',
            style: GoogleFonts.hankenGrotesk(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  'https://images.unsplash.com/photo-1541888946425-d81bb19240f5?auto=format&fit=crop&w=500&q=80',
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(height: 180, color: Colors.grey[900]),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Work completed at the site. Verified and closed by the municipal officer.',
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, height: 1.4),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Dismiss', style: TextStyle(color: saffron)),
            ),
          ],
        );
      },
    );
  }

  void _showAlertDialog(AlertItem item) {
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
  }

  Widget _buildAlertCard(AlertItem item) {
    return GestureDetector(
      onTap: () {
        setState(() {
          item.isRead = true;
          _readAlertIds.add(item.id);
        });
        _showAlertDialog(item);
      },
      child: Opacity(
        opacity: item.isRead ? 0.6 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: darkSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: item.isRead ? Colors.transparent : Colors.white.withOpacity(0.04),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Absolute positioned left indicator line from Stitch
              Positioned(
                left: 0,
                top: 12,
                bottom: 12,
                width: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: item.indicatorColor,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: item.indicatorColor.withOpacity(0.3),
                        blurRadius: 6,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                ),
              ),
              // Card Details
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: item.indicatorColor.withOpacity(0.1),
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
                            maxLines: 3,
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
                                      color: (item.tagColor ?? saffron).withOpacity(0.12),
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
                                  GestureDetector(
                                    onTap: () => _showProofPhotoDialog(item),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: saffron.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: saffron.withOpacity(0.2)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.photo_camera, color: saffron, size: 12),
                                          const SizedBox(width: 6),
                                          Text(
                                            'VIEW PROOF PHOTO',
                                            style: GoogleFonts.hankenGrotesk(
                                              color: saffron,
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
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
            ],
          ),
        ),
      ),
    );
  }
}

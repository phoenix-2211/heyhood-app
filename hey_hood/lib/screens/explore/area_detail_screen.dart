import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hey_hood/core/constants/app_colors.dart';
import 'package:hey_hood/models/models.dart';
import 'package:hey_hood/models/wish_model.dart';
import 'package:hey_hood/models/emergency_service_model.dart';
import 'package:hey_hood/services/firestore_service.dart';
import 'package:hey_hood/screens/explore/news_short_detail_screen.dart';

class AreaDetailScreen extends StatefulWidget {
  final Ward ward;

  const AreaDetailScreen({
    super.key,
    required this.ward,
  });

  @override
  State<AreaDetailScreen> createState() => _AreaDetailScreenState();
}

class _AreaDetailScreenState extends State<AreaDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestore = FirestoreService();
  bool _isCalling = false;
  String _callTitle = '';
  String _callNumber = '';
  int _callSeconds = 0;
  Timer? _callTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _callTimer?.cancel();
    super.dispose();
  }

  String _getWardBannerImage(String wardId) {
    if (wardId == "TN-CHN-170") {
      return "https://images.unsplash.com/photo-1580618672591-eb180b1a973f?auto=format&fit=crop&w=800&q=80"; // Adyar River/Bridge
    }
    if (wardId == "TN-CHN-179") {
      return "https://images.unsplash.com/photo-1546482502-04b3417935c2?auto=format&fit=crop&w=800&q=80"; // Velachery Flyover/Lake
    }
    if (wardId == "TN-VRD-001") {
      return "https://images.unsplash.com/photo-1605649487212-47bdab064df7?auto=format&fit=crop&w=800&q=80"; // Virudhunagar Street
    }
    if (wardId == "TN-VRD-002") {
      return "https://images.unsplash.com/photo-1596422846543-75c6fc18a523?auto=format&fit=crop&w=800&q=80"; // Virudhunagar Market
    }
    return "https://picsum.photos/seed/ward-banner-$wardId/800/400";
  }

  void _startCall(String title, String number) {
    if (_isCalling) return;
    setState(() {
      _isCalling = true;
      _callTitle = title;
      _callNumber = number;
      _callSeconds = 0;
    });

    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _callSeconds++;
        });
      }
    });
  }

  void _endCall() {
    _callTimer?.cancel();
    setState(() {
      _isCalling = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Call to $_callTitle ended. Duration: $_callSeconds seconds.'),
        backgroundColor: saffron,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bannerUrl = _getWardBannerImage(widget.ward.wardId);
    
    return Scaffold(
      backgroundColor: darkBg,
      body: Stack(
        children: [
          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 240,
                  floating: false,
                  pinned: true,
                  backgroundColor: darkBg,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    background: Stack(
                      children: [
                        // Banner Image
                        Positioned.fill(
                          child: Image.network(
                            bannerUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(color: Colors.grey[900]),
                          ),
                        ),
                        // Dark Gradients
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.5),
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.85),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Ward name + number overlay
                        Positioned(
                          left: 16,
                          bottom: 16,
                          right: 16,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      widget.ward.wardName,
                                      style: GoogleFonts.hankenGrotesk(
                                        color: Colors.white,
                                        fontSize: 26,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      "WARD ${widget.ward.wardNumber} • ${widget.ward.district}".toUpperCase(),
                                      style: GoogleFonts.hankenGrotesk(
                                        color: saffron,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Pulse score badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: saffron.withOpacity(0.5), width: 1.5),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "${widget.ward.pulseScore}",
                                      style: GoogleFonts.hankenGrotesk(
                                        color: widget.ward.pulseScore >= 70 ? green : saffron,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const Text(
                                      'PULSE',
                                      style: TextStyle(color: Colors.white54, fontSize: 8, fontWeight: FontWeight.bold),
                                    ),
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
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: saffron,
                      unselectedLabelColor: Colors.white38,
                      indicatorColor: saffron,
                      indicatorWeight: 3,
                      labelStyle: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.bold, fontSize: 13),
                      unselectedLabelStyle: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.normal, fontSize: 13),
                      tabs: const [
                        Tab(text: 'News Shorts'),
                        Tab(text: 'Analytics'),
                        Tab(text: 'KYH'),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildNewsShortsTab(),
                _buildAnalyticsTab(),
                _buildKYHTab(),
              ],
            ),
          ),
          
          // Active calling overlay simulator
          if (_isCalling) _buildCallOverlay(),
        ],
      ),
    );
  }

  // TAB 1: News Shorts (Ward Specific)
  Widget _buildNewsShortsTab() {
    return StreamBuilder<List<Wish>>(
      stream: _firestore.getWishesByWard(widget.ward.wardId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final wishes = snapshot.data!;
        if (wishes.isEmpty) {
          return Center(
            child: Text(
              'No news highlights in ${widget.ward.wardName} yet.',
              style: const TextStyle(color: Colors.white38, fontSize: 13),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: wishes.length,
          itemBuilder: (context, index) {
            final wish = wishes[index];
            return Card(
              color: darkSurface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.only(bottom: 16),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewsShortDetailScreen(
                        wishes: wishes,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
                child: Row(
                  children: [
                    // Thumbnail
                    Image.network(
                      wish.imageUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(width: 100, height: 100, color: Colors.grey[900]),
                    ),
                    const SizedBox(width: 12),
                    // Details
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: saffron.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                wish.category.toUpperCase(),
                                style: const TextStyle(color: saffron, fontSize: 8, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              wish.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.back_hand, color: Colors.white38, size: 10),
                                const SizedBox(width: 4),
                                Text(
                                  '${wish.supportCount} Supports',
                                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.access_time, color: Colors.white38, size: 10),
                                const SizedBox(width: 4),
                                const Text(
                                  '2d ago',
                                  style: TextStyle(color: Colors.white38, fontSize: 10),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // TAB 2: Analytics (Dynamic & Ward-Specific)
  Widget _buildAnalyticsTab() {
    return StreamBuilder<List<Issue>>(
      stream: _firestore.getIssuesByWard(widget.ward.wardId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final issues = snapshot.data!;
        
        // Dynamic calculations
        final totalIssues = issues.length;
        final resolvedIssues = issues.where((i) => i.status == "Resolved").length;
        final resolvedPct = totalIssues == 0 ? 0 : ((resolvedIssues / totalIssues) * 100).round();
        
        // Calculate average resolution time
        double sumDays = 0;
        int resolvedCount = 0;
        for (var issue in issues) {
          if (issue.status == 'Resolved' && issue.resolvedAt != null && issue.createdAt != null) {
            sumDays += issue.resolvedAt!.difference(issue.createdAt!).inDays;
            resolvedCount++;
          }
        }
        final avgDaysText = resolvedCount == 0 
            ? (totalIssues == 0 ? "N/A" : "4.8 days") 
            : "${(sumDays / resolvedCount).toStringAsFixed(1)} days";

        // Category breakdown
        final Map<String, int> catCounts = {};
        for (var issue in issues) {
          catCounts[issue.category] = (catCounts[issue.category] ?? 0) + 1;
        }
        final sortedCats = catCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Row of Stat Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('Total Issues', '$totalIssues', Icons.assignment_outlined),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('Resolved %', '$resolvedPct%', Icons.check_circle_outline, valueColor: green),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('Avg Resolve Time', avgDaysText, Icons.timer_outlined),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('Active Steer', widget.ward.zone, Icons.location_city_outlined),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Category Breakdown Chart Card
            _buildSectionHeader('Issue Categories Breakdown'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: darkSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.04)),
              ),
              child: totalIssues == 0
                  ? const Center(child: Text('No data recorded', style: TextStyle(color: Colors.white38)))
                  : Column(
                      children: List.generate(sortedCats.length, (idx) {
                        final cat = sortedCats[idx];
                        final pct = cat.value / totalIssues;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(cat.key, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                  Text('${cat.value} (${(pct * 100).round()}%)', style: const TextStyle(color: saffron, fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: pct,
                                  backgroundColor: Colors.white10,
                                  valueColor: const AlwaysStoppedAnimation<Color>(saffron),
                                  minHeight: 6,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
            ),
            const SizedBox(height: 24),

            // Visual Monthly Trend Chart Card
            _buildSectionHeader('Issues Monthly Trend'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: darkSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.04)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: saffron, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      const Text('Raised', style: TextStyle(color: Colors.white70, fontSize: 10)),
                      const SizedBox(width: 16),
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: green, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      const Text('Resolved', style: TextStyle(color: Colors.white70, fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 120,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: TrendLinePainter(
                        // Create different curves dynamically for Adyar vs Virudhunagar
                        isChennai: widget.ward.wardId.startsWith("TN-CHN"),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Week 1', style: TextStyle(color: Colors.white30, fontSize: 8)),
                      Text('Week 2', style: TextStyle(color: Colors.white30, fontSize: 8)),
                      Text('Week 3', style: TextStyle(color: Colors.white30, fontSize: 8)),
                      Text('Week 4', style: TextStyle(color: Colors.white30, fontSize: 8)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Top Recurring Issues List Card
            _buildSectionHeader('Top Recurring Grievances'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: darkSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.04)),
              ),
              child: sortedCats.isEmpty
                  ? const Center(child: Text('No grievances registered', style: TextStyle(color: Colors.white38)))
                  : Column(
                      children: List.generate(sortedCats.take(3).length, (idx) {
                        final cat = sortedCats[idx];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: saffron.withOpacity(0.12),
                            child: const Icon(Icons.warning_amber_outlined, color: saffron),
                          ),
                          title: Text(cat.key, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                          subtitle: Text('Highest priority ticket volume in ward', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)),
                          trailing: Text('${cat.value} reports', style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                        );
                      }),
                    ),
            ),
          ],
        );
      },
    );
  }

  // TAB 3: Know Your Hood (KYH Directory)
  Widget _buildKYHTab() {
    return StreamBuilder<List<EmergencyService>>(
      stream: _firestore.getEmergencyServices(widget.ward.wardId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final services = snapshot.data!;
        
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Fixed Quick-Action Boxes (Ambulance + Fire)
            Row(
              children: [
                Expanded(
                  child: _buildEmergencyBox('Ambulance', '108', Icons.local_hospital_outlined, danger),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildEmergencyBox('Fire Force', '101', Icons.local_fire_department_outlined, saffron),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            _buildSectionHeader('Nearby Ward Directories'),
            const SizedBox(height: 12),
            
            services.isEmpty
                ? const Center(child: Text('No nearby emergency stations mapped', style: TextStyle(color: Colors.white38)))
                : Column(
                    children: services.map((service) {
                      IconData typeIcon = Icons.location_on_outlined;
                      if (service.type == "Hospital" || service.type == "Clinic") {
                        typeIcon = Icons.medical_services_outlined;
                      } else if (service.type == "Police") {
                        typeIcon = Icons.local_police_outlined;
                      } else if (service.type == "Fire Station") {
                        typeIcon = Icons.fire_truck_outlined;
                      }
                      
                      return Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: darkSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.04)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        service.name,
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '0.8km • ${service.phone}',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.4),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.call, color: saffron),
                                  onPressed: () => _startCall(service.name, service.phone),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _buildHospitalTag(service.type),
                                const SizedBox(width: 8),
                                if (service.open247) _buildHospitalTag('24 / 7'),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, {Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
              Icon(icon, color: Colors.white24, size: 14),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.hankenGrotesk(
              color: valueColor ?? Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyBox(String label, String code, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => _startCall(label, code),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: darkSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(code, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHospitalTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: Colors.white60,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.hankenGrotesk(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // Native call overlay simulator
  Widget _buildCallOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.92),
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              CircleAvatar(
                radius: 48,
                backgroundColor: saffron.withOpacity(0.12),
                child: const Icon(Icons.person, color: saffron, size: 48),
              ),
              const SizedBox(height: 24),
              Text(
                _callTitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.hankenGrotesk(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _callNumber,
                style: const TextStyle(color: Colors.white54, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                '${_callSeconds ~/ 60}:${(_callSeconds % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(color: saffron, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _endCall,
                child: Container(
                  height: 64,
                  width: 64,
                  decoration: const BoxDecoration(
                    color: danger,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.call_end, color: Colors.white, size: 28),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

// Slivers delegate for TabBar pinning
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverAppBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: darkBg,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

// Custom Painter for Analytics Trend Line (dynamic curves per ward)
class TrendLinePainter extends CustomPainter {
  final bool isChennai;

  TrendLinePainter({required this.isChennai});

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine1 = Paint()
      ..color = saffron
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final paintLine2 = Paint()
      ..color = green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path1 = Path();
    final path2 = Path();

    if (isChennai) {
      // Chennai: Higher volume, fluctuating
      path1.moveTo(0, size.height * 0.7);
      path1.cubicTo(size.width * 0.25, size.height * 0.2, size.width * 0.5, size.height * 0.8, size.width * 0.75, size.height * 0.3);
      path1.lineTo(size.width, size.height * 0.4);

      path2.moveTo(0, size.height * 0.9);
      path2.cubicTo(size.width * 0.25, size.height * 0.5, size.width * 0.5, size.height * 0.4, size.width * 0.75, size.height * 0.6);
      path2.lineTo(size.width, size.height * 0.35);
    } else {
      // Virudhunagar: Lower volume, steadier decrease
      path1.moveTo(0, size.height * 0.4);
      path1.cubicTo(size.width * 0.3, size.height * 0.3, size.width * 0.6, size.height * 0.5, size.width * 0.8, size.height * 0.2);
      path1.lineTo(size.width, size.height * 0.1);

      path2.moveTo(0, size.height * 0.5);
      path2.cubicTo(size.width * 0.3, size.height * 0.45, size.width * 0.6, size.height * 0.3, size.width * 0.8, size.height * 0.15);
      path2.lineTo(size.width, size.height * 0.05);
    }

    canvas.drawPath(path1, paintLine1);
    canvas.drawPath(path2, paintLine2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

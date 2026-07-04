import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hey_hood/core/constants/app_colors.dart';
import 'package:hey_hood/services/firestore_service.dart';
import 'package:hey_hood/models/models.dart';
import 'package:hey_hood/screens/profile/citizen_settings_screen.dart';
import 'package:hey_hood/screens/shorts/shorts_feed_screen.dart';
import 'package:hey_hood/screens/wish/wish_here_screen.dart';
import 'package:hey_hood/screens/stats/neighborhood_stats_screen.dart';
import 'package:hey_hood/screens/explore/news_short_detail_screen.dart';

class HoodHomeScreen extends StatefulWidget {
  const HoodHomeScreen({super.key});

  @override
  State<HoodHomeScreen> createState() => _HoodHomeScreenState();
}

class _HoodHomeScreenState extends State<HoodHomeScreen> {
  bool _isSearching = false;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _notices = [
    {
      'avatarUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDsWQ5uSN5PqmDubDuV9SAeLZtUsArmrBgpNVC0F8gjOuHXsgZuP6RJ08RCcNtTupBDULFXzdcrtdU9Ie9Q9XOaWeMckP7tc2_w3UwqG3zYOxFlHaq-dAAAYmSGG3jPYaNn2ERVEtaIUrf5yddJbyQBbEQghktEnYmUHlPCnvkCXBZyNh96N9LIKPZ-HRoR4JVpgM5viVlYCo76nFbMmyg5An2R1rYoFL3MmYOqdyny5RWjcP-K4NfUMBkk4U3wjzVZMt5QqgWoJDlH',
      'name': 'Aruna Devi',
      'role': 'Ward Corporator',
      'content': 'Public grievance meeting scheduled for this Saturday at the 6th Block Library at 10:00 AM.',
      'timeAgo': '2h ago',
    },
    {
      'avatarUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBdVEanBrnxnSUTHwSqJyqSFVHhnwUQdEwxK8p8FSqZurEYYDnST6ZAwXvx7rQa5dxrRZFskB20AJRnhxIbnUTUWPjDPVczty7NdSt7mDhW8-jhE-zdZAB0WAhJo-e7Af0PXNuB4gXtNNEMPI6qA7A2dqD6MMHSpqcONqjDrhqryuT0h3KtVh_Q3tVjFmQOmHiesgOqBR139L9zv2DWRQOnWawxqAGgUdotYTUwJ7ujs7BV6SyTXzSGpT0qDWGiAo8kE43ZlJH64i6p',
      'name': 'Vikram S.',
      'role': 'BBMP Engineer',
      'content': 'Scheduled power outage in 4th Block on Tuesday from 11 AM to 4 PM for feeder maintenance.',
      'timeAgo': '5h ago',
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      backgroundColor: darkSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Municipal Alerts',
                style: GoogleFonts.hankenGrotesk(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildNotificationItem('Water tank supply delayed by 2 hours in Block C', '1h ago', Icons.water_drop, Colors.blue),
              const SizedBox(height: 12),
              _buildNotificationItem('Feeder lines upgrade finished in 2nd Block', '3h ago', Icons.flash_on, saffron),
              const SizedBox(height: 12),
              _buildNotificationItem('Stray dog vaccination camp successfully concluded', '1d ago', Icons.pets, green),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem(String title, String time, IconData icon, Color iconColor) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(time, style: GoogleFonts.inter(color: Colors.white38, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }

  List<Map<String, String>> get _filteredNotices {
    if (_searchQuery.isEmpty) return _notices;
    return _notices.where((n) {
      return n['name']!.toLowerCase().contains(_searchQuery) ||
             n['content']!.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredNotices;

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.4),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: _isSearching
            ? Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Search notice board...',
                    hintStyle: TextStyle(color: Colors.white30),
                    border: InputBorder.none,
                  ),
                ),
              )
            : GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const CitizenSettingsScreen()),
                  );
                },
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24),
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuDKSPynJzbnnIqIa5hdeKN8na4CdLHHD8usykyL1ZH89f2FI2keeGvlfzQ9pXwk4stL6ua5yJDF4X7K0OemjOkQqIH5VHTqYSjbbQpsTqSi9UqwpBOjJWoxXF4VXWZLXPcPtRBRBLJw5Armoo1O30M1YVSvCjSu4sgHJyVp8cb9PztihaDXEr6fAyifyIqJ4vPhQys4O2zihL88ITIEWIgnBU7XbRVUN1FDCqW2Ux1sGUBYcGGA6O1oJ6U3zV5kFWJt1ddBCQUP5sJD',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          FirestoreService.currentWardName,
                          style: GoogleFonts.hankenGrotesk(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'WARD ' + (FirestoreService.currentWardId.split('-').last),
                          style: GoogleFonts.hankenGrotesk(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: saffron),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                  _isSearching = false;
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: saffron),
                onPressed: _showNotifications,
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: saffron,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Visual Banner
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuAAUVa9XXzNA7C5yoxr77S4RMQ4Ee_xqg-YuQS4G5igY_QZ7rSKHtB3xKWDMPqK60UwNDIAHMWrIH8l5QXwaVFHgb3SuGoyATEhoz7GYy5ACbiM2cVHI-6T0F6O8iMLAA4z5Ovr8850RRhJjxyoM9-DwWb-hFfq9s6Fu5R5Bpj6t2FbN-B-8V3UqQC9bRss2LURIevyzb0fJCCKDMlqDi4GAx4ZMEh-DV3zVyuNYTSa9gmFAv3tMChyfeYY-cXsNrwTpW0l60vDkvCX',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.2),
                        darkBg.withOpacity(0.9),
                      ],
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                        children: const [
                          TextSpan(text: 'I '),
                          TextSpan(text: '❤️ ', style: TextStyle(color: saffron)),
                          TextSpan(text: 'Adyar'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Chennai, India',
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Three Quick Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      context,
                      Icons.dynamic_feed,
                      'Shorts',
                      () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const ShortsFeedScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      context,
                      Icons.star_outline,
                      'Wish Here',
                      () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const WishHereScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      context,
                      Icons.bar_chart,
                      'Stats',
                      () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const NeighborhoodStatsScreen()),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // This Month's Wins
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "This Month's Wins",
                    style: GoogleFonts.hankenGrotesk(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: darkSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.04)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: green.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.emoji_events,
                            color: green,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Road repaired · 3rd Block ✓',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Neighborhood Snapshot
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Neighborhood Snapshot',
                    style: GoogleFonts.hankenGrotesk(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  StreamBuilder<List<Issue>>(
                    stream: FirestoreService().getIssuesByWard(FirestoreService.currentWardId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.6,
                          children: [
                            _buildSnapshotCard('...', 'Total Issues', Colors.white),
                            _buildSnapshotCard('...', 'Resolved', green),
                            _buildSnapshotCard('...', 'In Progress', amber),
                            _buildSnapshotCard('...', 'Overdue', danger),
                          ],
                        );
                      }
                      final issues = snapshot.data!;
                      final total = issues.length;
                      final resolved = issues.where((i) => i.status == 'Resolved').length;
                      final inProgress = issues.where((i) => i.status == 'In Progress' || i.status == 'Notified' || i.status == 'Posted').length;
                      final now = DateTime.now();
                      final overdue = issues.where((i) => i.status != 'Resolved' && i.resolutionDeadline != null && i.resolutionDeadline!.isBefore(now)).length;

                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.6,
                        children: [
                          _buildSnapshotCard(total.toString(), 'Total Issues', Colors.white),
                          _buildSnapshotCard(resolved.toString(), 'Resolved', green),
                          _buildSnapshotCard(inProgress.toString(), 'Active Issues', amber),
                          _buildSnapshotCard(overdue.toString(), 'Overdue', danger),
                        ],
                      );
                    }
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Trending in Your Hood
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Trending In Your Hood',
                    style: GoogleFonts.hankenGrotesk(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 220,
                  child: StreamBuilder<List<Wish>>(
                    stream: FirestoreService().getWishesByWard(FirestoreService.currentWardId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final wishes = snapshot.data!;
                      if (wishes.isEmpty) {
                        return const Center(
                          child: Text(
                            "No trending wishes in this ward yet.",
                            style: TextStyle(color: Colors.white38, fontSize: 13),
                          ),
                        );
                      }
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: wishes.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: _buildTrendingCard(
                              wishes,
                              index,
                            ),
                          );
                        },
                      );
                    }
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Notice Board
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.campaign, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Notice Board · Ward ' + FirestoreService.currentWardId.split('-').last,
                        style: GoogleFonts.hankenGrotesk(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (filtered.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          'No notices match your search.',
                          style: GoogleFonts.inter(color: Colors.white30),
                        ),
                      ),
                    )
                  else
                    ...filtered.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _buildNoticeCard(
                          item['avatarUrl']!,
                          item['name']!,
                          item['role']!,
                          item['content']!,
                          item['timeAgo']!,
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 100), // Height of bottom nav bar padding
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: darkSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.04)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSnapshotCard(String count, String label, Color countColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count,
            style: GoogleFonts.hankenGrotesk(
              color: countColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.hankenGrotesk(
              color: Colors.white.withOpacity(0.4),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingCard(
    List<Wish> wishes,
    int index,
  ) {
    final wish = wishes[index];
    final imageUrl = wish.imageUrl.isNotEmpty ? wish.imageUrl : 'https://images.unsplash.com/photo-1509391366360-2e959784a276?auto=format&fit=crop&w=500&q=80';
    final title = wish.title;
    final subtitle = '${wish.supportCount} Support · ' + wish.category;
    final indicatorColor = wish.supportCount >= 100 ? green : amber;

    return GestureDetector(
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
      child: Container(
        width: 160,
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: indicatorColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoticeCard(
    String avatarUrl,
    String name,
    String role,
    String content,
    String timeAgo,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: green, width: 3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(avatarUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  role,
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    timeAgo,
                    style: GoogleFonts.hankenGrotesk(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 10,
                    ),
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

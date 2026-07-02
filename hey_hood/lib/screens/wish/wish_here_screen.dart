import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hey_hood/core/constants/app_colors.dart';
import 'package:hey_hood/screens/wish/post_wish_bottom_sheet.dart';
import 'package:hey_hood/screens/profile/citizen_settings_screen.dart';
import 'package:hey_hood/services/firestore_service.dart';
import 'package:hey_hood/services/agent_service.dart';
import 'package:hey_hood/models/models.dart' as model;

class WishItem {
  final String id;
  final String imageUrl;
  final String category;
  final String area;
  final String title;
  final String desc;
  int supportCount;
  bool isSupported;
  final int excessFaces;

  WishItem({
    required this.id,
    required this.imageUrl,
    required this.category,
    required this.area,
    required this.title,
    required this.desc,
    required this.supportCount,
    this.isSupported = false,
    this.excessFaces = 12,
  });
}

class WishHereScreen extends StatefulWidget {
  const WishHereScreen({super.key});

  @override
  State<WishHereScreen> createState() => _WishHereScreenState();
}

class _WishHereScreenState extends State<WishHereScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  String _selectedFilter = 'All';
  String _searchQuery = "";
  final Set<String> _supportedWishIds = {};

  void _toggleSupport(WishItem item) {
    if (_supportedWishIds.contains(item.id)) return;
    setState(() {
      _supportedWishIds.add(item.id);
      item.isSupported = true;
      item.supportCount++;
    });
    FirestoreService().supportWish(item.id, FirestoreService.currentUserId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Support registered! Ward Councillor notified.'),
        backgroundColor: green,
      ),
    );
  }

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

  void _showPostWishBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PostWishBottomSheet(
        onWishAdded: (newWish) async {
          final wishData = {
            'title': newWish.title,
            'description': newWish.desc,
            'category': newWish.category,
            'imageUrl': newWish.imageUrl,
            'imageType': 'ai_generated',
            'support_count': 1,
            'ward_id': FirestoreService.currentWardId,
            'posted_by': FirestoreService.currentUserId,
            'status': 'Active',
            'is_trending': false,
          };
          final createdWish = await FirestoreService().createWish(wishData);
          if (createdWish != null) {
            await AgentService.matchWish(
              wishId: createdWish.wishId,
              title: createdWish.title,
              description: createdWish.description,
              category: createdWish.category,
              wardId: createdWish.wardId,
            );
          }
        },
      ),
    );
  }

  void _selectWard() {
    showModalBottomSheet(
      context: context,
      backgroundColor: darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Active Ward',
                style: GoogleFonts.hankenGrotesk(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Adyar · Ward 170', style: TextStyle(color: Colors.white)),
                trailing: FirestoreService.currentWardId == 'TN-CHN-170' ? const Icon(Icons.check, color: saffron) : null,
                onTap: () {
                  setState(() {
                    FirestoreService.currentWardId = 'TN-CHN-170';
                    FirestoreService.currentWardName = 'Adyar';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Velachery · Ward 179', style: TextStyle(color: Colors.white)),
                trailing: FirestoreService.currentWardId == 'TN-CHN-179' ? const Icon(Icons.check, color: saffron) : null,
                onTap: () {
                  setState(() {
                    FirestoreService.currentWardId = 'TN-CHN-179';
                    FirestoreService.currentWardName = 'Velachery';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Virudhunagar Ward 1', style: TextStyle(color: Colors.white)),
                trailing: FirestoreService.currentWardId == 'TN-VRD-001' ? const Icon(Icons.check, color: saffron) : null,
                onTap: () {
                  setState(() {
                    FirestoreService.currentWardId = 'TN-VRD-001';
                    FirestoreService.currentWardName = 'Virudhunagar Ward 1';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Virudhunagar Ward 2', style: TextStyle(color: Colors.white)),
                trailing: FirestoreService.currentWardId == 'TN-VRD-002' ? const Icon(Icons.check, color: saffron) : null,
                onTap: () {
                  setState(() {
                    FirestoreService.currentWardId = 'TN-VRD-002';
                    FirestoreService.currentWardName = 'Virudhunagar Ward 2';
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<model.Wish>>(
      stream: FirestoreService().getWishesByWard(FirestoreService.currentWardId),
      builder: (context, snapshot) {
        final liveWishes = snapshot.data ?? [];
        
        List<WishItem> mappedWishes = liveWishes.map((w) {
          final isSupported = _supportedWishIds.contains(w.wishId);
          return WishItem(
            id: w.wishId,
            imageUrl: w.imageUrl.isNotEmpty ? w.imageUrl : 'https://images.unsplash.com/photo-1519331379826-f10be5486c6f?auto=format&fit=crop&w=500&q=80',
            category: w.category,
            area: FirestoreService.currentWardName,
            title: w.title,
            desc: w.description,
            supportCount: w.supportCount,
            isSupported: isSupported,
            excessFaces: w.supportCount > 3 ? (w.supportCount - 3) : 0,
          );
        }).toList();

        // Apply filters
        List<WishItem> filtered = List.from(mappedWishes);
        if (_searchQuery.isNotEmpty) {
          filtered = filtered.where((w) {
            return w.title.toLowerCase().contains(_searchQuery) ||
                   w.desc.toLowerCase().contains(_searchQuery);
          }).toList();
        }
        if (_selectedFilter == 'Facilities') {
          filtered = filtered.where((w) => w.category.toLowerCase().contains('facil')).toList();
        } else if (_selectedFilter == 'Infrastructure') {
          filtered = filtered.where((w) => w.category.toLowerCase().contains('infras')).toList();
        } else if (_selectedFilter == 'Most Supported') {
          filtered.sort((a, b) => b.supportCount.compareTo(a.supportCount));
        } else if (_selectedFilter == 'Newest') {
          filtered.sort((a, b) => b.id.compareTo(a.id));
        }

        final wishes = filtered;

        return Scaffold(
          backgroundColor: darkBg,
          appBar: AppBar(
            backgroundColor: Colors.black.withOpacity(0.4),
            elevation: 0,
            automaticallyImplyLeading: false,
            title: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Row(
                children: [
                  const Icon(Icons.arrow_back, color: saffron),
                  const SizedBox(width: 8),
                  Text(
                    'HEY HOOD',
                    style: GoogleFonts.hankenGrotesk(
                      color: saffron,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.location_on, color: saffron),
                onPressed: _selectWard,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CitizenSettingsScreen(),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  width: 32,
                  height: 32,
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
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            // Welcome Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Wish Here',
                        style: GoogleFonts.hankenGrotesk(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.star, color: saffron, size: 24),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Viewing: ' + FirestoreService.currentWardName + ' • Ward ' + FirestoreService.currentWardId.split('-').last,
                    style: GoogleFonts.hankenGrotesk(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: darkSurface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: TextField(
                  controller: _searchController,
                  style: GoogleFonts.inter(color: Colors.white),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Search wishes in your area...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                    prefixIcon: const Icon(Icons.search, color: Colors.white30),
                    suffixIcon: _searchQuery.isNotEmpty 
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white54, size: 18),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Post a Wish Entry Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: _showPostWishBottomSheet,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: darkSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: saffron.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.star, color: saffron, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Got a wish for your hood?',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Post it and let your neighbors support it',
                              style: GoogleFonts.inter(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.3)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Trending Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: darkSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border(
                    left: const BorderSide(color: saffron, width: 4),
                    top: BorderSide(color: Colors.white.withOpacity(0.08)),
                    right: BorderSide(color: Colors.white.withOpacity(0.08)),
                    bottom: BorderSide(color: Colors.white.withOpacity(0.08)),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TRENDING IN YOUR HOOD',
                      style: GoogleFonts.hankenGrotesk(
                        color: saffron,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'New Public Library Wing',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.local_fire_department, color: green, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '1.2k supporting · Growing fast',
                          style: GoogleFonts.inter(
                            color: green,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Filter Row
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildFilterChip('All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Most Supported'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Newest'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Facilities'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Infrastructure'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Feed list
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: wishes.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Text(
                        'No wishes matching this filter.',
                        style: GoogleFonts.inter(color: Colors.white38),
                      ),
                    ),
                  )
                : Column(
                    children: wishes.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _buildWishCard(item),
                      );
                    }).toList(),
                  ),
            ),
            const SizedBox(height: 80),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? saffron : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? saffron : Colors.white.withOpacity(0.12),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.hankenGrotesk(
              color: isActive ? Colors.black : Colors.white,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWishCard(WishItem item) {
    return Container(
      decoration: BoxDecoration(
        color: darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(height: 160, width: double.infinity, color: Colors.grey[900]),
              Image.network(
                item.imageUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 160, 
                  color: Colors.grey[900],
                  child: const Center(child: Icon(Icons.star_outline, color: Colors.white24, size: 40)),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Row(
                  children: [
                    _buildOverlayChip(item.category),
                    const SizedBox(width: 8),
                    _buildOverlayChip(item.area),
                  ],
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.isSupported ? green : saffron,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${item.supportCount} supporting',
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.desc,
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Facepile
                    Row(
                      children: [
                        _buildFacepileAvatar('https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=80'),
                        const SizedBox(width: 4),
                        _buildFacepileAvatar('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=80'),
                        const SizedBox(width: 4),
                        _buildFacepileAvatar('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80'),
                        if (item.excessFaces > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white10,
                              border: Border.all(color: darkSurface, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                '+${item.excessFaces}',
                                style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Row(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: item.isSupported ? green : saffron,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          onPressed: () => _toggleSupport(item),
                          child: Text(
                            item.isSupported ? 'Supported ✓' : 'Support',
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(color: Colors.white.withOpacity(0.12)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Wish link copied to clipboard! Share with your block.'),
                                backgroundColor: saffron,
                              ),
                            );
                          },
                          child: Text(
                            'Share',
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlayChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.hankenGrotesk(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildFacepileAvatar(String url) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: darkSurface, width: 2),
        image: DecorationImage(
          image: NetworkImage(url),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

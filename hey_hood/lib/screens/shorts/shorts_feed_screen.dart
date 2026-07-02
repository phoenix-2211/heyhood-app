import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hey_hood/core/constants/app_colors.dart';
import 'package:hey_hood/screens/shorts/beach_walkway_detail_screen.dart';
import 'package:hey_hood/services/firestore_service.dart';
import 'package:hey_hood/models/models.dart';

class ShortsFeedScreen extends StatefulWidget {
  const ShortsFeedScreen({super.key});

  @override
  State<ShortsFeedScreen> createState() => _ShortsFeedScreenState();
}

class _ShortsFeedScreenState extends State<ShortsFeedScreen> {
  final PageController _pageController = PageController();

  final List<Map<String, dynamic>> _stories = [
    {
      'title': 'Karaikal locals flag poorly lit beach walkway',
      'location': 'BEACH PROMENADE • KARAIKAL',
      'time': '2 hours ago',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCxg4te4qfMkKKwaYZrVWutsw2CjtG3v9tQnXSVYqFlEWGYvay9TwgITUfcK4P5NSuJg7kumLR50DGtM6-2mREq1f0BbgzgI6qCVx5RcIbRFEoh1UGVKKqV0lTKU0U2koEfaPs2dMzKzbtL7cd1Ky3MADtLY1jr1NW0XzKfMqjYbvbbOsNoBpJ-QoIBBh5TlIVFhSXQ-Lcr3e1NMIewaHyWktaLWZLe1at5n-fRKcWNT6N_HTMIP68pB_wwk8z5rulTI9hmhGugVewN',
      'description': 'Residents report that over 60% of the street lamps along the Beach Promenade have been non-functional for weeks, creating safety concerns for evening walkers and tourists. Local authorities have been notified but repairs are pending.',
      'supportCount': 142,
      'isSupported': false,
      'isBookmarked': false,
    },
    {
      'title': 'Ward 170 garbage blackspot cleared by citizen drive',
      'location': '5TH CROSS • KORAMANGALA',
      'time': '5 hours ago',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDfgUNlkLCh4YWI_sax0zGQ2p7sR4u7GBe6v566Lp3YDMI9rRus1Amkk4sWBrCHgGo6d9LeWCzH6R5H0EBO165ACz5L3VMmW3WVu616GRll3dOwihTt2Lfbv_V2ZaxpV0lmJi5x_SVEyYcMjw91PlOB9yNHqpHdJdb3zBycyJ73PZktH6SyzoQwOsTHFY-eUyxoo3BiTBK_7UiY4YE36KMrnC1_VjbHPU4DZR6iR3n-CpL3-gOz_6JJnSQ0fgxRjKphLqiFPxuIyc5K',
      'description': 'A group of 15 residents teamed up today to clear a persistent garbage dump at 5th Cross. BBMP supported the drive by sending a truck to cart away the collected waste. The spot has now been converted into a micro-garden.',
      'supportCount': 89,
      'isSupported': false,
      'isBookmarked': false,
    },
    {
      'title': 'Stray dog vaccination drive logs 80 pets & strays',
      'location': 'ST. JOHN\'S ROAD • WARD 151',
      'time': '1 day ago',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDKSPynJzbnnIqIa5hdeKN8na4CdLHHD8usykyL1ZH89f2FI2keeGvlfzQ9pXwk4stL6ua5yJDF4X7K0OemjOkQqIH5VHTqYSjbbQpsTqSi9UqwpBOjJWoxXF4VXWZLXPcPtRBRBLJw5Armoo1O30M1YVSvCjSu4sgHJyVp8cb9PztihaDXEr6fAyifyIqJ4vPhQys4O2zihL88ITIEWIgnBU7XbRVUN1FDCqW2Ux1sGUBYcGGA6O1oJ6U3zV5kFWJt1ddBCQUP5sJD',
      'description': 'The local animal welfare group, in partnership with Cessna Lifeline, successfully completed a rabies vaccination and health check drive. Ward 170 Councillor Ramesh Kumar visited the camp and promised municipal aid.',
      'supportCount': 214,
      'isSupported': false,
      'isBookmarked': false,
    }
  ];

  void _toggleSupport(int index) {
    setState(() {
      final story = _stories[index];
      if (story['isSupported']) {
        story['isSupported'] = false;
        story['supportCount']--;
      } else {
        story['isSupported'] = true;
        story['supportCount']++;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Support registered! Councillor notified.'), backgroundColor: green),
        );
      }
    });
  }

  void _toggleBookmark(int index) {
    setState(() {
      final story = _stories[index];
      story['isBookmarked'] = !story['isBookmarked'];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_stories[index]['isBookmarked'] ? 'Story saved to bookmarks.' : 'Story removed from bookmarks.'),
        backgroundColor: saffron,
      ),
    );
  }

  void _shareStory(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Short link copied to clipboard! Share with your neighborhood.'), backgroundColor: saffron),
    );
  }

  void _reportStory(int index) {
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
                'Report Short Story',
                style: GoogleFonts.hankenGrotesk(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.warning, color: saffron),
                title: const Text('False Information', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted. Thank you.'), backgroundColor: green));
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: saffron),
                title: const Text('Spam or Repetitive', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted. Thank you.'), backgroundColor: green));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      body: Stack(
        children: [
          // Scrollable Vertical PageView
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: _stories.length,
            itemBuilder: (context, index) {
              final story = _stories[index];
              return Column(
                children: [
                  // Space for the overlapping header
                  const SizedBox(height: 100),
                  
                  // Main Interactive Card / Image Section (70% weight)
                  Expanded(
                    flex: 7,
                    child: Stack(
                      children: [
                        // Main image
                        Positioned.fill(
                          child: Image.network(
                            story['image'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(color: Colors.black),
                          ),
                        ),
                        // Ambient bottom vignette
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  darkBg.withOpacity(0.5),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Floating Actions on the right side
                        Positioned(
                          right: 16,
                          bottom: 24,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildFloatingActionButton(
                                story['isSupported'] ? Icons.favorite : Icons.favorite_border,
                                color: story['isSupported'] ? Colors.red : Colors.white,
                                label: '${story['supportCount']}',
                                onTap: () => _toggleSupport(index),
                              ),
                              const SizedBox(height: 16),
                              _buildFloatingActionButton(
                                story['isBookmarked'] ? Icons.bookmark : Icons.bookmark_border,
                                color: story['isBookmarked'] ? saffron : Colors.white,
                                label: 'Save',
                                onTap: () => _toggleBookmark(index),
                              ),
                              const SizedBox(height: 16),
                              _buildFloatingActionButton(
                                Icons.share,
                                label: 'Share',
                                onTap: () => _shareStory(index),
                              ),
                              const SizedBox(height: 16),
                              _buildFloatingActionButton(
                                Icons.flag_outlined,
                                label: 'Report',
                                onTap: () => _reportStory(index),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Story Details section (30% weight)
                  Expanded(
                    flex: 4,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      color: darkBg,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            story['title'],
                            style: GoogleFonts.hankenGrotesk(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                story['location'],
                                style: GoogleFonts.hankenGrotesk(
                                  color: saffron,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 3,
                                height: 3,
                                decoration: const BoxDecoration(
                                  color: Colors.white30,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                story['time'],
                                style: GoogleFonts.inter(
                                  color: Colors.white54,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            story['description'],
                            style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 13,
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const BeachWalkwayDetailScreen(),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'READ FULL BRIEFING',
                                  style: GoogleFonts.hankenGrotesk(
                                    color: saffron,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.chevron_right,
                                  color: saffron,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          
          // Custom Overlay Header Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              padding: const EdgeInsets.only(top: 36, left: 16, right: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
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
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: saffron),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No new updates.')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(
    IconData icon, {
    Color? color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
              ),
            ),
            child: Icon(
              icon,
              color: color ?? Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.hankenGrotesk(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

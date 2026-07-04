import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hey_hood/core/constants/app_colors.dart';
import 'package:hey_hood/models/wish_model.dart';
import 'package:hey_hood/services/firestore_service.dart';

class NewsShortDetailScreen extends StatefulWidget {
  final List<Wish> wishes;
  final int initialIndex;

  const NewsShortDetailScreen({
    super.key,
    required this.wishes,
    required this.initialIndex,
  });

  @override
  State<NewsShortDetailScreen> createState() => _NewsShortDetailScreenState();
}

class _NewsShortDetailScreenState extends State<NewsShortDetailScreen> {
  late PageController _pageController;
  late int _currentIndex;
  final Map<String, int> _supports = {};
  final Map<String, bool> _hasSupported = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    
    // Initialize support counts
    for (var wish in widget.wishes) {
      _supports[wish.wishId] = wish.supportCount;
      _hasSupported[wish.wishId] = false;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleSupport(String wishId) {
    setState(() {
      if (_hasSupported[wishId] == true) {
        _hasSupported[wishId] = false;
        _supports[wishId] = (_supports[wishId] ?? 1) - 1;
      } else {
        _hasSupported[wishId] = true;
        _supports[wishId] = (_supports[wishId] ?? 0) + 1;
        // Optionally update Firestore
        FirestoreService().supportWish(wishId, "USR-CURRENT-DEMO");
      }
    });
  }

  void _showCommentsSheet(Wish wish) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161515),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Comments',
                style: GoogleFonts.hankenGrotesk(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _buildCommentItem('Ramesh Kumar', 'This is desperately needed. The depot gets so crowded in the afternoons.', '2h ago'),
                    _buildCommentItem('Selvi Ramasamy', 'Solar powered backup would make this even better!', '5h ago'),
                    _buildCommentItem('Karthik Raja', 'Glad to see this is trending. Supporting!', '1d ago'),
                  ],
                ),
              ),
              // Write a comment input field
              Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                    hintStyle: const TextStyle(color: Colors.white30),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send, color: saffron),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentItem(String author, String text, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: saffron.withOpacity(0.1),
            radius: 16,
            child: Text(author[0], style: const TextStyle(color: saffron, fontSize: 12)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(author, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Text(time, style: const TextStyle(color: Colors.white38, fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(text, style: const TextStyle(color: Colors.white, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRelatedWishesSheet(Wish currentWish) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161515),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final related = widget.wishes.where((w) => w.wishId != currentWish.wishId).toList();
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Related Updates in this Ward',
                style: GoogleFonts.hankenGrotesk(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: related.isEmpty
                    ? const Center(child: Text('No other items in this ward', style: TextStyle(color: Colors.white38)))
                    : ListView.builder(
                        itemCount: related.length,
                        itemBuilder: (context, idx) {
                          final item = related[idx];
                          return Card(
                            color: Colors.white.withOpacity(0.03),
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(item.imageUrl, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: Colors.black)),
                              ),
                              title: Text(item.title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                              subtitle: Text('${item.supportCount} Supports · ${item.category}', style: const TextStyle(color: saffron, fontSize: 11)),
                              onTap: () {
                                Navigator.pop(context);
                                final newIdx = widget.wishes.indexOf(item);
                                if (newIdx != -1) {
                                  _pageController.animateToPage(
                                    newIdx,
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Vertical PageView for Reels effect
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: widget.wishes.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final wish = widget.wishes[index];
              final hasSupported = _hasSupported[wish.wishId] ?? false;
              final supportCount = _supports[wish.wishId] ?? wish.supportCount;

              return Stack(
                children: [
                  // Full Screen Background Image
                  Positioned.fill(
                    child: Image.network(
                      wish.imageUrl.isNotEmpty ? wish.imageUrl : 'https://images.unsplash.com/photo-1509391366360-2e959784a276?auto=format&fit=crop&w=800&q=80',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(color: Colors.black),
                    ),
                  ),
                  // Dark radial/linear gradient overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.2),
                            Colors.black.withOpacity(0.7),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.55),
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withOpacity(0.9),
                          ],
                          stops: const [0.0, 0.2, 0.65, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Content Layout Overlay (Reels Style)
                  Positioned(
                    left: 16,
                    bottom: 84,
                    right: 76,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category and Severity pills
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: saffron.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: saffron, width: 1),
                              ),
                              child: Text(
                                wish.category.toUpperCase(),
                                style: const TextStyle(color: saffron, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                "TRENDING",
                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Headline
                        Text(
                          wish.title,
                          style: GoogleFonts.hankenGrotesk(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Description
                        Text(
                          wish.description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.hankenGrotesk(
                            color: Colors.white70,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Time & Ward details
                        Row(
                          children: [
                            const Icon(Icons.access_time, color: Colors.white38, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              "Posted 2 days ago · Ward ${wish.wardId.split('-').last}",
                              style: const TextStyle(color: Colors.white38, fontSize: 11),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Horizontal progress stepper
                        _buildStatusStepper(wish.status),
                      ],
                    ),
                  ),

                  // Right side vertical action rail
                  Positioned(
                    right: 12,
                    bottom: 120,
                    child: Column(
                      children: [
                        // Support (Reactions)
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () => _toggleSupport(wish.wishId),
                              child: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: hasSupported ? saffron.withOpacity(0.2) : Colors.black38,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: hasSupported ? saffron : Colors.white24, width: 1.5),
                                ),
                                child: Icon(
                                  hasSupported ? Icons.back_hand : Icons.back_hand_outlined,
                                  color: hasSupported ? saffron : Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$supportCount',
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        // Comments
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () => _showCommentsSheet(wish),
                              child: Container(
                                height: 50,
                                width: 50,
                                decoration: const BoxDecoration(
                                  color: Colors.black38,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.mode_comment_outlined, color: Colors.white, size: 22),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '3',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        // Share
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Link copied to clipboard!'), backgroundColor: saffron),
                                );
                              },
                              child: Container(
                                height: 50,
                                width: 50,
                                decoration: const BoxDecoration(
                                  color: Colors.black38,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.share_outlined, color: Colors.white, size: 22),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Share',
                              style: TextStyle(color: Colors.white38, fontSize: 9),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        // Report
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Report submitted for human review.'), backgroundColor: danger),
                                );
                              },
                              child: Container(
                                height: 50,
                                width: 50,
                                decoration: const BoxDecoration(
                                  color: Colors.black38,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.flag_outlined, color: Colors.white, size: 22),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Report',
                              style: TextStyle(color: Colors.white38, fontSize: 9),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Swipe Up Indicator Hint
                  Positioned(
                    bottom: 56,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.keyboard_double_arrow_up, color: Colors.white38, size: 16),
                          const SizedBox(height: 2),
                          Text(
                            "Swipe up for next trending update",
                            style: GoogleFonts.hankenGrotesk(color: Colors.white38, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Top Header (Constant Over all Pages)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    // Stories progress bar segments
                    Row(
                      children: List.generate(widget.wishes.length, (idx) {
                        return Expanded(
                          child: Container(
                            height: 3,
                            margin: const EdgeInsets.symmetric(horizontal: 2.0),
                            decoration: BoxDecoration(
                              color: idx <= _currentIndex ? saffron : Colors.white24,
                              borderRadius: BorderRadius.circular(1.5),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.location_on, color: saffron, size: 12),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Ward ${widget.wishes[_currentIndex].wardId.split('-').last} · Adyar",
                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_vert, color: Colors.white),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Sheet Expand Trigger Peak
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _showRelatedWishesSheet(widget.wishes[_currentIndex]),
              child: Container(
                height: 50,
                decoration: const BoxDecoration(
                  color: Color(0xFF161515),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -3)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Related updates in this ward",
                      style: GoogleFonts.hankenGrotesk(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_ios, color: saffron, size: 10),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Horizontal Stepper widget for Status: Posted -> Notified -> In Progress -> Resolved
  Widget _buildStatusStepper(String status) {
    final steps = ['Posted', 'Notified', 'In Progress', 'Resolved'];
    
    // Determine active index
    int activeIdx = 0;
    if (status == 'Notified') activeIdx = 1;
    if (status == 'In Progress') activeIdx = 2;
    if (status == 'Resolved') activeIdx = 3;

    return Row(
      children: List.generate(steps.length, (index) {
        final stepName = steps[index];
        final isActive = index <= activeIdx;
        
        return Expanded(
          child: Row(
            children: [
              // Stepper Line (except first)
              if (index > 0)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isActive ? saffron : Colors.white12,
                  ),
                ),
              // Stepper Node
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 8,
                    width: 8,
                    decoration: BoxDecoration(
                      color: isActive ? saffron : Colors.white24,
                      shape: BoxShape.circle,
                      boxShadow: isActive
                          ? [BoxShadow(color: saffron.withOpacity(0.5), blurRadius: 4, spreadRadius: 1)]
                          : [],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stepName,
                    style: TextStyle(
                      color: isActive ? saffron : Colors.white30,
                      fontSize: 8,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              if (index < steps.length - 1) const SizedBox(width: 4),
            ],
          ),
        );
      }),
    );
  }
}

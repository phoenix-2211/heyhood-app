import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hey_hood/core/constants/app_colors.dart';

class BeachWalkwayDetailScreen extends StatefulWidget {
  const BeachWalkwayDetailScreen({super.key});

  @override
  State<BeachWalkwayDetailScreen> createState() => _BeachWalkwayDetailScreenState();
}

class _BeachWalkwayDetailScreenState extends State<BeachWalkwayDetailScreen> {
  bool _isSupporting = false;
  int _supportCount = 127;

  void _onSupport() {
    setState(() {
      if (_isSupporting) {
        _isSupporting = false;
        _supportCount--;
      } else {
        _isSupporting = true;
        _supportCount++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      body: Stack(
        children: [
          // Scrollable content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Image & Vignette
                Stack(
                  children: [
                    Container(
                      height: 480,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuDXZk9KEZFarhVhd0BaY1F8qrLzT8Q03a5y7PthRTj_j6S1uOEiHttX87qpl137HkJ6HFJ9F33mbgys1OcmIIhW8KfH8iiqxbayGp_tFccW8W_8rdJQWoq2CTKA01s8Pjq35KdR9cnzwfRuuoalffiXEwnYxcz6Euh66oCDUpP8ZbhOwdgFjlpfXd068O8BDYSOloXeDfuAga7-wxktuDA8HqsY283BH1UWpk-pZ_U8NuY3zddqSQzFs2L-3qFdeN9UXBHhZyWrFkk9',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      height: 480,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            darkBg.withOpacity(0.9),
                            darkBg,
                          ],
                          stops: const [0.0, 0.7, 1.0],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: saffron,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'SAFETY ISSUE',
                                  style: GoogleFonts.hankenGrotesk(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Ref: #KRK-4921',
                                style: GoogleFonts.hankenGrotesk(
                                  color: saffron,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Flickering Lighting Hazards at Karaikal Beach Walkway',
                            style: GoogleFonts.hankenGrotesk(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          RichText(
                            text: TextSpan(
                              style: GoogleFonts.hankenGrotesk(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 12,
                              ),
                              children: const [
                                TextSpan(text: 'Reported by '),
                                TextSpan(
                                  text: 'J. Dawson',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: ' • Oct 12, 2023'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Metrics Bento box
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildBentoCard(Icons.groups, '$_supportCount', 'Neighbors'),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildBentoCard(Icons.forum, '23', 'Comments'),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildBentoCard(Icons.warning, '08', 'Similar'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Narrative Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Case Briefing',
                        style: GoogleFonts.hankenGrotesk(
                          color: saffron,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'A comprehensive survey of the Karaikal Beach Walkway reveals that nearly 40% of the ornamental street lamps are currently non-functional or exhibiting severe flickering issues.',
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'This lapse in infrastructure has created significant dark zones throughout the popular evening stretch, posing immediate safety risks to families and lone walkers. Furthermore, residents have reported visible sparks near the lamp bases, suggesting potential short-circuit hazards caused by saline air erosion.',
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Official Oversight Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: darkSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'OFFICIAL OVERSIGHT',
                              style: GoogleFonts.hankenGrotesk(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const Icon(
                              Icons.verified,
                              color: saffron,
                              size: 18,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: saffron.withOpacity(0.2)),
                                image: const DecorationImage(
                                  image: NetworkImage(
                                    'https://lh3.googleusercontent.com/aida-public/AB6AXuC9gsXxRNlV-tMW4-eSVPAxipEDn_72wkdiHIPwElHFRyxvGIyh1FaVK5GArTdgE3BGfmnE9ublIAClTFhMN6xNxHrk3zNmfiDByh0Fhm6lxVZlkY9guggAkOEIznMJRA8Wvi6HT2f8A7teZS4jpUxqevyeSdHfxljubgfJBc7h8OVPdfaB7B9VrecJtGi3peiPcY-ivXEEVCczFmHJcWTqrT3B4xGVj1fRhq1bPcMTibSZmzSStKTPryVPzc6ngVfQthnocftkH9MS',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Eng. K. Rajasekaran',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Municipal Public Works (MPW)',
                                  style: GoogleFonts.hankenGrotesk(
                                    color: saffron,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(height: 1, color: Colors.white10),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'EXPECTED REVIEW',
                              style: GoogleFonts.hankenGrotesk(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                            Text(
                              'Oct 19, 2023',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Roadmap timeline
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resolution Roadmap',
                        style: GoogleFonts.hankenGrotesk(
                          color: saffron,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildRoadmapStep("Reported", "Oct 12 • Community Consensus Reached", true, true),
                      _buildRoadmapStep("Notified Department", "Oct 13 • Official Ticket #MPW-2023-X9", true, true),
                      _buildRoadmapStep("Scheduled Inspection", "Oct 16 • Field Crew Dispatched", false, true),
                      _buildRoadmapStep("In Progress", "Awaiting Engineer Log", false, false),
                      _buildRoadmapStep("Resolved", "Completion Verification", false, false, isLast: true),
                    ],
                  ),
                ),
                const SizedBox(height: 120), // Bottom padding for support bar
              ],
            ),
          ),
          // Top Navigation Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                color: Colors.black.withOpacity(0.4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Text(
                      'DETAIL BRIEFING',
                      style: GoogleFonts.hankenGrotesk(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Fixed Bottom Support Action Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              decoration: BoxDecoration(
                color: darkBg.withOpacity(0.8),
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.08)),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSupporting ? Colors.green[800] : saffron,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _onSupport,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isSupporting ? Icons.check_circle : Icons.thumb_up,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _isSupporting ? 'Support Added' : 'Add Your Support',
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoCard(IconData icon, String count, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: saffron, size: 20),
          const SizedBox(height: 8),
          Text(
            count,
            style: GoogleFonts.hankenGrotesk(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.hankenGrotesk(
              color: Colors.white.withOpacity(0.4),
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoadmapStep(
    String title,
    String subtitle,
    bool isActive,
    bool isCompleted, {
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: isCompleted ? saffron : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted ? saffron : Colors.white24,
                    width: 2,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: saffron.withOpacity(0.4),
                            blurRadius: 8,
                          )
                        ]
                      : null,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isCompleted ? saffron.withOpacity(0.5) : Colors.white10,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: isCompleted ? Colors.white : Colors.white.withOpacity(0.4),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    color: isCompleted ? Colors.white.withOpacity(0.6) : Colors.white.withOpacity(0.3),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

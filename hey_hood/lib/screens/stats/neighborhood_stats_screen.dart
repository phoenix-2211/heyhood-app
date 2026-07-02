import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hey_hood/core/constants/app_colors.dart';
import 'package:hey_hood/services/firestore_service.dart';
import 'package:hey_hood/models/models.dart';

class NeighborhoodStatsScreen extends StatelessWidget {
  const NeighborhoodStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: saffron),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stats',
              style: GoogleFonts.hankenGrotesk(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              ''+FirestoreService.currentWardName+' • Ward '+FirestoreService.currentWardId.split('-').last+' • Live',
              style: GoogleFonts.hankenGrotesk(
                color: Colors.white.withOpacity(0.4),
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: saffron.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: saffron.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on, color: saffron, size: 14),
                const SizedBox(width: 4),
                Text(
                  FirestoreService.currentWardName,
                  style: GoogleFonts.hankenGrotesk(
                    color: saffron,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(Icons.expand_more, color: saffron, size: 14),
              ],
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Issue>>(
        stream: FirestoreService().getIssuesByWard(FirestoreService.currentWardId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final issues = snapshot.data!;
          final total = issues.length;
          final resolved = issues.where((i) => i.status == 'Resolved').length;
          final active = issues.where((i) => i.status == 'In Progress' || i.status == 'Notified' || i.status == 'Posted').length;
          final now = DateTime.now();
          final overdue = issues.where((i) => i.status != 'Resolved' && i.resolutionDeadline != null && i.resolutionDeadline!.isBefore(now)).length;
          
          final resRate = total > 0 ? (resolved / total) : 0.0;
          final resRatePercent = (resRate * 100).toInt();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Grid (4 items)
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.3,
                  children: [
                    _buildStatSummaryCard('Total Issues', total.toString(), 'Live count', Colors.white, Colors.green),
                    _buildStatSummaryCard('Resolved', resolved.toString(), 'Completed', Colors.green, Colors.green),
                    _buildStatSummaryCard('Active Issues', active.toString(), 'In progress', saffron, saffron),
                    _buildStatSummaryCard('Overdue', overdue.toString(), 'Urgent priority', danger, danger),
                  ],
                ),
            const SizedBox(height: 20),
            // Overall Resolution Rate Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: darkSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'OVERALL RESOLUTION RATE',
                        style: GoogleFonts.hankenGrotesk(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        '$resRatePercent%',
                        style: GoogleFonts.hankenGrotesk(
                          color: saffron,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      height: 8,
                      child: LinearProgressIndicator(
                        value: resRate,
                        backgroundColor: Colors.white10,
                        valueColor: const AlwaysStoppedAnimation<Color>(saffron),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Active Problems By Category
            Text(
              'Active problems by tag',
              style: GoogleFonts.hankenGrotesk(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTagChip('Sewage', '7', danger),
                _buildTagChip('Road', '6', danger),
                _buildTagChip('Electricity', '4', saffron),
                _buildTagChip('Water', '3', saffron),
                _buildTagChip('Safety', '2', saffron),
                _buildTagChip('Garbage', '1', Colors.green),
              ],
            ),
            const SizedBox(height: 24),
            // Resolution Graph
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: darkSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "This month's progress",
                    style: GoogleFonts.hankenGrotesk(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildGraphBarColumn('W1', 0.6, 0.45),
                      _buildGraphBarColumn('W2', 0.8, 0.55),
                      _buildGraphBarColumn('W3', 0.4, 0.35),
                      _buildGraphBarColumn('W4', 0.95, 0.7),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(height: 1, color: Colors.white10),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Container(width: 8, height: 8, decoration: const BoxDecoration(color: saffron, shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text('Issues Raised', style: GoogleFonts.hankenGrotesk(color: Colors.white70, fontSize: 9)),
                        ],
                      ),
                      const SizedBox(width: 24),
                      Row(
                        children: [
                          Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text('Resolved', style: GoogleFonts.hankenGrotesk(color: Colors.white70, fontSize: 9)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Issues List Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Issues this month',
                  style: GoogleFonts.hankenGrotesk(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.sort, color: saffron, size: 16),
                  label: Text('SORT', style: GoogleFonts.hankenGrotesk(color: saffron, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildIssueProgressCard(
              'Sewage',
              'Day 14',
              '42',
              'Blocked drainage on 4th Block main road',
              'N. Venkatesh',
              1.0,
            ),
            const SizedBox(height: 12),
            _buildIssueProgressCard(
              'Road',
              'Day 7',
              '18',
              'Large pothole at 80ft Road intersection',
              'K. Somashekhar',
              0.5,
            ),
            const SizedBox(height: 24),
            // Official Performance
            Text(
              'Official Performance',
              style: GoogleFonts.hankenGrotesk(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: darkSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: saffron.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            'NV',
                            style: GoogleFonts.hankenGrotesk(
                              color: saffron,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'N. Venkatesh',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Assistant Engineer (BBMP)',
                              style: GoogleFonts.hankenGrotesk(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '64%',
                            style: GoogleFonts.hankenGrotesk(
                              color: Colors.green,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'RATING',
                            style: GoogleFonts.hankenGrotesk(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 8,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: const SizedBox(
                      height: 6,
                      child: LinearProgressIndicator(
                        value: 0.64,
                        backgroundColor: Colors.white10,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildPerformanceMetric('28', 'Assigned')),
                      const SizedBox(width: 8),
                      Expanded(child: _buildPerformanceMetric('18', 'Resolved', labelColor: Colors.green)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildPerformanceMetric('4', 'Overdue', labelColor: danger)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      );
    },
  ),
    );
  }

  Widget _buildStatSummaryCard(String title, String count, String trend, Color countColor, Color trendColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.toUpperCase(),
            style: GoogleFonts.hankenGrotesk(
              color: Colors.white.withOpacity(0.4),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            count,
            style: GoogleFonts.hankenGrotesk(
              color: countColor,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          Row(
            children: [
              Icon(Icons.trending_up, color: trendColor, size: 12),
              const SizedBox(width: 4),
              Text(
                trend,
                style: GoogleFonts.hankenGrotesk(
                  color: trendColor,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(String name, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name.toUpperCase(),
            style: GoogleFonts.hankenGrotesk(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            count,
            style: GoogleFonts.hankenGrotesk(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraphBarColumn(String week, double raisedVal, double resolvedVal) {
    return Column(
      children: [
        Container(
          height: 100,
          width: 24,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 100 * raisedVal,
                width: 6,
                decoration: const BoxDecoration(
                  color: saffron,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
                ),
              ),
              const SizedBox(width: 2),
              Container(
                height: 100 * resolvedVal,
                width: 6,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          week,
          style: GoogleFonts.hankenGrotesk(
            color: Colors.white.withOpacity(0.4),
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildIssueProgressCard(
    String tag,
    String duration,
    String heartVal,
    String title,
    String assignee,
    double progress,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: danger.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tag.toUpperCase(),
                      style: GoogleFonts.hankenGrotesk(color: danger, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      duration,
                      style: GoogleFonts.hankenGrotesk(color: Colors.white70, fontSize: 9),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.white30, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    heartVal,
                    style: GoogleFonts.hankenGrotesk(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: GoogleFonts.hankenGrotesk(color: Colors.white.withOpacity(0.4), fontSize: 11),
              children: [
                const TextSpan(text: 'Assigned to: '),
                TextSpan(text: assignee, style: const TextStyle(color: saffron, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Horizontal step nodes progress
          Row(
            children: [
              _buildStepDot('Posted', progress >= 0.25),
              _buildStepLine(progress >= 0.5),
              _buildStepDot('Notified', progress >= 0.5),
              _buildStepLine(progress >= 0.75),
              _buildStepDot('Scheduled', progress >= 0.75),
              _buildStepLine(progress >= 1.0),
              _buildStepDot('Resolved', progress >= 1.0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepDot(String label, bool isCompleted) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isCompleted ? saffron : Colors.white24,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.hankenGrotesk(
              color: isCompleted ? Colors.white70 : Colors.white24,
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(bool isCompleted) {
    return Container(
      width: 24,
      height: 1,
      color: isCompleted ? saffron.withOpacity(0.4) : Colors.white10,
    );
  }

  Widget _buildPerformanceMetric(String val, String label, {Color? labelColor}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            val,
            style: GoogleFonts.hankenGrotesk(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.hankenGrotesk(
              color: labelColor ?? Colors.white.withOpacity(0.4),
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

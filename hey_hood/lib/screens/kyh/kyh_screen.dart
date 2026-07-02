import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hey_hood/core/constants/app_colors.dart';
import 'package:hey_hood/screens/profile/citizen_settings_screen.dart';
import 'package:hey_hood/services/firestore_service.dart';
import 'package:hey_hood/models/models.dart';

class KyhScreen extends StatefulWidget {
  const KyhScreen({super.key});

  @override
  State<KyhScreen> createState() => _KyhScreenState();
}

class _KyhScreenState extends State<KyhScreen> {
  // Active call simulator state
  bool _isCalling = false;
  String _callTitle = "";
  String _callNumber = "";
  int _callSeconds = 0;
  Timer? _callTimer;

  // Active filter state
  String _selectedFilter = 'Officials';

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
        content: Text('Call with $_callTitle ended.'),
        backgroundColor: saffron,
      ),
    );
  }

  String _formatTimer(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _showRepDetails(String initials, String name, String role) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: darkSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: saffron.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: saffron, width: 2),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: GoogleFonts.hankenGrotesk(
                      color: saffron,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                name,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                role.toUpperCase(),
                style: GoogleFonts.hankenGrotesk(
                  color: saffron,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const Divider(color: Colors.white10, height: 24),
              _buildRepInfoRow('Jurisdiction', 'Ward 170 · Adyar'),
              _buildRepInfoRow('Response SLA', '98.5% within 24h'),
              _buildRepInfoRow('Initiatives', '7 active drives'),
              const Divider(color: Colors.white10, height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Message feature is in preview mode.')),
                        );
                      },
                      child: const Text('Message'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: saffron,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _startCall(name, '044-4552-8210');
                      },
                      child: const Text('Call'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showHospitalDirections() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: darkSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Directions to Manipal Hospital',
            style: GoogleFonts.hankenGrotesk(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDirectionStep('1', 'Head North on 80 Feet Road (200m)'),
              _buildDirectionStep('2', 'At the roundabout, take the 3rd exit (350m)'),
              _buildDirectionStep('3', 'Merge onto HAL Old Airport Rd (250m)'),
              _buildDirectionStep('4', 'Destination will be on your left'),
              const Divider(color: Colors.white10, height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: saffron,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Start Navigation'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showServiceDetailSheet(String serviceName) {
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
                '$serviceName Locations near you',
                style: GoogleFonts.hankenGrotesk(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildServiceDetailTile('Adyar 3rd Block Branch', '0.4 km away · Open'),
              _buildServiceDetailTile('National Games Village Branch', '0.8 km away · Open'),
              _buildServiceDetailTile('Indiranagar Metro Point Hub', '2.5 km away · Open'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRepInfoRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(color: Colors.white30, fontSize: 12)),
          Text(val, style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDirectionStep(String step, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: saffron,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step,
                style: GoogleFonts.hankenGrotesk(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceDetailTile(String name, String desc) {
    return ListTile(
      leading: const Icon(Icons.location_on, color: saffron),
      title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(desc, style: const TextStyle(color: Colors.white38, fontSize: 12)),
      trailing: const Icon(Icons.directions, color: saffron, size: 20),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Starting route to $name...'), backgroundColor: green),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.4),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'HEY HOOD',
          style: GoogleFonts.hankenGrotesk(
            color: saffron,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: -1,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white70),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new official updates for Ward 170.')),
              );
            },
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CitizenSettingsScreen()),
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
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title & Location Capsule
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Know Your Hood',
                        style: GoogleFonts.hankenGrotesk(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: darkSurface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on, color: saffron, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'WARD ' + (FirestoreService.currentWardId.split('-').last),
                              style: GoogleFonts.hankenGrotesk(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Filter row
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildFilterChip('Officials'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Services'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Utilities'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                if (_selectedFilter == 'Officials') ...[
                  // Representatives Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Representatives',
                          style: GoogleFonts.hankenGrotesk(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Horizontal Representatives Scroll
                        SizedBox(
                          height: 72,
                          child: FutureBuilder<List<Official>>(
                            future: FirestoreService().getOfficialsByWard(FirestoreService.currentWardId),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              final officials = snapshot.data!;
                              if (officials.isEmpty) {
                                return const Center(
                                  child: Text(
                                    "No officials found for this ward.",
                                    style: TextStyle(color: Colors.white38, fontSize: 12),
                                  ),
                                );
                              }
                              return ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: officials.length,
                                itemBuilder: (context, index) {
                                  final official = officials[index];
                                  // Get initials
                                  final initials = official.name.isNotEmpty
                                      ? official.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
                                      : 'OF';
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 12.0),
                                    child: _buildMiniRepCard(initials, official.name.isNotEmpty ? official.name : official.designation, official.designation),
                                  );
                                },
                              );
                            }
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                // Emergency Contacts Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(width: 3, height: 18, color: danger),
                          const SizedBox(width: 8),
                          Text(
                            'Emergency Contacts',
                            style: GoogleFonts.hankenGrotesk(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildEmergencyBox('Ambulance', '108', 'assets/images/ambulance.png')),
                          const SizedBox(width: 12),
                          Expanded(child: _buildEmergencyBox('Fire Station', '101', 'assets/images/fire_station.png')),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => _startCall('Adyar Police', '044-2295-0001'),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: darkSurface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.04)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Adyar Police Station',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '0.8km • 044-2295-0001',
                                    style: GoogleFonts.inter(
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: saffron.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: saffron.withOpacity(0.2)),
                                ),
                                child: const Icon(Icons.call, color: saffron, size: 20),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Healthcare Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(width: 3, height: 18, color: saffron),
                          const SizedBox(width: 8),
                          Text(
                            'Nearby Healthcare',
                            style: GoogleFonts.hankenGrotesk(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: darkSurface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                Container(
                                  height: 120,
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        'https://lh3.googleusercontent.com/aida-public/AB6AXuDfgUNlkLCh4YWI_sax0zGQ2p7sR4u7GBe6v566Lp3YDMI9rRus1Amkk4sWBrCHgGo6d9LeWCzH6R5H0EBO165ACz5L3VMmW3WVu616GRll3dOwihTt2Lfbv_V2ZaxpV0lmJi5x_SVEyYcMjw91PlOB9yNHqpHdJdb3zBycyJ73PZktH6SyzoQwOsTHFY-eUyxoo3BiTBK_7UiY4YE36KMrnC1_VjbHPU4DZR6iR3n-CpL3-gOz_6JJnSQ0fgxRjKphLqiFPxuIyc5K',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'OPEN 24H',
                                      style: GoogleFonts.hankenGrotesk(
                                        color: Colors.black,
                                        fontSize: 8,
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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Manipal Hospital',
                                            style: GoogleFonts.inter(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'HAL Old Airport Rd • 0.8km away',
                                            style: GoogleFonts.inter(
                                              color: Colors.white.withOpacity(0.5),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.call, color: saffron),
                                        onPressed: () => _startCall('Manipal Hospital', '044-2502-4444'),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      _buildHospitalTag('Emergency'),
                                      const SizedBox(width: 8),
                                      _buildHospitalTag('ICU'),
                                      const SizedBox(width: 8),
                                      _buildHospitalTag('Radiology'),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 44,
                                    child: OutlinedButton(
                                      onPressed: _showHospitalDirections,
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        side: BorderSide(color: Colors.white.withOpacity(0.12)),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.directions, size: 16),
                                          const SizedBox(width: 8),
                                          Text('Get Directions', style: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => _startCall('Adyar Local Clinic', '044-1882-9011'),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: darkSurface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.04)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: saffron.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.medical_services, color: saffron, size: 20),
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Adyar Local Clinic',
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Opens 8:00 AM Tomorrow',
                                        style: GoogleFonts.hankenGrotesk(
                                          color: saffron,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.3)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Local Services Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Local Services',
                        style: GoogleFonts.hankenGrotesk(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 112,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _buildServiceBox('assets/images/post_office.png', 'Post Office', Colors.blue),
                            const SizedBox(width: 12),
                            _buildServiceBox('assets/images/atm.png', 'ATM', Colors.green),
                            const SizedBox(width: 12),
                            _buildServiceBox('assets/images/bus_stop.png', 'Bus Stop', amber),
                            const SizedBox(width: 12),
                            _buildServiceBox('assets/images/community.png', 'Community', Colors.purple),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Calls are verified via your Hey Hood account.',
                        style: GoogleFonts.hankenGrotesk(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.verified_user, color: Colors.white.withOpacity(0.2), size: 12),
                          const SizedBox(width: 4),
                          Text(
                            'SECURE INFRASTRUCTURE',
                            style: GoogleFonts.hankenGrotesk(
                              color: Colors.white.withOpacity(0.2),
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),

          // Dialer Simulator Overlay Panel
          if (_isCalling)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.92),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.phone_in_talk, color: saffron, size: 72),
                      const SizedBox(height: 32),
                      Text(
                        _callTitle,
                        style: GoogleFonts.hankenGrotesk(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _callNumber,
                        style: GoogleFonts.inter(
                          color: Colors.white54,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _formatTimer(_callSeconds),
                        style: GoogleFonts.hankenGrotesk(
                          color: saffron,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 64),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildDialerAction(Icons.mic_off, 'Mute'),
                          const SizedBox(width: 32),
                          _buildDialerAction(Icons.volume_up, 'Speaker'),
                          const SizedBox(width: 32),
                          _buildDialerAction(Icons.dialpad, 'Keypad'),
                        ],
                      ),
                      const SizedBox(height: 80),
                      FloatingActionButton(
                        backgroundColor: Colors.red,
                        onPressed: _endCall,
                        child: const Icon(Icons.call_end, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDialerAction(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.08),
            border: Border.all(color: Colors.white12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.hankenGrotesk(color: Colors.white60, fontSize: 12),
        ),
      ],
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? saffron : Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive ? saffron : Colors.white.withOpacity(0.08),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: isActive ? Colors.black : Colors.white.withOpacity(0.6),
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniRepCard(String initials, String name, String role) {
    return GestureDetector(
      onTap: () => _showRepDetails(initials, name, role),
      child: Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: darkSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.04)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: saffron.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: saffron.withOpacity(0.2)),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: GoogleFonts.inter(
                      color: saffron,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    role.toUpperCase(),
                    style: GoogleFonts.hankenGrotesk(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyBox(String label, String code, String assetPath) {
    return GestureDetector(
      onTap: () => _startCall(label, code),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: darkSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: danger.withOpacity(0.3), width: 1.5),
        ),
        child: Stack(
          children: [
            Positioned(
              right: 8,
              bottom: 8,
              child: Opacity(
                opacity: 0.18,
                child: Image.asset(
                  assetPath,
                  width: 56,
                  height: 56,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: GoogleFonts.hankenGrotesk(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    code,
                    style: GoogleFonts.hankenGrotesk(
                      color: saffron,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
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

  Widget _buildHospitalTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Text(
        text,
        style: GoogleFonts.hankenGrotesk(
          color: Colors.white.withOpacity(0.6),
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildServiceBox(String assetPath, String label, Color borderBottomColor) {
    return GestureDetector(
      onTap: () => _showServiceDetailSheet(label),
      child: Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: Container(
          width: 90,
          decoration: BoxDecoration(
            color: darkSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderBottomColor.withOpacity(0.4), width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                assetPath,
                width: 32,
                height: 32,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 8),
              Text(
                label.toUpperCase(),
                style: GoogleFonts.hankenGrotesk(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

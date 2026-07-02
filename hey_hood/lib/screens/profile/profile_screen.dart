import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hey_hood/core/constants/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Profile',
          style: GoogleFonts.hankenGrotesk(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Hero Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: darkSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Column(
                children: [
                  // S Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: saffron,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 4),
                      boxShadow: const [
                        BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4)),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'S',
                        style: GoogleFonts.hankenGrotesk(
                          color: Colors.black,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sarvesh',
                    style: GoogleFonts.hankenGrotesk(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Location Capsule
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on, color: saffron, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Adyar · Ward 170',
                          style: GoogleFonts.hankenGrotesk(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Aadhaar Verified badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: saffron.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: saffron.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified, color: saffron, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Aadhaar Verified',
                          style: GoogleFonts.hankenGrotesk(
                            color: saffron,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(height: 1, color: Colors.white.withOpacity(0.05)),
                  const SizedBox(height: 16),
                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildHeroStat('12', 'POSTS'),
                      _buildHeroStat('34', 'SUPPORTED'),
                      _buildHeroStat('3', 'WISHES'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Civic Score Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: darkSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.04)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CIVIC SCORE',
                        style: GoogleFonts.hankenGrotesk(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '780',
                        style: GoogleFonts.hankenGrotesk(
                          color: saffron,
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Active community member',
                        style: GoogleFonts.inter(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // Circular Progress Indicator
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 64,
                        height: 64,
                        child: CircularProgressIndicator(
                          value: 0.78,
                          backgroundColor: Colors.white.withOpacity(0.05),
                          valueColor: const AlwaysStoppedAnimation<Color>(saffron),
                          strokeWidth: 6,
                        ),
                      ),
                      Text(
                        '78%',
                        style: GoogleFonts.hankenGrotesk(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // My Activity Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    'My Activity',
                    style: GoogleFonts.hankenGrotesk(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildActivityTabChip('Posts', isActive: true),
                      const SizedBox(width: 8),
                      _buildActivityTabChip('Supported'),
                      const SizedBox(width: 8),
                      _buildActivityTabChip('Wishes'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Activity List
                _buildActivityCard(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCGDl0kaqnuq3DkxkMm5uZiM74kaeqY2WtZiKmJQKmbEtGRkjEg-3kYpSggAztLYo1chML8Ft5VNGzm2Ny1bBOn-nT7z4O2Nj6aa4kYDX3t_gV3Rdc8MFBu6pbDz7M1WFN2ISgAxMBMbGCJSrcfPamdV2yoKqgTpYzL0_pLytBR-r4WvICBzDLYpy4J9CHDw30A1jk_aPMXsC-njpsMM_8UFcRALxC6GGCTFN_cBRO9EgXgwse6DE9ndllWxR2vODel4KKlvlb-qrUH',
                  'Pothole near 4th Block Park',
                  'Resolved',
                  Colors.green,
                  '42 supports',
                  '2d ago',
                ),
                const SizedBox(height: 8),
                _buildActivityCard(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuAdRnF4mLQuANPMNLfoH99KHsII8Pe0EUi47ZwHG7HEkFkFZwBzF1A1Qq9qBd34s8zXA9S_NtEMEID8IZhoM-gimClNOSwn5cf_87Z00LsyZI8tmYjCIOJ9Ql7UFzki6eL5Kb2LRQ_3FD7o5jTmZIT6sNFFfLFKFaE6nV_rpzBZ2lCpW8dVsVsfeOVDDrJKP6f3Or-MegPd8saxgc1-PRQqgR6PofFfYaPqh17YrC5qO-AQaJ9K5enhUbVt6G-6UHE2vCHVL6N5KfwO',
                  'Broken street light at 12th Cross',
                  'In Progress',
                  saffron,
                  '18 supports',
                  '5d ago',
                ),
                const SizedBox(height: 8),
                _buildActivityCard(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCOZyjLPoywJoDPeb2-HoTjvHOPJSJoXC-_e4seBZ9gWICr7dzKKTNFD_zVrtP7CKWWpDQbQ7497TpxAAJxxbUEiUIi55v1cednLEQxctJBul93fOCDlLclNgsdGCUtQW_gA-1dFeimXQK621Nmmw1sSsF1mCR9dNv5wekjsmwJhm7C9dcwYSfjnbmEHacU4K6qe-kdSv7A5fPyw273CE-PkOXUK_iWmJMXqIScF99LP3Zs37uoEGOG4tJ2hYEAqkCUoUo4twqjcLWN',
                  'Garbage pile up near metro station',
                  'Resolved',
                  Colors.green,
                  '56 supports',
                  '1w ago',
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Settings Dropdown List
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    'Settings',
                    style: GoogleFonts.hankenGrotesk(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: darkSurface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      _buildSettingRow(Icons.language, 'Language', trailingText: 'English'),
                      _buildDivider(),
                      _buildSettingToggleRow(Icons.notifications, 'Notifications', true),
                      _buildDivider(),
                      _buildSettingRow(Icons.push_pin, 'Home Area'),
                      _buildDivider(),
                      _buildSettingRow(Icons.lock, 'Privacy'),
                      _buildDivider(),
                      _buildSettingToggleRow(Icons.dark_mode, 'Dark Mode', true),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Account Options
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    'Account',
                    style: GoogleFonts.hankenGrotesk(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: darkSurface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      _buildAccountActionRow(Icons.logout, 'Log Out', danger),
                      _buildDivider(),
                      _buildAccountActionRow(Icons.delete, 'Delete Account', danger),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroStat(String val, String label) {
    return Column(
      children: [
        Text(
          val,
          style: GoogleFonts.hankenGrotesk(
            color: saffron,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.hankenGrotesk(
            color: Colors.white.withOpacity(0.4),
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityTabChip(String label, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? saffron : Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.hankenGrotesk(
            color: isActive ? Colors.black : Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(
    String imageUrl,
    String title,
    String status,
    Color statusColor,
    String supports,
    String time,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
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
                        title,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status,
                        style: GoogleFonts.hankenGrotesk(
                          color: statusColor,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.thumb_up, color: Colors.white30, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          supports,
                          style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      time,
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 11,
                      ),
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

  Widget _buildSettingRow(IconData icon, String label, {String? trailingText}) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: saffron, size: 20),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
          Row(
            children: [
              if (trailingText != null) ...[
                Text(
                  trailingText,
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(width: 4),
              ],
              const Icon(Icons.chevron_right, color: Colors.white30, size: 18),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingToggleRow(IconData icon, String label, bool isChecked) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: saffron, size: 20),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
          Switch(
            value: isChecked,
            onChanged: (v) {},
            activeColor: saffron,
            activeTrackColor: saffron.withOpacity(0.3),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.white10,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountActionRow(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.inter(color: color, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 1, color: Colors.white.withOpacity(0.05));
  }
}

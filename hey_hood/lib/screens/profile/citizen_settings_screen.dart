import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hey_hood/core/constants/app_colors.dart';

class CitizenSettingsScreen extends StatefulWidget {
  const CitizenSettingsScreen({super.key});

  @override
  State<CitizenSettingsScreen> createState() => _CitizenSettingsScreenState();
}

class _CitizenSettingsScreenState extends State<CitizenSettingsScreen> {
  // Mock settings states
  bool _postAnonymously = true;
  bool _maskLocation = true;
  bool _emergencyAlerts = true;
  bool _wishStatusUpdates = true;
  String _selectedWard = 'Ward 170 · Adyar';
  
  int _karmaPoints = 1420;
  int _impactTokens = 8;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.4),
        elevation: 0,
        title: Text(
          'Settings',
          style: GoogleFonts.hankenGrotesk(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: saffron),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. User Badge Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: darkSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: saffron, width: 2),
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuDKSPynJzbnnIqIa5hdeKN8na4CdLHHD8usykyL1ZH89f2FI2keeGvlfzQ9pXwk4stL6ua5yJDF4X7K0OemjOkQqIH5VHTqYSjbbQpsTqSi9UqwpBOjJWoxXF4VXWZLXPcPtRBRBLJw5Armoo1O30M1YVSvCjSu4sgHJyVp8cb9PztihaDXEr6fAyifyIqJ4vPhQys4O2zihL88ITIEWIgnBU7XbRVUN1FDCqW2Ux1sGUBYcGGA6O1oJ6U3zV5kFWJt1ddBCQUP5sJD',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sarvesh Kumar',
                            style: GoogleFonts.hankenGrotesk(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedWard,
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. Gamified Civic Wallet Card
              Text(
                'CIVIC WALLET',
                style: GoogleFonts.hankenGrotesk(
                  color: saffron,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      saffron.withOpacity(0.15),
                      Colors.transparent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: saffron.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildWalletMetric('$_karmaPoints', 'Karma Points', Icons.auto_awesome),
                        Container(width: 1, height: 40, color: Colors.white12),
                        _buildWalletMetric('$_impactTokens', 'Impact Tokens', Icons.toll),
                      ],
                    ),
                    const Divider(color: Colors.white10, height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 38,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Rewards store coming soon! Keep supporting wishes.'),
                              backgroundColor: saffron,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: saffron,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Redeem Rewards',
                          style: GoogleFonts.hankenGrotesk(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. Privacy & Reporting Settings
              Text(
                'PRIVACY & REPORTING',
                style: GoogleFonts.hankenGrotesk(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: darkSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Column(
                  children: [
                    _buildSwitchTile(
                      'Post Anonymously by Default',
                      'Your name is hidden on your reports unless you opt-in manually.',
                      _postAnonymously,
                      (val) => setState(() => _postAnonymously = val),
                    ),
                    const Divider(color: Colors.white10, height: 1),
                    _buildSwitchTile(
                      'Mask Exact Location',
                      'Truncates GPS coordinates to a 50m radius block overlay for safety.',
                      _maskLocation,
                      (val) => setState(() => _maskLocation = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 4. Notifications Configuration
              Text(
                'NOTIFICATION ALERTS',
                style: GoogleFonts.hankenGrotesk(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: darkSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Column(
                  children: [
                    _buildSwitchTile(
                      'Emergency Alerts',
                      'Receive instant alarms for level 4/5 emergencies in your ward.',
                      _emergencyAlerts,
                      (val) => setState(() => _emergencyAlerts = val),
                    ),
                    const Divider(color: Colors.white10, height: 1),
                    _buildSwitchTile(
                      'Wish Status Updates',
                      'Get notified when a supported neighborhood wish is approved or reaches a milestone.',
                      _wishStatusUpdates,
                      (val) => setState(() => _wishStatusUpdates = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 5. App Actions
              Text(
                'ADVANCED SYSTEM',
                style: GoogleFonts.hankenGrotesk(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: darkSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: ListTile(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Offline Map Caches cleared (142.5 MB freed).'),
                        backgroundColor: green,
                      ),
                    );
                  },
                  title: Text(
                    'Clear Offline Map Caches',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    'Frees storage. Neighborhood map layers will re-download on next load.',
                    style: GoogleFonts.inter(
                      color: Colors.white30,
                      fontSize: 11,
                    ),
                  ),
                  trailing: const Icon(Icons.cleaning_services_outlined, color: saffron),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletMetric(String val, String label, IconData icon) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: saffron, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                val,
                style: GoogleFonts.hankenGrotesk(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool currentVal, ValueChanged<bool> onChange) {
    return SwitchListTile(
      value: currentVal,
      onChanged: onChange,
      activeColor: saffron,
      activeTrackColor: saffron.withOpacity(0.2),
      inactiveThumbColor: Colors.white30,
      inactiveTrackColor: Colors.white12,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        title,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          subtitle,
          style: GoogleFonts.inter(
            color: Colors.white70,
            fontSize: 12,
            height: 1.3,
          ),
        ),
      ),
    );
  }
}

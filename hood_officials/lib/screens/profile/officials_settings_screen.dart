import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hood_officials/core/constants/app_colors.dart';

class OfficialsSettingsScreen extends StatefulWidget {
  const OfficialsSettingsScreen({super.key});

  @override
  State<OfficialsSettingsScreen> createState() => _OfficialsSettingsScreenState();
}

class _OfficialsSettingsScreenState extends State<OfficialsSettingsScreen> {
  // Mock settings states
  bool _isOnDuty = true;
  bool _autoResponder = true;
  double _escalationHours = 36.0;
  bool _biometricLock = false;
  bool _cryptoSignOff = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        backgroundColor: lightBg,
        elevation: 0,
        title: Text(
          'Administrative Settings',
          style: GoogleFonts.hankenGrotesk(
            color: navy,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: navy),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Official Identity Badge
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E2E1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: saffron, width: 2),
                            image: const DecorationImage(
                              image: NetworkImage(
                                'https://lh3.google/AP1WRLvRj7hL0cDhfToOkr6TY-ALHME_0JVdK06Z0WlMYKkeESV-KPetJMKUHP6iewGx7F-yjF-J58rU9UnWVRbPomcyuBc40s2rp4t3s6zOV_MEhT7_hAHCSoitULBwpJGr4s_9rZmzJPECn2_3M47aPmzU-VQfo2e_T9Znxh44rki83W1MVVve3w2gIZZOL8QWrtd7vRaZLAvbXg3qWARzcEkxYR_O7NZ4mvkcNfkJsyBhPXa-gJFvxW6vygDB',
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
                                'Ramesh Kumar',
                                style: GoogleFonts.hankenGrotesk(
                                  color: navy,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ward Councillor · Ward 170',
                                style: GoogleFonts.hankenGrotesk(
                                  color: muted,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Color(0xFFE5E2E1), height: 24),
                    Row(
                      children: [
                        const Icon(Icons.verified_user, color: green, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'CRYPTOGRAPHIC SIGNATURE VERIFIED',
                            style: GoogleFonts.hankenGrotesk(
                              color: green,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 2. Performance Summary Card
              Text(
                'PERFORMANCE SCORECARD',
                style: GoogleFonts.hankenGrotesk(
                  color: muted,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E2E1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPerformanceMetric('98.4%', 'SLA Compliance', green),
                    Container(width: 1, height: 40, color: const Color(0xFFE5E2E1)),
                    _buildPerformanceMetric('2.4 Days', 'Avg. Resolution', navy),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. Duty Availability
              Text(
                'DUTY AVAILABILITY',
                style: GoogleFonts.hankenGrotesk(
                  color: muted,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E2E1)),
                ),
                child: Column(
                  children: [
                    _buildSwitchTile(
                      'On-Duty Availability Status',
                      'Toggle off to mark yourself unavailable. Citizen issue notifications will be muted.',
                      _isOnDuty,
                      (val) => setState(() => _isOnDuty = val),
                    ),
                    const Divider(color: Color(0xFFE5E2E1), height: 1),
                    _buildSwitchTile(
                      'Auto-Responder for Issues',
                      'Instantly acknowledges citizen reports with a standardized verified message.',
                      _autoResponder,
                      (val) => setState(() => _autoResponder = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 4. Escalation SLA Configuration
              Text(
                'ESCALATION SLA THRESHOLD',
                style: GoogleFonts.hankenGrotesk(
                  color: muted,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E2E1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Auto-Escalation Timer',
                          style: GoogleFonts.hankenGrotesk(
                            color: navy,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_escalationHours.toInt()} Hours',
                          style: GoogleFonts.hankenGrotesk(
                            color: saffron,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Time before an unaccepted citizen report is escalated to MLA Suresh Patel.',
                      style: GoogleFonts.hankenGrotesk(
                        color: muted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Slider(
                      value: _escalationHours,
                      min: 12.0,
                      max: 72.0,
                      divisions: 5,
                      activeColor: saffron,
                      inactiveColor: const Color(0xFFE5E2E1),
                      onChanged: (val) => setState(() => _escalationHours = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 5. Security & Authorization
              Text(
                'SECURITY & CLEARANCE',
                style: GoogleFonts.hankenGrotesk(
                  color: muted,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E2E1)),
                ),
                child: Column(
                  children: [
                    _buildSwitchTile(
                      'Biometric Administrative Lock',
                      'Requires FaceID/Fingerprint validation to launch official actions or resolves.',
                      _biometricLock,
                      (val) => setState(() => _biometricLock = val),
                    ),
                    const Divider(color: Color(0xFFE5E2E1), height: 1),
                    _buildSwitchTile(
                      'Cryptographic Post Sign-Off',
                      'Requires signing off news and notice updates using department secure certificates.',
                      _cryptoSignOff,
                      (val) => setState(() => _cryptoSignOff = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceMetric(String val, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            val,
            style: GoogleFonts.hankenGrotesk(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.hankenGrotesk(
              color: muted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
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
      inactiveThumbColor: Colors.grey[400],
      inactiveTrackColor: const Color(0xFFE5E2E1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        title,
        style: GoogleFonts.hankenGrotesk(
          color: navy,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          subtitle,
          style: GoogleFonts.hankenGrotesk(
            color: muted,
            fontSize: 12,
            height: 1.3,
          ),
        ),
      ),
    );
  }
}

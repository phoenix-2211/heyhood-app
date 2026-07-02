import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hood_officials/core/constants/app_colors.dart';
import 'package:hood_officials/screens/dashboard/officials_navigation_shell.dart';

class IdentityVerifiedScreen extends StatefulWidget {
  const IdentityVerifiedScreen({super.key});

  @override
  State<IdentityVerifiedScreen> createState() => _IdentityVerifiedScreenState();
}

class _IdentityVerifiedScreenState extends State<IdentityVerifiedScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      body: Stack(
        children: [
          // Background subtle glow
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [
                    Color(0x0FFF9933),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 1. Success check circle with scale-up animation
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 96,
                          height: 96,
                          decoration: const BoxDecoration(
                            color: green,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x33138808),
                                blurRadius: 15,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 2. Headings
                      Text(
                        'Identity Verified',
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: navy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Welcome to Hood Officials',
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: green,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Your account has been verified and activated. You are now responsible for your assigned ward.',
                          style: GoogleFonts.hankenGrotesk(
                            fontSize: 13,
                            color: muted,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 3. Profile details card
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: lightSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE5E2E1)),
                        ),
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                // Avatar with verification tick badge overlay
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 6,
                                          ),
                                        ],
                                        image: const DecorationImage(
                                          image: NetworkImage(
                                            'https://lh3.googleusercontent.com/aida-public/AB6AXuDwt-l5tKzD4s_R5w9WdI7gXz-g1j4H7g9_V6k2x0z1y8e6t5r4c3e2w1q0p7o8n9m8l7k6j5h4g3f2d1', // High quality portrait fallback or direct image
                                          ),
                                          fit: BoxFit.cover,
                                          onError: _handleImageError,
                                        ),
                                      ),
                                      // Fallback image using Icon if internet fails or url is placeholder
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.grey,
                                        size: 32,
                                      ),
                                    ),
                                    const Positioned(
                                      bottom: -2,
                                      right: -2,
                                      child: CircleAvatar(
                                        radius: 10,
                                        backgroundColor: green,
                                        child: Icon(
                                          Icons.verified,
                                          color: Colors.white,
                                          size: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                
                                // User info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Sarvesh Kumar',
                                        style: GoogleFonts.hankenGrotesk(
                                          color: navy,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Ward Councillor',
                                        style: GoogleFonts.hankenGrotesk(
                                          color: muted,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: saffron.withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              'Ward 170',
                                              style: GoogleFonts.hankenGrotesk(
                                                color: saffron,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                            decoration: BoxDecoration(
                                              border: Border.all(color: const Color(0xFFE5E2E1)),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              'Adyar',
                                              style: GoogleFonts.hankenGrotesk(
                                                color: muted,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            const Divider(color: Color(0xFFE5E2E1)),
                            const SizedBox(height: 8),
                            
                            // Stats grid
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem('Assigned', '0'),
                                Container(width: 1, height: 28, color: const Color(0xFFE5E2E1)),
                                _buildStatItem('Resolved', '0', color: green),
                                Container(width: 1, height: 28, color: const Color(0xFFE5E2E1)),
                                _buildStatItem('Score', '100'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 4. Quote section
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF9F9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF0ECEB)),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: -10,
                              left: -10,
                              child: Icon(
                                Icons.format_quote,
                                size: 48,
                                color: saffron.withOpacity(0.15),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'You have been entrusted with the trust of your community. Every issue you resolve on Hood Officials is a promise kept to a resident of your ward.',
                                style: GoogleFonts.hankenGrotesk(
                                  color: navy.withOpacity(0.8),
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  height: 1.6,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // 5. Enter button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _loading ? null : () {
                            setState(() {
                              _loading = true;
                            });
                            Timer(const Duration(milliseconds: 1000), () {
                              if (mounted) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (context) => const OfficialsNavigationShell()),
                                );
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: saffron,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                          ),
                          child: _loading 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Enter Hood Officials',
                                    style: GoogleFonts.hankenGrotesk(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward),
                                ],
                              ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      Opacity(
                        opacity: 0.2,
                        child: const Icon(
                          Icons.account_balance,
                          size: 72,
                          color: navy,
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

  static void _handleImageError(Object exception, StackTrace? stackTrace) {
    // Suppress network image load errors
  }

  Widget _buildStatItem(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.hankenGrotesk(
            color: muted,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.hankenGrotesk(
            color: color ?? navy,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

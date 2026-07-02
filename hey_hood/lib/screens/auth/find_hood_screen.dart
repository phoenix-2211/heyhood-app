import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hey_hood/core/constants/app_colors.dart';
import 'package:hey_hood/screens/auth/confirm_hood_screen.dart';

class FindHoodScreen extends StatefulWidget {
  const FindHoodScreen({super.key});

  @override
  State<FindHoodScreen> createState() => _FindHoodScreenState();
}

class _FindHoodScreenState extends State<FindHoodScreen> {
  bool _isDetecting = false;

  void _onEnableLocation() async {
    setState(() {
      _isDetecting = true;
    });

    // Simulate location detection
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isDetecting = false;
      });
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const ConfirmHoodScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      body: Stack(
        children: [
          // Background city map graphic with low opacity
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuB_4ATSiFb4ExWW2WQFa7tSE4hCHwDsDOlseEuwHtjQ_ZDfCBea3Iu5ak3wcecGG-cRapN6sT4TJ3gs1nN82SqXVk511Bu3ri6-qv7E98KfnHA0V1jQCrbLzAq5igTFVdIiXgkNrTotpyAu_CaJXKkqbdQOXRt97IXWMRyOs1--yRFVxTqwO9HGRVXDRhnndsT6Deq_5yQhXmptjMPDF7XwkhR5Y5BnhrEmRLdvVsJmep5fsmJ5LVPSCXBoEcaDpDuAghA9VQtYxE7e',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: Colors.black),
              ),
            ),
          ),
          // Gradient overlays
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),
          // TopAppBar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withOpacity(0.08),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: saffron),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Text(
                      'HEY HOOD',
                      style: GoogleFonts.hankenGrotesk(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1,
                      ),
                    ),
                    TextButton(
                      onPressed: _onEnableLocation,
                      child: Text(
                        'SKIP',
                        style: GoogleFonts.hankenGrotesk(
                          color: saffron,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Main Content
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(),
                    // Animated Icon Container
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: saffron.withOpacity(0.1),
                          ),
                        ),
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: darkSurface,
                            border: Border.all(
                              color: saffron.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: saffron,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                    // Title and Description
                    Text(
                      'Find Your Hood',
                      style: GoogleFonts.hankenGrotesk(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'We use your location to connect you with the correct neighborhood.',
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(),
                    // Action Buttons
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: saffron,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _isDetecting ? null : _onEnableLocation,
                        child: _isDetecting
                            ? const CircularProgressIndicator(color: Colors.black)
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.my_location),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Enable Location',
                                    style: GoogleFonts.hankenGrotesk(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _onEnableLocation,
                      child: Text(
                        'MANUAL SEARCH',
                        style: GoogleFonts.hankenGrotesk(
                          color: saffron,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Privacy indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock,
                          color: Colors.white.withOpacity(0.3),
                          size: 14,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Privacy-first location detection',
                          style: GoogleFonts.hankenGrotesk(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

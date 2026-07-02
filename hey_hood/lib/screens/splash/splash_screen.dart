import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hey_hood/core/constants/app_colors.dart';
import 'package:hey_hood/screens/onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _logoOpacity = 0.0;
  double _taglineOpacity = 0.0;
  double _taglineOffsetY = 20.0;

  @override
  void initState() {
    super.initState();
    _startAnimations();
    _navigateToOnboarding();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() {
        _logoOpacity = 1.0;
      });
    }
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() {
        _taglineOpacity = 1.0;
        _taglineOffsetY = 0.0;
      });
    }
  }

  void _navigateToOnboarding() async {
    await Future.delayed(const Duration(seconds: 10));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
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
          // Background Image with dark cinematic overlay
          Positioned.fill(
            child: Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuA7Grh_d1P08ar8CKHu1GqPDxDdHDxNo5r9bWlmrkeerxgxVdfKwfIENbHO1V9B11_jGhTzCpSOYnnFXLoXNVVdOdEBV5cHqm7XJd61m6QTUuVKIr4FnnTWtIXVlpZlvmOQivDXZT5I11r2ToOUDqEEJ3jl4x9nxqiYaLdGre1BfKnhLKjGqDuZSEsPubh6PNLxcAENPDNfBDzYfzt7RWYlnJx-WB23nBi8ZZaap7n7ALQ9PRlK--Qb790N2KQ81ktDGozxK7cQgxxJ',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: Colors.black),
            ),
          ),
          // Vignette and black overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.9),
                  ],
                  stops: const [0.0, 0.7, 1.0],
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
                    Colors.transparent,
                    darkBg.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Section
                AnimatedOpacity(
                  opacity: _logoOpacity,
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeIn,
                  child: Column(
                    children: [
                      Text(
                        'HEY',
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 64,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -2,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'H',
                            style: GoogleFonts.hankenGrotesk(
                              fontSize: 64,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -2,
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Location Pin O
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 64,
                                color: saffron,
                              ),
                              Positioned(
                                top: 16,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 4),
                          // Glowing Orange Node O
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: saffron,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: saffron.withOpacity(0.5),
                                  blurRadius: 15,
                                  spreadRadius: 3,
                                ),
                              ],
                              border: Border.all(
                                color: darkSurface,
                                width: 3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'D',
                            style: GoogleFonts.hankenGrotesk(
                              fontSize: 64,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -2,
                            ),
                          ),
                        ],
                      ),
                      // Divider Line
                      Container(
                        width: 64,
                        height: 1,
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              saffron.withOpacity(0.5),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Tagline Section
                AnimatedOpacity(
                  opacity: _taglineOpacity,
                  duration: const Duration(milliseconds: 600),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    transform: Matrix4.translationValues(0, _taglineOffsetY, 0),
                    child: Column(
                      children: [
                        Text(
                          'KNOW YOUR HOOD. IMPACT YOUR HOOD.',
                          style: GoogleFonts.hankenGrotesk(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.6),
                            letterSpacing: 3.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

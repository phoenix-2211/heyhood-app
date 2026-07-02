import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hood_officials/core/constants/app_colors.dart';
import 'package:hood_officials/screens/auth/officials_onboarding_screen.dart';

class OfficialsSplashScreen extends StatefulWidget {
  const OfficialsSplashScreen({super.key});

  @override
  State<OfficialsSplashScreen> createState() => _OfficialsSplashScreenState();
}

class _OfficialsSplashScreenState extends State<OfficialsSplashScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _quoteFadeAnimation;
  late Animation<double> _quoteSlideAnimation;
  
  CrossFadeState _logoCrossFadeState = CrossFadeState.showFirst;
  bool _showQuote = false;

  @override
  void initState() {
    super.initState();
    
    // Animation controller for the quote at Stage 2
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _quoteFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _quoteSlideAnimation = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    // At 3 seconds, cross-fade the logo and trigger quote animation
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _logoCrossFadeState = CrossFadeState.showSecond;
          _showQuote = true;
        });
        _fadeController.forward();
      }
    });

    // Navigate to Onboarding screen after 6 seconds total
    Timer(const Duration(seconds: 6), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const OfficialsOnboardingScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Blank white screen
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            children: [
              const Spacer(),
              
              // 1. Header Typography
              Text(
                'Hood Officials',
                style: GoogleFonts.hankenGrotesk(
                  color: saffron,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The Mission Control for Civic Leadership.',
                style: GoogleFonts.hankenGrotesk(
                  color: const Color(0xFF7F8C8D), // grey/muted
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              
              const Spacer(),
              
              // 2. Animated Logos in Center
              Center(
                child: AnimatedCrossFade(
                  duration: const Duration(milliseconds: 800),
                  firstChild: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBlaNysjyczv1_YVrmH5D7x7TsE4sOEJNEEYXCVxVNpxUj2b2dX94RptmeJQe4uCIDiysR8W_McyiyLg5Zl2LULl-fE4yQF40uHlFmbEiKjHLgTYbF8HKgeB_VnFGgXOqSnqH9Q2k-x0xcggzJxccOuFIPuqPvo-s_YcR20g-aA__i9hTlrTCCSfMpqDEC2IJlpI3lt6rhsc9Bc2gNfEeMbk-Qqy5F5NR2j2r9Cb-qLPsAYMMVmtO1_RZA0QGCmb6hEoTEIq0Br1HcD',
                    height: 180,
                    fit: BoxFit.contain,
                  ),
                  secondChild: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuCKd4n2jD-IoFnDQTjg-r2sTs9YHLKujkE7ZitkqEROGqLYI1RxD9wuRQfIiHqi2SM6kFyBj7rbQRFOLH0TzsE58vndn8JEktfbbLM1OM2J0gMEg8tRWlmOjjP5thIwUVocI3nPETM27RZXp6fZlVSr_0bD97EzXLBt3TTIi8GXGSQwFyWIUbrVmTXSmdBzGO8l_Us51cecVMyUTwCwclLNbrO1kqjccfmOSZRBvWj_EYRPGA59IkafhT758Cq93awFyvxYrVLJt2Ew',
                    height: 180,
                    fit: BoxFit.contain,
                  ),
                  crossFadeState: _logoCrossFadeState,
                  firstCurve: Curves.easeInOut,
                  secondCurve: Curves.easeInOut,
                  sizeCurve: Curves.easeInOut,
                ),
              ),
              
              const Spacer(),
              
              // 3. Quotes Section with slide-up and fade-in animation
              SizedBox(
                height: 80,
                child: _showQuote
                    ? AnimatedBuilder(
                        animation: _fadeController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _quoteSlideAnimation.value),
                            child: Opacity(
                              opacity: _quoteFadeAnimation.value,
                              child: child,
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: GoogleFonts.hankenGrotesk(
                                fontSize: 18,
                                fontStyle: FontStyle.italic,
                                color: const Color(0xFF2C3E50), // Navy/dark
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                              children: [
                                TextSpan(
                                  text: '“ ',
                                  style: GoogleFonts.hankenGrotesk(
                                    color: saffron,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.normal,
                                  ),
                                ),
                                const TextSpan(text: 'Serve with proof. Lead with action.'),
                                TextSpan(
                                  text: ' ”',
                                  style: GoogleFonts.hankenGrotesk(
                                    color: saffron,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

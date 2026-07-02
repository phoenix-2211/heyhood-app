import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:hey_hood/core/constants/app_colors.dart';
import 'package:hey_hood/screens/auth/verify_phone_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> _backgroundImages = [
    'https://lh3.googleusercontent.com/aida-public/AB6AXuAsHQNsZSfhXLyYcgTWNJ51AHsA3Yt7ojLDAI1WS7f2Hcj9sIWckjy6dAqI5OZQr2DBq6mSTiad9_BKZ3Dd9-vkRZSfNnnEeEP1M-Qd6G-e-yKzDkgBYy7zBrUyStIgYD7klFKAjQDAV2INBxh-dGXnUsmT7RtNgqJ7MmhrgPSelFNTB6gma9n6yrdj16gSE2zihSFCjbaUBOWafPwhyKZzrXWCsRMDdWze4aBVe6Mb7TxLFHa0EFs1AVX7V0K1rQLxPOiAkxRF07A7',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuCk1gi1QMl3ztAQhbYdpInkLMzhAF15Ku1SWnT0G2iO2OWYCjSYXgssxhONu8bYh0kS6S9qO0meOVLdhHlNBKxeU52lyHtv28jQtBLF0HoamQoVnms23CgHH8Lnuhj73q8-YQbqnTvbYkBrZRcmMSexNyhIDyHNTPp245jylw5HtPUMwsCdL90I_X7u8m6KeAa3yu3cNosqKVYbCTUvXbwACfb7X6muDtXqgfjC01FIv2BNS8HSEQJVmP590bJITVqSz3RjNDYxnsDq',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuCJt6haRO5B_NMYoRVCfODzgb8DVNdpHdNeEHEhWOCF-ISGUqf0u7CpgFQVNy_jWnBOTM_i8HA9ZnfniWyCVbDWd2kfwU5zOSaJtwHQvxnrHqkLeMmaI5bPrrc8o1_TNUfOh3pevuvAhDGjyz-txHxR-kSVJ5b6DpDSQfXrm4mCrgMoj26Af9S-lpHIrSFwRIyEO5mB5UEaNF5MEkEdhq-qCunaSzOd96DkzYQk9zQjofaqJxq-Gw1m2Yn05-4olVk2LwsRS-n2lrDt'
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToVerifyPhone();
    }
  }

  void _navigateToVerifyPhone() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const VerifyPhoneScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      body: Stack(
        children: [
          // Background Images Crossfade
          ...List.generate(_backgroundImages.length, (index) {
            return Positioned.fill(
              child: AnimatedOpacity(
                opacity: _currentPage == index ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 600),
                child: Image.network(
                  _backgroundImages[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(color: Colors.black),
                ),
              ),
            );
          }),
          // Dark overlays for cinematic effect
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.9),
                  ],
                  stops: const [0.0, 0.5, 1.0],
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
                    Colors.black.withOpacity(0.6),
                    darkBg,
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),
          // Top Skip Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: saffron),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    TextButton(
                      onPressed: _navigateToVerifyPhone,
                      child: Text(
                        'SKIP',
                        style: GoogleFonts.hankenGrotesk(
                          color: saffron,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
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
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const Spacer(),
                    // PageView for slides content
                    SizedBox(
                      height: 250,
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (page) {
                          setState(() {
                            _currentPage = page;
                          });
                        },
                        children: [
                          _buildSlideContent(
                            "Know Your Hood",
                            "See what is happening around you, from local issues and community updates to important neighborhood events.",
                          ),
                          _buildSlideContent(
                            "Every Voice Matters",
                            "Support issues that matter and help your neighborhood speak with one stronger voice.",
                          ),
                          _buildSlide3Content(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Smooth page indicator
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: 3,
                      effect: const ExpandingDotsEffect(
                        activeDotColor: saffron,
                        dotColor: Color(0x3FE5E2E3),
                        dotHeight: 8,
                        dotWidth: 8,
                        expansionFactor: 3,
                        spacing: 8,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Primary Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: saffron,
                          foregroundColor: Colors.black,
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _onNextPage,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentPage == 2 ? 'Get Started' : 'Next',
                              style: GoogleFonts.hankenGrotesk(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlideContent(String title, String subtitle) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: GoogleFonts.hankenGrotesk(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildSlide3Content() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Timeline indicator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Track line
              Positioned(
                left: 16,
                right: 16,
                child: Container(
                  height: 2,
                  color: saffron.withOpacity(0.3),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 1.0,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      color: saffron,
                      boxShadow: [
                        BoxShadow(
                          color: saffron.withOpacity(0.5),
                          blurRadius: 8,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              // Nodes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTimelineNode("Reported", true, false),
                  _buildTimelineNode("Notified", true, false),
                  _buildTimelineNode("Resolved", true, true),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "From Problem To Solution",
          style: GoogleFonts.hankenGrotesk(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            "Track issues from report to resolution and see real change happen in your neighborhood.",
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineNode(String label, bool isActive, bool isLarge) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isLarge ? 14 : 10,
          height: isLarge ? 14 : 10,
          decoration: BoxDecoration(
            color: isActive ? saffron : Colors.grey,
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: saffron.withOpacity(0.4),
                      blurRadius: 10,
                      spreadRadius: isLarge ? 2 : 1,
                    )
                  ]
                : null,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.hankenGrotesk(
            color: isActive ? saffron : Colors.grey,
            fontSize: 10,
            fontWeight: isLarge ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

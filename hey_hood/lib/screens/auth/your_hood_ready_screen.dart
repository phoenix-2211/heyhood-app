import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hey_hood/core/constants/app_colors.dart';
import 'package:hey_hood/screens/home/home_dashboard.dart';

class YourHoodReadyScreen extends StatefulWidget {
  const YourHoodReadyScreen({super.key});

  @override
  State<YourHoodReadyScreen> createState() => _YourHoodReadyScreenState();
}

class _YourHoodReadyScreenState extends State<YourHoodReadyScreen> {
  void _onEnterHood() {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomeDashboard(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      body: Stack(
        children: [
          // Ambient decorative lighting beams
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 500,
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.1),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 500,
              decoration: BoxDecoration(
                color: saffron.withOpacity(0.05),
                borderRadius: BorderRadius.circular(100),
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
                      onPressed: _onEnterHood,
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
          // Content
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 80, 24, 100),
                child: Column(
                  children: [
                    const Spacer(),
                    // Verified Badge Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: saffron.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: saffron.withOpacity(0.2),
                        ),
                      ),
                      child: const Icon(
                        Icons.verified,
                        color: saffron,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Your Hood Is Ready',
                      style: GoogleFonts.hankenGrotesk(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "You're now connected to your neighborhood.",
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    // Success Checklist Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: darkSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildCheckItem("Phone Verified"),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(color: Colors.white10, height: 1),
                          ),
                          _buildCheckItem("Profile Created"),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(color: Colors.white10, height: 1),
                          ),
                          _buildCheckItem("Location Confirmed"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Neighborhood Image
                    Container(
                      width: double.infinity,
                      height: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.network(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuBSLindAjq7JmViopXiGe7nB6qNEoEdgKKU_9E48dRpjmuj1V8KaGtBAuz1kS8t_t_7UypqNrLaCl5mHM5-JIYkmZVL9QfJSnI_0jvqIL_RZRXrwlyjht9Lr8QWJqqk7r5fBDUjXUrLGVmaRjI8iOAcyIdTS2X-_MLVLSqUQYbqOPoErzpV2d0_cJcoQYyy-M0aMcnswabIVhxGvAjjZdNhPizoEe4vglm853__dFBSEn39AHK9uQ6QhSl1ZN5P_vd3Ib1P6s2-c69p',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[900]),
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.8),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
          // Enter Your Hood Button
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: SizedBox(
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
                onPressed: _onEnterHood,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Enter Your Hood',
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
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String label) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: saffron.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check,
            color: saffron,
            size: 16,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.hankenGrotesk(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

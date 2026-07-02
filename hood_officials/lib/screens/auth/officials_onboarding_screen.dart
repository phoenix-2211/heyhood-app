import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hood_officials/core/constants/app_colors.dart';
import 'package:hood_officials/screens/auth/officials_login_screen.dart';

class OfficialsOnboardingScreen extends StatelessWidget {
  const OfficialsOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
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
                  color: muted,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              
              const Spacer(),
              
              // 2. Shield Emblem
              Center(
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCKd4n2jD-IoFnDQTjg-r2sTs9YHLKujkE7ZitkqEROGqLYI1RxD9wuRQfIiHqi2SM6kFyBj7rbQRFOLH0TzsE58vndn8JEktfbbLM1OM2J0gMEg8tRWlmOjjP5thIwUVocI3nPETM27RZXp6fZlVSr_0bD97EzXLBt3TTIi8GXGSQwFyWIUbrVmTXSmdBzGO8l_Us51cecVMyUTwCwclLNbrO1kqjccfmOSZRBvWj_EYRPGA59IkafhT758Cq93awFyvxYrVLJt2Ew',
                  height: 180,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.shield,
                    size: 120,
                    color: saffron,
                  ),
                ),
              ),
              
              const Spacer(),
              
              // 3. Dots indicator matching the design
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: saffron,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // 4. Quote block
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: navy,
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
              
              const Spacer(flex: 2),
              
              // 5. Get Started Button
              SizedBox(
                width: 200,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const OfficialsLoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: saffron,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: saffron.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28.0),
                    ),
                  ),
                  child: Text(
                    'Get Started',
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

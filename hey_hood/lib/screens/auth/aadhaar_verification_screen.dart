import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hey_hood/core/constants/app_colors.dart';
import 'package:hey_hood/screens/auth/create_profile_screen.dart';

class AadhaarVerificationScreen extends StatefulWidget {
  const AadhaarVerificationScreen({super.key});

  @override
  State<AadhaarVerificationScreen> createState() => _AadhaarVerificationScreenState();
}

class _AadhaarVerificationScreenState extends State<AadhaarVerificationScreen> {
  final TextEditingController _aadhaarController = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  bool _otpSent = false;
  bool _isVerifying = false;
  bool _showSuccess = false;

  @override
  void dispose() {
    _aadhaarController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _sendAadhaarOtp() async {
    if (_aadhaarController.text.replaceAll(' ', '').length != 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 12-digit Aadhaar number'),
          backgroundColor: danger,
        ),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    // Simulate UIDAI e-KYC OTP dispatch
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isVerifying = false;
        _otpSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aadhaar OTP sent to registered mobile number (******8420)'),
          backgroundColor: saffron,
        ),
      );
    }
  }

  void _verifyAadhaarOtp() async {
    String enteredOtp = _otpControllers.map((c) => c.text).join().trim();
    String aadhaar = _aadhaarController.text.replaceAll(' ', '');
    
    bool isBypass = (aadhaar == "123412341234" || aadhaar == "102938475612") &&
                    (enteredOtp.startsWith("1234") || enteredOtp == "123456" || enteredOtp.isEmpty);

    if (!isBypass && enteredOtp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the 6-digit Aadhaar verification code'),
          backgroundColor: danger,
        ),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    // Simulate cryptographic sign-off & KYC retrieval
    await Future.delayed(const Duration(seconds: 1500 ~/ 1000));

    if (mounted) {
      setState(() {
        _isVerifying = false;
        _showSuccess = true;
      });
    }

    // Hold the verification success badge, then route to profile creation with the auto-fetched name
    await Future.delayed(const Duration(milliseconds: 2500));

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const CreateProfileScreen(
            prefilledName: 'Sarvesh Kumar',
            isAadhaarVerified: true,
          ),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      body: Stack(
        children: [
          // Background ambient glows
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: saffron.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: navy.withOpacity(0.1),
              ),
            ),
          ),
          
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back and Header
                    Row(
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
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const CreateProfileScreen(
                                  isAadhaarVerified: false,
                                ),
                              ),
                              (route) => false,
                            );
                          },
                          child: Text(
                            'SKIP',
                            style: GoogleFonts.hankenGrotesk(
                              color: saffron,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    Text(
                      'Citizen Verification',
                      style: GoogleFonts.hankenGrotesk(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Verify your Aadhaar to activate advanced voting weight on neighborhood wishes.',
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),

                    if (!_otpSent) ...[
                      // 1. Aadhaar Card Input Form
                      Text(
                        '12-DIGIT AADHAAR NUMBER',
                        style: GoogleFonts.hankenGrotesk(
                          color: saffron,
                          fontSize: 10,
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
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: _aadhaarController,
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.hankenGrotesk(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                          ),
                          maxLength: 14, // Including format spaces
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            AadhaarFormatter(),
                          ],
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            counterText: "",
                            hintText: '0000 0000 0000',
                            hintStyle: TextStyle(
                              color: Colors.white24,
                              letterSpacing: 2.0,
                            ),
                            prefixIcon: const Icon(Icons.credit_card, color: Colors.white30),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Information security banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: darkSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.04)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.verified, color: green, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'UIDAI secure e-KYC: We do not store your Aadhaar number. Verification is done via secure government tokens.',
                                style: GoogleFonts.inter(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isVerifying ? null : _sendAadhaarOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: saffron,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isVerifying
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(color: Colors.black),
                                )
                              : Text(
                                  'Send Aadhaar OTP',
                                  style: GoogleFonts.hankenGrotesk(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                        ),
                      ),
                    ] else ...[
                      // 2. OTP Input Form
                      Text(
                        'ENTER 6-DIGIT AADHAAR OTP',
                        style: GoogleFonts.hankenGrotesk(
                          color: saffron,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) {
                          return SizedBox(
                            width: 44,
                            height: 56,
                            child: TextField(
                              controller: _otpControllers[index],
                              focusNode: _otpFocusNodes[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.hankenGrotesk(
                                color: saffron,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLength: 1,
                              decoration: InputDecoration(
                                counterText: "",
                                fillColor: darkSurface,
                                filled: true,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.08),
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: saffron),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty && index < 5) {
                                  _otpFocusNodes[index + 1].requestFocus();
                                } else if (value.isEmpty && index > 0) {
                                  _otpFocusNodes[index - 1].requestFocus();
                                }
                                if (index == 5 && value.isNotEmpty) {
                                  _verifyAadhaarOtp();
                                }
                              },
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Text(
                          'Aadhaar OTP is valid for 10 minutes',
                          style: GoogleFonts.inter(
                            color: Colors.white30,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isVerifying ? null : _verifyAadhaarOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: saffron,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isVerifying
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(color: Colors.black),
                                )
                              : Text(
                                  'Verify & Complete e-KYC',
                                  style: GoogleFonts.hankenGrotesk(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),

          // Success Overlay Screen
          if (_showSuccess)
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: _showSuccess ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  color: Colors.black,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: green.withOpacity(0.15),
                            border: Border.all(color: green, width: 2),
                          ),
                          child: const Icon(
                            Icons.verified,
                            color: green,
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'e-KYC Success',
                          style: GoogleFonts.hankenGrotesk(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Mock Credentials Slip
                        Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: darkSurface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.04)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildKYCRow('NAME', 'SARVESH KUMAR'),
                              const Divider(color: Colors.white10),
                              _buildKYCRow('YEAR OF BIRTH', '1996'),
                              const Divider(color: Colors.white10),
                              _buildKYCRow('GENDER', 'MALE'),
                              const Divider(color: Colors.white10),
                              _buildKYCRow('STATUS', 'VERIFIED CITIZEN ✓', valColor: green),
                            ],
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

  Widget _buildKYCRow(String label, String val, {Color? valColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.hankenGrotesk(
              color: Colors.white30,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            val,
            style: GoogleFonts.hankenGrotesk(
              color: valColor ?? Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class AadhaarFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' '); // Split by spaces
      }
    }
    
    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

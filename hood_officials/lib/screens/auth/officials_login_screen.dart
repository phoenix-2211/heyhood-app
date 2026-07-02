import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hood_officials/core/constants/app_colors.dart';
import 'package:hood_officials/screens/auth/identity_verified_screen.dart';
import 'package:hood_officials/services/auth_service.dart';
import 'package:hood_officials/services/firestore_service.dart';

class OfficialsLoginScreen extends StatefulWidget {
  const OfficialsLoginScreen({super.key});

  @override
  State<OfficialsLoginScreen> createState() => _OfficialsLoginScreenState();
}

class _OfficialsLoginScreenState extends State<OfficialsLoginScreen> {
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final TextEditingController _phoneController = TextEditingController(text: '7402608309');
  final TextEditingController _employeeIdController = TextEditingController(text: 'GCC-WC-100');
  final TextEditingController _nameController = TextEditingController(text: 'Sarvesh Kumar');
  
  String _designation = 'Ward Councillor';
  String _assignedWard = 'Ward 170';
  bool _otpSent = false;
  bool _otpVerified = false;
  bool _isUploadingID = false;
  String? _uploadedFilename;

  void _simulateUpload() async {
    if (_isUploadingID) return;
    setState(() {
      _isUploadingID = true;
    });
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      setState(() {
        _isUploadingID = false;
        _uploadedFilename = "government_id_councillor.jpg";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID card uploaded and verified successfully!'),
          backgroundColor: green,
        ),
      );
    }
  }

  @override
  void dispose() {
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    _phoneController.dispose();
    _employeeIdController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _onOtpInput(String value, int index) {
    if (value.length == 1 && index < 5) {
      _otpFocusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _otpFocusNodes[index - 1].requestFocus();
    }
    
    // Check if OTP is complete
    String otp = _otpControllers.map((c) => c.text).join();
    if (otp.length == 6) {
      _verifyOtpCode(otp);
    }
  }

  void _verifyOtpCode(String otp) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: saffron),
      ),
    );

    final authService = AuthService();
    final user = await authService.verifyOTP(
      otp: otp,
      onError: (error) {
        Navigator.of(context).pop(); // dismiss loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
          ),
        );
      },
    );

    if (user != null) {
      Navigator.of(context).pop(); // dismiss loading dialog
      setState(() {
        _otpVerified = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP Verified successfully ✓'),
          backgroundColor: green,
        ),
      );
    }
  }

  void _onSendOtp() async {
    final employeeId = _employeeIdController.text.trim();
    final phone = _phoneController.text.replaceAll(' ', '').trim();
    
    if (employeeId.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both Employee ID and Mobile number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: saffron),
      ),
    );
    
    try {
      final official = await FirestoreService().getOfficial(employeeId);
      if (official == null || official.mobile != phone) {
        Navigator.of(context).pop(); // dismiss loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Access Denied: Invalid Employee ID or Phone Number.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      final authService = AuthService();
      await authService.sendOTP(
        phoneNumber: phone,
        onCodeSent: (verificationId) {
          Navigator.of(context).pop(); // dismiss loading dialog
          setState(() {
            _otpSent = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OTP sent successfully!'),
              backgroundColor: green,
            ),
          );
        },
        onError: (error) {
          Navigator.of(context).pop(); // dismiss loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    } catch (e) {
      Navigator.of(context).pop(); // dismiss loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const IdentityVerifiedScreen()),
              );
            },
            child: const Text(
              'Bypass Login',
              style: TextStyle(
                color: saffron,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Top Section
                const SizedBox(height: 16),
                Center(
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBGwozBoMKexohJvPCUa0NaNB4YfbRRpQ12unPZOIlA2fjBz6WXeOKhLoqmg1RRiwefc26T-1Fd9Vj_c8zFNxg0RgN7cetELoHhMOJVbFlWA4iijFsE2L58z3z_PjWvfRyGXYKYb--kS_LtvwlhtVrHqM8Ztw62irQ9jfJLJaaopSsWuBCQOmfHQe4nO0KAce0cBFwicobjO_bC90xNK7d2OdG2GdiIfaZL6mOCKufIPmIKG_2s_j53tim6kd6sbrgP8XJyTMYpyUbp',
                    width: 56,
                    height: 56,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.shield_outlined,
                      size: 48,
                      color: saffron,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Hood Officials',
                  style: GoogleFonts.hankenGrotesk(
                    color: navy,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 3,
                  color: saffron,
                ),
                const SizedBox(height: 12),
                Text(
                  'OFFICIAL ACCESS ONLY',
                  style: GoogleFonts.hankenGrotesk(
                    color: muted,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 32),

                // 2. Government ID Upload
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Government ID Verification',
                    style: GoogleFonts.hankenGrotesk(
                      color: navy,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: lightSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: saffron.withOpacity(0.3),
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _uploadedFilename != null ? null : _simulateUpload,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _isUploadingID
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(color: saffron),
                                    SizedBox(height: 12),
                                    Text('Uploading ID Card...', style: TextStyle(color: navy, fontSize: 13, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              )
                            : _uploadedFilename != null
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Icon(Icons.verified, color: green, size: 36),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              _uploadedFilename!,
                                              style: GoogleFonts.inter(
                                                color: navy,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'VERIFIED GOVT ID CARD ✓',
                                              style: GoogleFonts.hankenGrotesk(
                                                color: green,
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () {
                                          setState(() {
                                            _uploadedFilename = null;
                                          });
                                        },
                                      ),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.badge_outlined,
                                        size: 40,
                                        color: saffron,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Upload your official government ID card',
                                        style: GoogleFonts.hankenGrotesk(
                                          color: navy,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Accepted: Govt Employee ID · Municipal ID · Official Letter',
                                        style: GoogleFonts.hankenGrotesk(
                                          color: muted,
                                          fontSize: 10,
                                          fontWeight: FontWeight.normal,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 3. Profile Photo
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Profile Photo',
                    style: GoogleFonts.hankenGrotesk(
                      color: navy,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: lightSurface,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE5E2E1), width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.photo_camera, color: saffron),
                        const SizedBox(height: 4),
                        Text(
                          'ADD PHOTO',
                          style: GoogleFonts.hankenGrotesk(
                            color: muted,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 4. Official Details
                _buildLabel('Full Name'),
                _buildTextField(placeholder: 'As per official records', controller: _nameController),
                const SizedBox(height: 16),
                
                _buildLabel('Employee ID'),
                _buildTextField(placeholder: 'Unique Identification Number', controller: _employeeIdController),
                const SizedBox(height: 16),

                // 5. Designation & Ward Dropdowns
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Designation'),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: lightSurface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _designation,
                                isExpanded: true,
                                icon: const Icon(Icons.expand_more, color: saffron),
                                onChanged: (value) {
                                  setState(() {
                                    _designation = value!;
                                  });
                                },
                                items: <String>['Ward Councillor', 'MLA', 'Nodal Officer', 'Department Head']
                                    .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: GoogleFonts.hankenGrotesk(color: navy, fontSize: 14),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Assigned Ward'),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: lightSurface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _assignedWard,
                                isExpanded: true,
                                icon: const Icon(Icons.expand_more, color: saffron),
                                onChanged: (value) {
                                  setState(() {
                                    _assignedWard = value!;
                                  });
                                },
                                items: <String>['Ward 170', 'Ward 102', 'Ward 103', 'Ward 104', 'Central Zone']
                                    .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: GoogleFonts.hankenGrotesk(color: navy, fontSize: 14),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 6. Phone Verification
                const Divider(color: Color(0xFFE5E2E1)),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Phone Verification',
                    style: GoogleFonts.hankenGrotesk(
                      color: navy,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: lightSurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            Image.network(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuDPqI2yfB5rfCVlQzlfhW8lxF2Bl55xnCmZgYY5yRTcfIRyTWvha6r7mRRNM816cC4S_5U0_35eokF-Dx0c55794hDghPX8vdENJzjO-4jFbLJIOhpolXMhxs_WjBibxYbkgF0l2gFFsilZzSwLZQwQYXxxqQHOMYDSaugcHXS6kEmy9hiHcvDbDuPWETE0gFSAGejvfrERa79fyBbmHwgeRZL3vXZYvtosDWAuj3MsOG9NrMcwr0HS0g_YW9tlDwiYaC7T96hx9PN7',
                              width: 20,
                              errorBuilder: (context, error, stackTrace) => const Text('🇮🇳'),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '+91',
                              style: GoogleFonts.hankenGrotesk(color: navy, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                style: GoogleFonts.hankenGrotesk(color: navy, fontSize: 14),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Mobile Number',
                                  hintStyle: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _onSendOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: saffron,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: const Text('Send OTP'),
                      ),
                    ),
                  ],
                ),
                
                if (_otpSent) ...[
                  const SizedBox(height: 24),
                  // OTP Input Boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 48,
                        height: 48,
                        child: TextField(
                          controller: _otpControllers[index],
                          focusNode: _otpFocusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.hankenGrotesk(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: navy,
                          ),
                          maxLength: 1,
                          decoration: InputDecoration(
                            counterText: '',
                            fillColor: lightSurface,
                            filled: true,
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (value) => _onOtpInput(value, index),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  
                  // Verify OTP outline button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () {
                        String otp = _otpControllers.map((c) => c.text).join().trim();
                        if (otp.length == 6) {
                          _verifyOtpCode(otp);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a 6-digit OTP code'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: saffron,
                        side: const BorderSide(color: saffron, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_otpVerified) const Icon(Icons.check_circle, color: green) else const SizedBox.shrink(),
                          const SizedBox(width: 8),
                          const Text('Verify OTP'),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // 7. Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _otpVerified
                        ? () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => const IdentityVerifiedScreen()),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: saffron,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: saffron.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Submit for Verification',
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 8. Footer Note
                Text(
                  'Hood Officials access is strictly for verified government personnel. Misuse will be reported to authorities.',
                  style: GoogleFonts.hankenGrotesk(
                    color: muted.withOpacity(0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.normal,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, left: 2.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: GoogleFonts.hankenGrotesk(
            color: navy,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required String placeholder, TextEditingController? controller}) {
    return Container(
      decoration: BoxDecoration(
        color: lightSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.hankenGrotesk(color: navy, fontSize: 14),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: placeholder,
          hintStyle: const TextStyle(color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}

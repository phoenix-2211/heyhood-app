import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hey_hood/core/constants/app_colors.dart';
import 'package:hey_hood/services/firestore_service.dart';
import 'package:hey_hood/services/agent_service.dart';

class ReportIssueModal extends StatefulWidget {
  const ReportIssueModal({super.key});

  @override
  State<ReportIssueModal> createState() => _ReportIssueModalState();
}

class _ReportIssueModalState extends State<ReportIssueModal> {
  String? _selectedCategory;
  String _selectedSeverity = "Low";
  String _selectedDuration = "Today";
  final TextEditingController _descriptionController = TextEditingController();

  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  XFile? _capturedPhoto;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _determinePosition();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.medium,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      print("Camera initialization failed: $e");
    }
  }

  Future<void> _determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      
      if (permission == LocationPermission.deniedForever) return;

      final pos = await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 4),
      );
      if (mounted) {
        setState(() {
          _currentPosition = pos;
        });
      }
    } catch (e) {
      print("Geolocation failed or timed out: $e");
    }
  }

  Future<void> _takePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    try {
      final photo = await _cameraController!.takePicture();
      setState(() {
        _capturedPhoto = photo;
      });
    } catch (e) {
      print("Error taking photo: $e");
    }
  }

  void _onPost() async {
    if (_capturedPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please capture a photo of the issue first'),
          backgroundColor: danger,
        ),
      );
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: danger,
        ),
      );
      return;
    }
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please describe the issue'),
          backgroundColor: danger,
        ),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: saffron),
      ),
    );

    try {
      final wardId = FirestoreService.currentWardId;
      final issueId = 'HH-$wardId-${DateTime.now().year}-${Random().nextInt(90000) + 10000}';
      
      // 1. Upload photo to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('issues')
          .child(issueId)
          .child('photo.jpg');
          
      await storageRef.putFile(File(_capturedPhoto!.path));
      final photoUrl = await storageRef.getDownloadURL();

      // 2. Polish description with AI Text Polish Agent
      final polishedDesc = await AgentService.polishText(
        rawText: _descriptionController.text.trim(),
        context: 'issue',
      );

      // 3. Check for duplicates via Duplicate Detection Agent
      final duplicateResult = await AgentService.checkDuplicate(
        issueId: issueId,
        title: '$_selectedCategory issue reported',
        description: polishedDesc,
        category: _selectedCategory!,
        wardId: wardId,
        wardName: 'Adyar',
      );

      if (duplicateResult['action'] == 'merged') {
        if (mounted) {
          Navigator.of(context).pop(); // dismiss loading dialog
          Navigator.of(context).pop(); // close modal
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: darkSurface,
              title: Text('Already Reported', style: GoogleFonts.hankenGrotesk(color: Colors.white, fontWeight: FontWeight.bold)),
              content: Text(
                'This issue is already reported in your neighborhood. Your support has been added to the existing report.',
                style: GoogleFonts.inter(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK', style: GoogleFonts.hankenGrotesk(color: saffron, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        }
        return;
      }

      // 4. Verify report integrity via Fake News Agent
      final verifyResult = await AgentService.verifyImage(
        issueId: issueId,
        photoUrl: photoUrl,
        description: polishedDesc,
        wardId: wardId,
        category: _selectedCategory!,
      );

      final isVerified = verifyResult['action'] == 'publish';

      // 5. Create issue in Firestore
      final issueData = {
        'issue_id': issueId,
        'title': '$_selectedCategory issue reported',
        'description': polishedDesc,
        'category': _selectedCategory!,
        'severity': _selectedSeverity,
        'duration': _selectedDuration,
        'photo_url': photoUrl,
        'status': 'Posted',
        'ward_id': wardId,
        'citizen_id': FirestoreService.currentUserId,
        'latitude': _currentPosition?.latitude ?? 13.0063,
        'longitude': _currentPosition?.longitude ?? 80.2574,
        'verified': isVerified,
      };

      await FirestoreService().createIssue(issueData);

      // 6. Run Routing Agent to assign the councillor and notify them
      if (isVerified) {
        await AgentService.routeIssue(
          issueId: issueId,
          title: '$_selectedCategory issue reported',
          category: _selectedCategory!,
          severity: _selectedSeverity,
          wardId: wardId,
          wardName: 'Adyar',
          lat: _currentPosition?.latitude ?? 13.0063,
          lng: _currentPosition?.longitude ?? 80.2574,
          description: polishedDesc,
        );
      }

      if (mounted) {
        Navigator.of(context).pop(); // dismiss loading dialog
        Navigator.of(context).pop(); // close modal
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Issue reported successfully!'),
            backgroundColor: saffron,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // dismiss loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post issue: $e'),
            backgroundColor: danger,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: darkBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header Bar
          Container(
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
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Text(
                  'Report an Issue',
                  style: GoogleFonts.hankenGrotesk(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: saffron,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  ),
                  onPressed: _onPost,
                  child: Text(
                    'Post',
                    style: GoogleFonts.hankenGrotesk(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Scrollable fields
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Camera Viewfinder
                  Container(
                    height: 240,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: _capturedPhoto != null
                              ? Image.file(
                                  File(_capturedPhoto!.path),
                                  fit: BoxFit.cover,
                                )
                              : (_isCameraInitialized && _cameraController != null
                                  ? CameraPreview(_cameraController!)
                                  : const Center(
                                      child: CircularProgressIndicator(color: saffron),
                                    )),
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(_capturedPhoto != null ? 0.3 : 0.6),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Viewfinder Controls
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 16,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildCameraIcon(
                                _capturedPhoto != null ? Icons.refresh : Icons.flash_off,
                                onTap: () {
                                  if (_capturedPhoto != null) {
                                    setState(() {
                                      _capturedPhoto = null;
                                    });
                                  }
                                },
                              ),
                              // Capture Circle
                              GestureDetector(
                                onTap: _capturedPhoto != null ? null : _takePhoto,
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 3),
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: _capturedPhoto != null ? Colors.grey : saffron,
                                      shape: BoxShape.circle,
                                    ),
                                    child: _capturedPhoto != null
                                        ? const Icon(Icons.check, color: Colors.white, size: 24)
                                        : null,
                                  ),
                                ),
                              ),
                              _buildCameraIcon(Icons.flip_camera_ios),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Text(
                        'LIVE ONLY • NO GALLERY',
                        style: GoogleFonts.hankenGrotesk(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Description Field
                  Text(
                    "What's happening?",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: darkSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: TextField(
                      controller: _descriptionController,
                      maxLines: 3,
                      style: GoogleFonts.inter(color: Colors.white),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(14),
                        hintText: 'Describe the civic issue in detail...',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () async {
                        final rawText = _descriptionController.text.trim();
                        if (rawText.isNotEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('AI is polishing your description...'),
                              duration: Duration(seconds: 4),
                            ),
                          );
                          final polished = await AgentService.polishText(
                            rawText: rawText,
                            context: 'issue',
                          );
                          setState(() {
                            _descriptionController.text = polished;
                          });
                          if (mounted) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Description polished! ✦'),
                                backgroundColor: green,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a description first'),
                              backgroundColor: danger,
                            ),
                          );
                        }
                      },
                      child: Text(
                        'Fix with AI ✦',
                        style: GoogleFonts.hankenGrotesk(
                          color: saffron,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Category Dropdown
                  Text(
                    "Category",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: darkSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        dropdownColor: darkBg,
                        hint: const Text('Select category', style: TextStyle(color: Colors.white30)),
                        icon: const Icon(Icons.expand_more, color: Colors.white30),
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                        onChanged: (v) => setState(() => _selectedCategory = v),
                        items: const [
                          DropdownMenuItem(value: "Road", child: Text("Road")),
                          DropdownMenuItem(value: "Sewage", child: Text("Sewage")),
                          DropdownMenuItem(value: "Safety", child: Text("Safety")),
                          DropdownMenuItem(value: "Lights", child: Text("Lights")),
                          DropdownMenuItem(value: "Waste", child: Text("Waste")),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Severity Dropdown
                  Text(
                    "Severity",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: darkSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedSeverity,
                        dropdownColor: darkBg,
                        icon: const Icon(Icons.expand_more, color: Colors.white30),
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                        onChanged: (v) {
                          if (v != null) setState(() => _selectedSeverity = v);
                        },
                        items: const [
                          DropdownMenuItem(value: "Low", child: Text("Low")),
                          DropdownMenuItem(value: "Medium", child: Text("Medium")),
                          DropdownMenuItem(value: "High", child: Text("High")),
                          DropdownMenuItem(value: "Emergency", child: Text("Emergency")),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Duration Dropdown
                  Text(
                    "Duration",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: darkSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedDuration,
                        dropdownColor: darkBg,
                        icon: const Icon(Icons.expand_more, color: Colors.white30),
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                        onChanged: (v) {
                          if (v != null) setState(() => _selectedDuration = v);
                        },
                        items: const [
                          DropdownMenuItem(value: "Today", child: Text("Today")),
                          DropdownMenuItem(value: "2 to 3 days", child: Text("2 to 3 days")),
                          DropdownMenuItem(value: "1 week", child: Text("1 week")),
                          DropdownMenuItem(value: "More than a week", child: Text("More than a week")),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Location Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: darkSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withOpacity(0.04)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: saffron, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              'Adyar · Ward 170',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.edit,
                          color: Colors.white.withOpacity(0.4),
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Official Assigned Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: darkSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withOpacity(0.04)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              'RK',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ASSIGNED OFFICIAL',
                                style: GoogleFonts.hankenGrotesk(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ward Councillor · Ramesh Kumar',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'Live camera posts only — keeps Hey Hood real and honest.',
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraIcon(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

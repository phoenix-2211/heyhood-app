import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hood_officials/core/constants/app_colors.dart';
import 'package:hood_officials/services/firestore_service.dart';
import 'package:hood_officials/models/models.dart' as model;
import 'package:hood_officials/services/agent_service.dart';

class OfficialsPostContainer extends StatefulWidget {
  final int initialTab; // 0 for Resolve, 1 for Report
  final String? prefilledIssueId;

  const OfficialsPostContainer({
    super.key,
    this.initialTab = 0,
    this.prefilledIssueId,
  });

  @override
  State<OfficialsPostContainer> createState() => _OfficialsPostContainerState();
}

class _OfficialsPostContainerState extends State<OfficialsPostContainer> {
  late int _activeTab; // 0: Resolve, 1: Report
  
  // Resolve Issue Form State
  late TextEditingController _issueIdController;
  final TextEditingController _workDoneController = TextEditingController();
  bool _isIssueFetched = false;
  model.Issue? _fetchedIssue;

  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  XFile? _capturedProofPhoto;

  void _fetchIssueDetails(String id) async {
    if (id.trim().isEmpty) {
      setState(() {
        _fetchedIssue = null;
        _isIssueFetched = false;
      });
      return;
    }
    final issue = await FirestoreService().getIssue(id.trim());
    setState(() {
      _fetchedIssue = issue;
      _isIssueFetched = issue != null;
    });
  }

  // Report Post Form State
  String _postType = 'Notice';
  String _postScope = 'Ward 170';
  bool _isPhotoPost = true;
  final TextEditingController _messageController = TextEditingController();
  bool _hasTakenReportPhoto = false;

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab;
    _issueIdController = TextEditingController(text: widget.prefilledIssueId ?? '');
    _messageController.text = "Scheduled maintenance work for the main pipeline in Sector 4 will take place tomorrow from 10:00 AM to 4:00 PM. Residents are requested to plan accordingly.";
    if (_issueIdController.text.isNotEmpty) {
      _fetchIssueDetails(_issueIdController.text);
    }
    _initializeCamera();
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

  Future<void> _takeProofPhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    try {
      final photo = await _cameraController!.takePicture();
      setState(() {
        _capturedProofPhoto = photo;
      });
    } catch (e) {
      print("Error taking proof photo: $e");
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _issueIdController.dispose();
    _workDoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _aiPolishResolve() {
    setState(() {
      _workDoneController.text = 
        "The road subsidence was addressed by excavating the damaged section, reinforcing the sub-base with graded stone, and applying a new layer of heavy-duty asphalt. Drainage pipes were checked and cleared to prevent future erosion.";
    });
  }

  void _aiPolishReport() {
    setState(() {
      _messageController.text = 
        "Official update for Ward 170: Scheduled maintenance work for the main pipeline in Sector 4 will take place tomorrow from 10:00 AM to 4:00 PM. Residents are requested to plan accordingly and store sufficient water in advance.";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        backgroundColor: lightBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: navy),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Post',
          style: GoogleFonts.hankenGrotesk(
            color: navy,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. Toggle Tab Bar
          Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE5E2E1))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _activeTab = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _activeTab == 0 ? saffron : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        'Resolve the Issue',
                        style: GoogleFonts.hankenGrotesk(
                          color: _activeTab == 0 ? saffron : muted,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _activeTab = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _activeTab == 1 ? saffron : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        'Report to Hood',
                        style: GoogleFonts.hankenGrotesk(
                          color: _activeTab == 1 ? saffron : muted,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Scrollable form area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: _activeTab == 0 ? _buildResolveView() : _buildReportView(),
            ),
          ),
        ],
      ),
    );
  }

  // --- RESOLVE ISSUE VIEW ---
  Widget _buildResolveView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Issue ID search
        Text(
          'Issue ID',
          style: GoogleFonts.hankenGrotesk(color: navy, fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: lightSurface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E2E1)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.tag, color: Colors.grey, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _issueIdController,
                  style: GoogleFonts.hankenGrotesk(color: navy, fontSize: 14),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter Issue ID',
                  ),
                  onChanged: (val) {
                    _fetchIssueDetails(val);
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.qr_code_scanner, color: saffron),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('QR Scanner initiated (mock)')),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Fetched Issue Details Card
        if (_isIssueFetched && _fetchedIssue != null) ...[
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: lightBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E2E1)),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(width: 4, color: green),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _fetchedIssue!.issueId,
                                  style: GoogleFonts.hankenGrotesk(
                                    color: muted,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: danger.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _fetchedIssue!.status.toUpperCase(),
                                    style: GoogleFonts.hankenGrotesk(
                                      color: danger,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _fetchedIssue!.title,
                              style: GoogleFonts.hankenGrotesk(
                                color: navy,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.category, color: muted, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  _fetchedIssue!.category,
                                  style: GoogleFonts.hankenGrotesk(color: muted, fontSize: 11),
                                ),
                                const SizedBox(width: 12),
                                const Icon(Icons.location_on, color: muted, size: 14),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    _fetchedIssue!.description,
                                    style: GoogleFonts.hankenGrotesk(color: muted, fontSize: 11),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.groups, color: muted, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '${_fetchedIssue!.supportCount} supporting',
                                  style: GoogleFonts.hankenGrotesk(color: muted, fontSize: 11),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(color: Color(0xFFF0ECEB)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.schedule, color: danger, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  _fetchedIssue!.resolutionDeadline != null 
                                      ? 'Deadline: ' + _fetchedIssue!.resolutionDeadline!.toString().split(' ').first
                                      : 'No deadline set',
                                  style: GoogleFonts.hankenGrotesk(
                                    color: danger,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle, color: green, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Issue verified and fetched',
                                    style: GoogleFonts.hankenGrotesk(
                                      color: green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ] else if (_issueIdController.text.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Center(
              child: Text(
                'Searching for Issue ID...',
                style: GoogleFonts.hankenGrotesk(color: muted, fontSize: 12),
              ),
            ),
          ),
        ],

        // Proof of Resolution Photo
        Text(
          'Proof of Resolution',
          style: GoogleFonts.hankenGrotesk(color: navy, fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _capturedProofPhoto != null ? null : _takeProofPhoto,
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: lightSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E2E1)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: _capturedProofPhoto != null
                      ? (kIsWeb
                          ? Image.network(
                              _capturedProofPhoto!.path,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(_capturedProofPhoto!.path),
                              fit: BoxFit.cover,
                            ))
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
                          Colors.black.withOpacity(_capturedProofPhoto != null ? 0.2 : 0.5),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_capturedProofPhoto == null)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.photo_camera, color: saffron),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Take live photo',
                        style: GoogleFonts.hankenGrotesk(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: saffron,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(_capturedProofPhoto != null ? Icons.refresh : Icons.camera_alt, color: Colors.white),
                      onPressed: () {
                        if (_capturedProofPhoto != null) {
                          setState(() {
                            _capturedProofPhoto = null;
                          });
                        } else {
                          _takeProofPhoto();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Work description
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Work done',
              style: GoogleFonts.hankenGrotesk(color: navy, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: _aiPolishResolve,
              icon: const Icon(Icons.auto_fix_high, color: saffron, size: 16),
              label: Text(
                'Polish with AI',
                style: GoogleFonts.hankenGrotesk(
                  color: saffron,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: lightSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E2E1)),
          ),
          child: TextField(
            controller: _workDoneController,
            maxLines: 4,
            style: GoogleFonts.hankenGrotesk(color: navy, fontSize: 14),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Describe the work completed...',
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () async {
              final rawText = _workDoneController.text.trim();
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
                  _workDoneController.text = polished;
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
        const SizedBox(height: 32),

        // Mark as Resolved button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () async {
              if (_fetchedIssue == null) return;
              if (_capturedProofPhoto == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please capture a proof of resolution photo first'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              if (_workDoneController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please describe the work completed'),
                    backgroundColor: Colors.red,
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
                final issueId = _fetchedIssue!.issueId;
                
                // 1. Upload proof photo to Firebase Storage
                final storageRef = FirebaseStorage.instance
                    .ref()
                    .child('resolutions')
                    .child(issueId)
                    .child('proof.jpg');
                    
                await storageRef.putData(await _capturedProofPhoto!.readAsBytes());
                final proofUrl = await storageRef.getDownloadURL();

                // 2. Resolve issue in Firestore
                await FirestoreService().resolveIssue(
                  issueId,
                  _workDoneController.text.trim(),
                  proofPhotoUrl: proofUrl,
                );

                if (mounted) {
                  Navigator.of(context).pop(); // dismiss loading dialog
                  Navigator.of(context).pop(); // close post container
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Issue marked as Resolved successfully!'),
                      backgroundColor: green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.of(context).pop(); // dismiss loading dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to resolve issue: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.check_circle),
            label: Text(
              'Mark as Resolved',
              style: GoogleFonts.hankenGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: saffron,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  // --- REPORT TO HOOD (OFFICIAL POST) VIEW ---
  Widget _buildReportView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Post Type Selector
        Text(
          'Post type',
          style: GoogleFonts.hankenGrotesk(color: navy, fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: lightSurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _postType,
              isExpanded: true,
              icon: const Icon(Icons.expand_more, color: saffron),
              onChanged: (val) {
                setState(() {
                  _postType = val!;
                });
              },
              items: <String>['Notice', 'Update', 'Announcement', 'Scheme', 'Warning']
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
        const SizedBox(height: 8),

        // Visual helper chips
        Row(
          children: [
            _buildPostTypeChip('Notice', Colors.blue),
            const SizedBox(width: 8),
            _buildPostTypeChip('Update', green),
            const SizedBox(width: 8),
            _buildPostTypeChip('Announcement', saffron),
          ],
        ),
        const SizedBox(height: 24),

        // Post to (Scope selector)
        Text(
          'Post to',
          style: GoogleFonts.hankenGrotesk(color: navy, fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildScopeButton('Ward 170'),
            const SizedBox(width: 8),
            _buildScopeButton('District'),
            const SizedBox(width: 8),
            _buildScopeButton('State'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.info_outline, color: muted, size: 14),
            const SizedBox(width: 6),
            Text(
              'Posting to $_postScope — 12,400 residents will be notified',
              style: GoogleFonts.hankenGrotesk(color: muted, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Photo/Text Toggle Grid
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isPhotoPost = true),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _isPhotoPost ? Colors.white : lightSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isPhotoPost ? saffron : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.photo_camera, color: _isPhotoPost ? saffron : muted, size: 28),
                      const SizedBox(height: 4),
                      Text(
                        'Add Photo',
                        style: GoogleFonts.hankenGrotesk(
                          color: navy,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Take live photo',
                        style: GoogleFonts.hankenGrotesk(color: muted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isPhotoPost = false),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: !_isPhotoPost ? Colors.white : lightSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: !_isPhotoPost ? saffron : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.notes, color: !_isPhotoPost ? saffron : muted, size: 28),
                      const SizedBox(height: 4),
                      Text(
                        'Text Only',
                        style: GoogleFonts.hankenGrotesk(
                          color: navy,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'No photo needed',
                        style: GoogleFonts.hankenGrotesk(color: muted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Photo capture area (if photo post active)
        if (_isPhotoPost) ...[
          GestureDetector(
            onTap: () => setState(() => _hasTakenReportPhoto = !_hasTakenReportPhoto),
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: lightSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E2E1)),
                image: DecorationImage(
                  image: const NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBUNNwmRfe0GxcS1gaCJLiob_uo4HAiYkZq4SSnEyncH5v26zAosRf-DnQCo8lUb6_aSHXReuiEMdfknz_TK5uL_NNclgIZ7Vh6mATAWUubfX11nArwhB-oX_k89asvwAoqCZGgoJ0nSMjgZVAjzRJRuolIkJoBF3iSqsomzEuRKZVUNyIQmYkKHATrJyum5ILwHsYoPSaPwPa2Z6TWsXm8uE3-XeImgHzTXUqT566dPYoAKi7qG_VfWDNTZkilMnLXYoNWsPPwl0OC',
                  ),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(_hasTakenReportPhoto ? 0.0 : 0.6),
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (!_hasTakenReportPhoto)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.camera_alt, color: Colors.white, size: 36),
                        const SizedBox(height: 6),
                        Text(
                          'Take live photo',
                          style: GoogleFonts.hankenGrotesk(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  Positioned(
                    bottom: 12,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: saffron,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Message input
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your message',
              style: GoogleFonts.hankenGrotesk(color: navy, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: _aiPolishReport,
              icon: const Icon(Icons.auto_fix_high, color: saffron, size: 16),
              label: Text(
                'Polish with AI ✦',
                style: GoogleFonts.hankenGrotesk(
                  color: saffron,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: lightSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E2E1)),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: _messageController,
                maxLines: 4,
                style: GoogleFonts.hankenGrotesk(color: navy, fontSize: 14),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Write your notice or update clearly...',
                ),
                onChanged: (val) {
                  setState(() {}); // trigger rebuild to update live preview
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () async {
              final rawText = _messageController.text.trim();
              if (rawText.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('AI is polishing your message...'),
                    duration: Duration(seconds: 4),
                  ),
                );
                final polished = await AgentService.polishText(
                  rawText: rawText,
                  context: 'post',
                );
                setState(() {
                  _messageController.text = polished;
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Message polished! ✦'),
                      backgroundColor: green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a message first'),
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
        const SizedBox(height: 24),

        // Live Preview Section
        Text(
          'Preview — how it appears on Hey Hood',
          style: GoogleFonts.hankenGrotesk(color: navy, fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: lightSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E2E1)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    backgroundImage: const NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuCFGGri5TF3SJ3q0D1R7oI4M7bo_UzljvpN2M9ifUscdszbXa7HpcWGKRTYW9wP5JNH7tWc90WekBG3-4Oo_eplmpTAlnWaAA_pBia_8crIGKst0lF3V28tY6dhRBG_hXpawIk35hOhmsv9VSTSUwbuxUZP6_jffWtd06Um45sOAyNfUJ_bdIiNfY7wE3sgX_tWusNqBR56syB7kKqHMX3g9rIaj2aHZlzgMYojD84qKKwxv_yDjAL5hoWs2-DEyL2UUYPM8GKEOXpc',
                    ),
                    child: Container(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Official Post',
                              style: GoogleFonts.hankenGrotesk(
                                color: navy,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.verified, color: green, size: 16),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.shield, color: green, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              'Ward Councillor · Ward 170',
                              style: GoogleFonts.hankenGrotesk(
                                color: muted,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Preview Post type tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _postType.toUpperCase(),
                  style: GoogleFonts.hankenGrotesk(
                    color: Colors.blue,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Post text body
              Text(
                _messageController.text.isNotEmpty 
                  ? _messageController.text 
                  : 'Write your notice or update clearly...',
                style: GoogleFonts.hankenGrotesk(
                  color: navy,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Just now',
                        style: GoogleFonts.hankenGrotesk(color: muted, fontSize: 10),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: GoogleFonts.hankenGrotesk(color: muted, fontSize: 10),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Ward 170',
                        style: GoogleFonts.hankenGrotesk(color: muted, fontSize: 10),
                      ),
                    ],
                  ),
                  const Row(
                    children: [
                      Icon(Icons.chat_bubble_outline, color: muted, size: 16),
                      SizedBox(width: 16),
                      Icon(Icons.share_outlined, color: muted, size: 16),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Submit post button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () async {
              final noticeData = {
                'title': _postType + ' Update',
                'description': _messageController.text,
                'category': _postType,
                'ward_id': FirestoreService.currentWardId,
                'posted_by': FirestoreService.currentOfficialId,
                'official_name': FirestoreService.currentOfficialName,
                'official_avatar': 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150',
              };
              await FirestoreService().createNotice(noticeData);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Notice posted to $_postScope successfully!')),
              );
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.campaign),
            label: Text(
              'Post to Hood',
              style: GoogleFonts.hankenGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildPostTypeChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 3, backgroundColor: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.hankenGrotesk(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScopeButton(String scope) {
    final isActive = _postScope == scope;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _postScope = scope;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? saffron : lightSurface,
        foregroundColor: isActive ? Colors.white : navy,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
      child: Text(
        scope,
        style: GoogleFonts.hankenGrotesk(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

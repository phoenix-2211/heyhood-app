import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hey_hood/core/constants/app_colors.dart';
import 'package:hey_hood/screens/wish/select_gallery_screen.dart';
import 'package:hey_hood/screens/wish/wish_here_screen.dart'; // import to get WishItem definition

class PostWishBottomSheet extends StatefulWidget {
  final Function(WishItem) onWishAdded;
  const PostWishBottomSheet({super.key, required this.onWishAdded});

  @override
  State<PostWishBottomSheet> createState() => _PostWishBottomSheetState();
}

class _PostWishBottomSheetState extends State<PostWishBottomSheet> {
  String _selectedCategory = "Facility";
  String _selectedLocation = "Adyar · Ward 170";
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _aiController = TextEditingController();

  bool _isGeneratingImage = false;
  String? _generatedImageUrl;

  void _onPost() {
    if (_titleController.text.trim().isEmpty || _descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both a title and description'),
          backgroundColor: danger,
        ),
      );
      return;
    }

    final newWish = WishItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imageUrl: _generatedImageUrl ?? 'https://images.unsplash.com/photo-1579684389782-64d84b5e905d?w=400',
      category: _selectedCategory,
      area: _selectedLocation.split(' · ')[0],
      title: _titleController.text.trim(),
      desc: _descController.text.trim(),
      supportCount: 1,
      isSupported: true,
      excessFaces: 0,
    );

    widget.onWishAdded(newWish);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Wish posted successfully to ${_selectedLocation}!'),
        backgroundColor: saffron,
      ),
    );
  }

  void _polishWithAI() async {
    if (_descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a draft description first to polish.'),
          backgroundColor: danger,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Polishing description with AI...'),
        backgroundColor: saffron,
        duration: Duration(milliseconds: 800),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 1000));

    if (mounted) {
      setState(() {
        String draft = _descController.text.trim();
        _descController.text = 
            "COMMUNITY PROJECT REQUEST: $draft\n\nThis installation will significantly enhance local safety, accessibility, and neighborhood cohesion. We urge ward authorities to review and allocate infrastructure funds.";
      });
    }
  }

  void _generateAIVisual() async {
    if (_aiController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please describe the visual layout you wish to generate.'),
          backgroundColor: danger,
        ),
      );
      return;
    }

    setState(() {
      _isGeneratingImage = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isGeneratingImage = false;
        // Mock set a gorgeous generated image url based on prompt
        _generatedImageUrl = 'https://images.unsplash.com/photo-1448375240586-882707db888b?w=400';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Visual concept generated successfully!'),
          backgroundColor: green,
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _aiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: darkBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Scrollable Fields
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Post a Wish',
                    style: GoogleFonts.hankenGrotesk(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Image Options Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildImageOptionCard(
                          Icons.auto_awesome,
                          'AI Generate',
                          isActive: _generatedImageUrl != null,
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildImageOptionCard(
                          Icons.search,
                          'Search',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Image Search is in preview mode.')),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildImageOptionCard(
                          Icons.image,
                          'Gallery',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const SelectGalleryScreen()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Generated Image Preview if exists
                  if (_generatedImageUrl != null) ...[
                    Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: NetworkImage(_generatedImageUrl!),
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(color: green.withOpacity(0.4), width: 1.5),
                      ),
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _generatedImageUrl = null;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // AI Preview Area Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: darkSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _aiController,
                          maxLines: 2,
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Describe what you wish for visually...',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: saffron.withOpacity(0.15),
                              foregroundColor: saffron,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _isGeneratingImage ? null : _generateAIVisual,
                            child: _isGeneratingImage
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(color: saffron, strokeWidth: 2),
                                  )
                                : Text(
                                    'Generate ✦',
                                    style: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Form Fields
                  Text(
                    'YOUR WISH',
                    style: GoogleFonts.hankenGrotesk(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F0F0F),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: TextField(
                      controller: _titleController,
                      style: GoogleFonts.inter(color: Colors.white),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        hintText: 'Example: Chess board installation',
                        hintStyle: TextStyle(color: Colors.white30, fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'WHY DOES YOUR HOOD NEED THIS?',
                        style: GoogleFonts.hankenGrotesk(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      GestureDetector(
                        onTap: _polishWithAI,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: saffron.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.auto_awesome, color: saffron, size: 10),
                              const SizedBox(width: 4),
                              Text(
                                'Polish with AI ✦',
                                style: GoogleFonts.hankenGrotesk(
                                  color: saffron,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F0F0F),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: TextField(
                      controller: _descController,
                      maxLines: 4,
                      style: GoogleFonts.inter(color: Colors.white),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        hintText: 'Describe the impact...',
                        hintStyle: TextStyle(color: Colors.white30, fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CATEGORY',
                              style: GoogleFonts.hankenGrotesk(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F0F0F),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withOpacity(0.08)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedCategory,
                                  dropdownColor: darkBg,
                                  icon: const Icon(Icons.expand_more, color: Colors.white30),
                                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                                  onChanged: (v) {
                                    if (v != null) setState(() => _selectedCategory = v);
                                  },
                                  items: const [
                                    DropdownMenuItem(value: "Facility", child: Text("Facility")),
                                    DropdownMenuItem(value: "Infrastructure", child: Text("Infrastructure")),
                                    DropdownMenuItem(value: "Environment", child: Text("Environment")),
                                    DropdownMenuItem(value: "Safety", child: Text("Safety")),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'LOCATION',
                              style: GoogleFonts.hankenGrotesk(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F0F0F),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withOpacity(0.08)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedLocation,
                                  dropdownColor: darkBg,
                                  icon: const Icon(Icons.expand_more, color: Colors.white30),
                                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                                  onChanged: (v) {
                                    if (v != null) setState(() => _selectedLocation = v);
                                  },
                                  items: const [
                                    DropdownMenuItem(value: "Adyar · Ward 170", child: Text("Adyar")),
                                    DropdownMenuItem(value: "HSR Layout · Ward 174", child: Text("HSR Layout")),
                                    DropdownMenuItem(value: "Indiranagar · Ward 80", child: Text("Indiranagar")),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: saffron,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        elevation: 0,
                      ),
                      onPressed: _onPost,
                      child: Text(
                        'Post Wish',
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageOptionCard(
    IconData icon,
    String label, {
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isActive ? saffron.withOpacity(0.12) : darkSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? saffron : Colors.white.withOpacity(0.08),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isActive ? saffron : Colors.white30, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.hankenGrotesk(
                color: isActive ? saffron : Colors.white60,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

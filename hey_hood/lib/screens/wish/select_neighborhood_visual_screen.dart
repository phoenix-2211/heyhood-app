import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hey_hood/core/constants/app_colors.dart';

class SelectNeighborhoodVisualScreen extends StatefulWidget {
  const SelectNeighborhoodVisualScreen({super.key});

  @override
  State<SelectNeighborhoodVisualScreen> createState() => _SelectNeighborhoodVisualScreenState();
}

class _SelectNeighborhoodVisualScreenState extends State<SelectNeighborhoodVisualScreen> {
  int _selectedIdx = 0; // Default to first photo selected matching design
  final TextEditingController _searchController = TextEditingController(text: 'Solar lighting');

  final List<String> _imageUrls = [
    'https://lh3.googleusercontent.com/aida-public/AB6AXuAqHVr3HKxSPN82gyEOeSmaa8LWEgy1n4iVqWeZC1FJOlBhJ03pZOgVIu_uyns0leg-877g0sqHsbCt_EykYg0HkOLE8fkcucBvYuOF0YVl07YgbLICjaggmqU_FOjSAeIQKFNnXt9O6xa6101Ueh2O-MJNnxvtkycxhO63diiNsFRWX73jMzyDYfeBauRkCxYIWwTr2r_I5ZUnD-BGfbSLyGRvoIc3tCm9G9dBUOTWnttMvKRYqoCKwINxVquFHeQIx_iq3xviK-GG',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuA1yzBuDjWiuRk1vveTxyBH68sBmUnv4PhS0nKywl0mSdAq98RwagqYmSIipQ5URFu5GqObgC8NU4j3DFHeBB9dZ_0UJXOE5SuSxyonEfxQLb0oFHbWqDIKiNKdAT81XGfDhEfSXc2iFdYa9HpUNRu7RA3AoQQ6UscgBToyViD4lcRa3G2P0xYGe1SAI56G3P5_gG33C6mlQo5W-aRSaw-TywNSMpa3SI4o6lilhuxrTrbQWmeS9BwEmOE-PkgO0o6xiiMALX6k4OqG',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuA08SgFYkjOxPvjaT-GPVVkMyz-sbVFNgRO1UmKcqaFZULpg-e-Dw4IHlf-Dr7UlwCN5QJ2E2Y7TkEBsCPhxeuXoX7SifsEHCETqfg7nTWlufXAf6gnNoDMomfLIkb4LA3uZFRPeL3f39MdFJpQvCEtu8ccHsUiB4aPTGTKszjE-l5KwK29uAqIKlYiYdQv-AseKX_1FCjwxS1FmlJNxPtG9ZQSQNXMZDMAw8XGPtxBloIv9m-JTd51GbpMuX7_XFbrvO5od8_g5oKI',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuB0fwMYYVzefa4xJrX-rBC_JSUjflfxmJsZo8rtMvihAmS7a72RSKsfq5tO-ODLJkip5mOwuuSp44SLMRkMaycH-DMN_3cZ_16NN5S4fNEzR88SqDTgF0-Gkl2SqYLoROggc1mo3C9oABza-GddI9murixdM7Yn6mf_TWNvZrmFzggCXVvSvnePPwIfgiFoHrcZk-SFhI9hU-JikXV6mHoNX95Ep0KGxGlxwxTC3puZFP6ctvoXGYFSBcBMxInu6sjT0HIaljNdZVaM',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuBBWQFpHqTc6PjtbQN3sU1JjuhNS6kDforu58k5uJdlIwnrOqnRKvR8HI7cuF2Rv6_vIzr8OSY5melMfu9BzwJZZxodQzS3RtGAFdEeAMx9RiZMvT365tlzLquoiHtqkk9v4iZnsaCHVh7ArkKyJRDoomq_dV8mP7_RvleGPCjpqUei7Cu-QoMkwdJ1VA4morbJoobuWD2HWoxkxhgJ3tYTOhyKo8u8KVJDMbWL4Z2wOKsIRtNyG2TCDesgsDwbZP2wy-jV7VvAkSPh',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuAZpJADv67_Nyn3kzahH3gUpTb4A8Po5osSXuhD3FI3jFTCVXHXqdn1WjL91lJkBDOZxcyEZ9hrq5MBjG7Cp3Rud501OByIQsFxupAB6ukzHQ9S7XV0JVhhGdM7TgQyGWZ-4gtOW4b_ZSvpe0f1tvFYMflkxGyfueJz8cVubzfCO4tb7UEFVgc3vwplwdYwTUun_7XmgpoDHCr0OaEfi--4966sLzYXI_HJE0WhKpu9cGud_-weoyiQnKjt4yissQGQ_f7f_yBeibfw',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuAgI6oeRlbmAfy0hQrR0PoEvxH18NdvvH5BxP3bBRkj70FAmaik3CRhpl6tG_EG87pvOs_OuDVzU7WDI5hOkqMBhtZi8Ui9Efrr4qVAHgdAPMwFjKcK-YVFKnwIah5tcpmEZ7c2wAaKQqB8PNpPS5-Xy8gQWP04D2HobDeta9IMhGDlG6KVhKgMZuJRJfdHR4Bw29YUDSQfGQOWu6yx5lWA5kvrycIsEJDSDSPkJKAOxV_ocepM-HD7_kN073SKbsUIyR214IHevWeS',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuBQypz5XvADS3F6CaucMlkYXwHA1khqY6zj6OW6UP_fQE4rnBiUzu3ybqCUq6BZ_fCUqNauL6A15-YXuWqs3lx9gdDfHvGXQSL67GJe03CdOPGKb-f-kU998s1PMp6sTvZDZVjZcTNmfplKK9h8Is5MF02M_pvcFZv5z-n8Qd3epAhu392YYFKV126dkfrtKGv6M2_pOfh9JXEQ8yYPUQop7oMLvpTWibj7GsCNAVqPA8l2qxxcLQzzHQepiGHZ7Up684sInAqcELYw',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuBArmiqb_P1lD8hZ-BiZIJyx9QVwpFAJVxpIqrRmX19OFEfV_tYUqYo_nvaCYUuwRm5Prhb183XGBmrHabzRr9VY5dHZaTFUsHCsDWEOgUuBhiQ4t8xnGhmX0OBV1HnM2iRyBcJVoZTaCbvpbmBPm4Y03MK02LP0xqHqd1jZv3LyQ8zhsU9GoVEcq7UUsAs2VaA-Ou8OljzzgN0CrW3UJ3yldp7wCxpn1b6AgF4tAyqWmMqNHd2SS2n1vSzuqfF6gkq0fUqRLRJ9N0O',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: saffron),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Search Image',
          style: GoogleFonts.hankenGrotesk(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
              image: const DecorationImage(
                image: NetworkImage(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuDKSPynJzbnnIqIa5hdeKN8na4CdLHHD8usykyL1ZH89f2FI2keeGvlfzQ9pXwk4stL6ua5yJDF4X7K0OemjOkQqIH5VHTqYSjbbQpsTqSi9UqwpBOjJWoxXF4VXWZLXPcPtRBRBLJw5Armoo1O30M1YVSvCjSu4sgHJyVp8cb9PztihaDXEr6fAyifyIqJ4vPhQys4O2zihL88ITIEWIgnBU7XbRVUN1FDCqW2Ux1sGUBYcGGA6O1oJ6U3zV5kFWJt1ddBCQUP5sJD',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: darkSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.inter(color: Colors.white),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: saffron),
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          // Filter Chips
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterChip('Lighting', isActive: true),
                const SizedBox(width: 8),
                _buildFilterChip('Parks'),
                const SizedBox(width: 8),
                _buildFilterChip('Safety'),
                const SizedBox(width: 8),
                _buildFilterChip('Infrastructure'),
                const SizedBox(width: 8),
                _buildFilterChip('Sustainability'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Photo Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: _imageUrls.length,
              itemBuilder: (context, idx) {
                final isSelected = _selectedIdx == idx;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIdx = idx),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? saffron : Colors.white.withOpacity(0.08),
                              width: isSelected ? 4 : 1,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.network(
                            _imageUrls[idx],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[900]),
                          ),
                        ),
                      ),
                      if (isSelected)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: saffron,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.check, color: Colors.black, size: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Bottom CTA
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  darkBg,
                  darkBg.withOpacity(0.9),
                  Colors.transparent,
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: saffron,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Select Image',
                          style: GoogleFonts.hankenGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Step 2 of 4 • Design Your Wish',
                  style: GoogleFonts.hankenGrotesk(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? saffron.withOpacity(0.15) : darkSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? saffron : Colors.white.withOpacity(0.08),
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.hankenGrotesk(
            color: isActive ? saffron : Colors.white.withOpacity(0.6),
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

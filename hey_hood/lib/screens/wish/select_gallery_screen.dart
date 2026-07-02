import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hey_hood/core/constants/app_colors.dart';

class SelectGalleryScreen extends StatefulWidget {
  const SelectGalleryScreen({super.key});

  @override
  State<SelectGalleryScreen> createState() => _SelectGalleryScreenState();
}

class _SelectGalleryScreenState extends State<SelectGalleryScreen> {
  final Set<int> _selectedIndices = {0, 2, 4}; // Default to 3 selected matching design

  final List<String> _imageUrls = [
    'https://lh3.googleusercontent.com/aida-public/AB6AXuD5WboGPHU_ygMocNAdCvTojEZzV_CqZmnFtvO2SNRNm4b2hDO5AZV0B1cEwiYOlhqdpqUeFDqwhXnv5C4xpMfv6cXqFiRKI8uqDh9Sg-ni8Yfz-TEc8UKTfOr68qd6WjSCOv2kRwWiy3xWVRUcghOMpLZwMqU8cPtNOdXeO9gI6KrDToOEtX4sD2DI-f1lUwL5wpF_TG9CkV2pdBPHb1oXTVUUJ9gG7akC_QUU2ykA8J3BHlvQPz-An94KUM9mAdxtr9IEhbU98sA5',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuAlX6V_aGDIEegP33H81pdnlrr-bZYYqt76SBu1FtaX1LoWLW9j5O4TI0KzXB6WZL1gqTuLGGvmk2W3j6UnyznPYpel4JL2E85y4QyRnzvIMa6dqS0ViTresne6AvgdJiQmIaj2W5pwDVP6fr8Xtz5JOvHhahNaPNkeoLsJa1ehydzJrq34pBDFWj3KSQoS2wX1L0dgv36KHFlAP2Rd6DLIGhYFVCLviJ1lOcMTPmk-3wpK7wgxajqRRyDc4m_H6I-e_kkp5383GekT',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuBuNaXaS7VOvyaDvvGXHdUS3tLkoO3W5rLvEvbiFHU5v4BEkoUaIgK5fIFdoauvy8Bo5BO99_cytA6x0fUgZrqtRD8wWa1FpEOa5nIDh8l4g2VnSI42yqZbEwn0XodozCe9eRM-Ds41dE0RIDQ4bm9hORlqB435b1UU50Mc4ugZPgY1ewSvYC01jELLRP8Y6k1W4eBU5UJVPWnFQnP1HjgLP7VI0Ha_B6R2DMEUO9ocS0DtPQJzN62ZPINtbLSmj-gVD020xmfTty_s',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuAHyV6s51sSNbI8fNMDL8SKPoSCerHurwItSiSg5SmjRdBMs5gsynYwdGEdsjDi8rA509vDZyYHtkNbueUdUZuUwdHNp9WKxsCbbnnVrziWWuyjCvAXaoW-VJu8k8K44xJG6QvDTykssuT6vzdnfb-7QTFCp2syjKgDuEN02iMkdBF7a6cUOUGW91HGNhz8dfha5CEB89Wx4hh2E1MXqqICAJVFUHwQUuwHa6up6gJD7Sy4IYoik1aA4Jb2PVlH2HJEZPVNsWpuls9W',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuA_eOwYZgmDdSptDwAVJSn3y_6iPIMneEfXbevlrpXOyfdkKGVqpCjDZC4R22t962QkLtk1uxYCJ9NLe5uOmYJ4N6YFw5pY8hPLzwpDWA5NjmIrN6-UbW2BCEUBcD3XoIKydS-vmqZh1cIvUftafSVxgVh9ijkxUuHOOslGN79YpM5cVnuV-xPAGBcsibAGOX72fOmiy6OYiKVrADe2svt7AFOcq2JBhCiVb10l4yb3D1DitfDzbTRDQD1jmslHifHhPkJm94POOLT1',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuCpud5P1IJWC1RdiL1ARuI-6Y2UvGQfjy3RUUXbMvorDdnodlVsSIgECuDnYNKfn1O_mXXYZbCSU0V1iaDSZANZrD0UV97STNXdCJr6N0t7zTCHcwUP4SKRV5qrWUzlW9IF16vgEp1E5ZmaH1sXPDbsHh9PwbZWjajXuyPZ7OPkn_V7HXYCsK51RojddHVrkAGh5De8B3RrfgsMcp3PZ0Ny6scJfmCMK_E2JDcAc_dHp6S1d-xs56sTVZbueaQ7SdQBfebTWs69GDut',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuCLMznHg8CtSBfwHS1iyNw7-ADdTeJEM42Qeld3rg3iF3jCdvQysAeRQ6R6-0HPY-6nYkxiCQFvBzjfBD6sak_Hx6iPC3qQC2NE8wYlMIgzFnhc6HiMTTADkj5NqGQIUECY8mgOGiHdpUY8n6SyLCJZtXYDoxouNPnncpyQ33oZ4i3w1ojIaw6FWIcvP0M9FioD5se_1_703cRCJ4dwn9dloBf-GZImkcLAOacBlYyO82z_ZtaxfrG2JLOPhOc440-U5AmVFdBrKgHm',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuCwN5pOVJdihVEpQaaWVYZ1WGTsz5aX0eNkZhcfaDD07ohb1fYc2yAX821RpgAyAxbZ4oZuc20OZmz67AccBmYSPT4g7mMoynjM_Rp41-kEvsdGyrTAnTnJvNqH_fZ2Oj3BmGfgAam7Ui7xVkBFPcS7IHDic0sqGYrOIuUkYukrdGDNjgsVd2wvXd0IjtCQOxBf4XZfTjMYC6K5XaZjunnTuDZIg1DuzZ7KMHcpgQW20gY3x4OhTy02uIWH7NkfOv607jnAAnqUZbqA',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuC96WyjJ0OU4-hLbQ0hHccpZmisgXL1oMouqgXxJL7RcSBNqmBOD7HcuUsaUuHtadHuN9rkbufeDfQW5Xxc-W5oCtXG7OYWy3uxLN5yg9IAvXEicl8yWcBgKJwzeQHvn3idxoob1CQ40W0UlqDyIhWJF6jV7AgqnSEViFefmjgjhyUGUrhbPE-6jfqnsQ7jFoijuWAr0ylPVe9fgXIgKwYge--c7Xv8fTK1S0z2RuWmQ3XiUsbyZ3D9KcVqKMKLqnaHBr2EqhE-ktBS',
  ];

  void _onToggleSelect(int idx) {
    setState(() {
      if (_selectedIndices.contains(idx)) {
        _selectedIndices.remove(idx);
      } else {
        _selectedIndices.add(idx);
      }
    });
  }

  void _onDone() {
    Navigator.of(context).pop();
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
          'Select Gallery',
          style: GoogleFonts.hankenGrotesk(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _onDone,
            child: Text(
              'Done (${_selectedIndices.length})',
              style: GoogleFonts.hankenGrotesk(
                color: saffron,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter Scroll Row
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterChip('All Photos', isActive: true),
                const SizedBox(width: 8),
                _buildFilterChip('Recent'),
                const SizedBox(width: 8),
                _buildFilterChip('Favorites'),
                const SizedBox(width: 8),
                _buildFilterChip('Camera'),
                const SizedBox(width: 8),
                _buildFilterChip('Screenshots'),
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
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _imageUrls.length,
              itemBuilder: (context, idx) {
                final isSelected = _selectedIndices.contains(idx);
                return GestureDetector(
                  onTap: () => _onToggleSelect(idx),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? saffron : Colors.white.withOpacity(0.08),
                              width: isSelected ? 3 : 1,
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
                        const Positioned(
                          top: 6,
                          right: 6,
                          child: Icon(
                            Icons.check_circle,
                            color: saffron,
                            size: 20,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // Floating pill showing count
      floatingActionButton: _selectedIndices.isNotEmpty
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: saffron,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.photo_library, color: Colors.black, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    '${_selectedIndices.length} selected',
                    style: GoogleFonts.hankenGrotesk(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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

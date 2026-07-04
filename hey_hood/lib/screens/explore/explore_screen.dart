import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hey_hood/core/constants/app_colors.dart';
import 'package:hey_hood/services/firestore_service.dart';
import 'package:hey_hood/models/models.dart';
import 'package:hey_hood/screens/explore/area_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final FirestoreService _firestore = FirestoreService();
  List<Ward> _wards = [];
  bool _isLoading = true;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  List<Ward> get _filteredWards {
    if (_searchQuery.isEmpty) return [];
    final query = _searchQuery.toLowerCase();
    return _wards.where((w) {
      return w.wardName.toLowerCase().contains(query) ||
          w.wardNumber.toString().toLowerCase().contains(query) ||
          w.district.toLowerCase().contains(query) ||
          w.zone.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadWards();
  }

  Future<void> _loadWards() async {
    try {
      final wards = await _firestore.getAllWards();
      if (mounted) {
        setState(() {
          _wards = wards;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading wards: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _selectWard(Ward ward) {
    setState(() {
      FirestoreService.currentWardId = ward.wardId;
      FirestoreService.currentWardName = ward.wardName;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Switched active ward to ${ward.wardName} (Ward ${ward.wardNumber})'),
        duration: const Duration(seconds: 2),
        backgroundColor: saffron,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.4),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'HEY HOOD',
          style: GoogleFonts.hankenGrotesk(
            color: saffron,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: -1,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white70),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: darkSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                style: GoogleFonts.inter(color: Colors.white),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search any area, ward, city...',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.white30,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white30),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = "";
                            });
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),
          
          if (_searchQuery.isNotEmpty)
            Expanded(
              child: _filteredWards.isEmpty
                  ? Center(
                      child: Text(
                        'No matching areas or wards found',
                        style: GoogleFonts.hankenGrotesk(color: Colors.white38, fontSize: 14),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredWards.length,
                      itemBuilder: (context, index) {
                        final ward = _filteredWards[index];
                        return Card(
                          color: darkSurface,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(Icons.location_on, color: saffron),
                            title: Text(
                              "Ward ${ward.wardNumber} · ${ward.wardName}",
                              style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "${ward.zone} · ${ward.district}, ${ward.state}",
                              style: const TextStyle(color: Colors.white38, fontSize: 11),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 12),
                            onTap: () {
                              _selectWard(ward);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AreaDetailScreen(ward: ward),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Map Visualization Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        height: 220,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            // Satellite grid image placeholder
                            Positioned.fill(
                              child: Image.network(
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuBrX8Xp8po7b3HoG6zJqlVnU88EnTjY9mpUzLdzX23MADl6ClRMYbbFl3SXufPUugyQ1Oa3G_-wAVQZzUij1GGEqViSK3jRlOyur01GZzuWot4thbmqDy0lQRowkaShmIQ09W9NaKhSHOx7iYbd-KunagH3AggQQjio8d3bKblhTcGRsfXo8I_3t6uYRUWDdo6mBMzMaNEibDVMbcLefpY1dbvr-OC7t4S7XF0GKCkiw4kO1rmriKulBnIBbM8Q2VnQ9Zc6hlKVWArj',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[900]),
                              ),
                            ),
                            // Centered pulse marker
                            Center(
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: saffron.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: saffron,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Ward Pins overlay
                            Positioned(
                              top: 40,
                              left: 32,
                              child: _buildWardPin('Ward 170 • 34', danger),
                            ),
                            Positioned(
                              bottom: 60,
                              right: 32,
                              child: _buildWardPin('Ward 75 • 78', green),
                            ),
                            Positioned(
                              top: 100,
                              right: 80,
                              child: _buildWardPin('Ward 22 • 52', saffron),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Nearby Wards Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              const Icon(Icons.explore, color: saffron, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'WARDS NEAR YOU',
                                style: GoogleFonts.hankenGrotesk(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 190,
                          child: _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : _wards.isEmpty
                                  ? const Center(child: Text("No wards found", style: TextStyle(color: Colors.white38)))
                                  : ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      itemCount: _wards.length,
                                      itemBuilder: (context, index) {
                                        final ward = _wards[index];
                                        final isCurrent = ward.wardId == FirestoreService.currentWardId;
                                        return GestureDetector(
                                          onTap: () {
                                            _selectWard(ward);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => AreaDetailScreen(ward: ward),
                                              ),
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(right: 12.0),
                                            child: Container(
                                              width: 140,
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: darkSurface,
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: isCurrent ? saffron.withOpacity(0.5) : Colors.white.withOpacity(0.04),
                                                  width: isCurrent ? 2.0 : 1.0,
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    ward.wardName,
                                                    style: GoogleFonts.inter(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    "Ward ${ward.wardNumber}".toUpperCase(),
                                                    style: GoogleFonts.hankenGrotesk(
                                                      color: Colors.white.withOpacity(0.4),
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Center(
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          "${ward.pulseScore}",
                                                          style: GoogleFonts.hankenGrotesk(
                                                            color: ward.pulseScore >= 70 ? green : saffron,
                                                            fontSize: 28,
                                                            fontWeight: FontWeight.w800,
                                                          ),
                                                        ),
                                                        Text(
                                                          'PULSE',
                                                          style: GoogleFonts.hankenGrotesk(
                                                            color: Colors.white.withOpacity(0.4),
                                                            fontSize: 9,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      ward.zone,
                                                      style: GoogleFonts.hankenGrotesk(
                                                        color: Colors.blue[300],
                                                        fontSize: 9,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Container(height: 1, color: Colors.white10),
                                                  const SizedBox(height: 6),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          "${ward.district}",
                                                          style: GoogleFonts.inter(
                                                            color: Colors.white.withOpacity(0.4),
                                                            fontSize: 9,
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                      Icon(
                                                        Icons.check_circle_outline,
                                                        color: isCurrent ? saffron : Colors.white24,
                                                        size: 12,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Hot Right Now Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.local_fire_department, color: saffron, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'HOT RIGHT NOW ACROSS INDIA',
                                style: GoogleFonts.hankenGrotesk(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildHotIssueCard(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuCexYBE4d4IPthOSgHQRRQxQu3DDtUPJl18daFurwU9AC9Q2G0af47kzV4tJh8KwvCLppzQat7OPgsN3MbDIXdl6eIe-9jF6n3UFgNPc-eGGThD9AYzpewP_kQXreQxe8cuNTxE7QxXFg8LfejtEBNsAoJ0bRau0ovyIovvlaPMP6hrroxT21l8KsecaLWbbUsd-F8Uf6iL4Bl5qhqMf4rSyxWXn9jRFmb8cuUh9ap7MXms9m-QvhsK4ASErIrLwm1_GfwDAJJrV4vF',
                            'Mumbai, MH',
                            'Severe Potholes on Western Express Highway',
                            '1.2k supporting',
                            'Urgent',
                            danger,
                          ),
                          const SizedBox(height: 12),
                          _buildHotIssueCard(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuDILW7v1qYfrMCkCvzM_FZ_hSlfn0-UFutjpNA-5SDggXY4W18kaiqVx4uPDCS16GzgRnxe4mX94FZNki0lgxxBAEnU9AcnAIOLMs5Tvw0OPyrg19LMu5Du7JoPmSiIqcI_LVAoDdLpyJ57wx6Sq-imckyNygvRQPE7dYhrfCZUXrqhRwNHqJY_ViKwJDdeeAYNhmRsYHjdAjfNpS1dgO6su3DvcaIo4BZkk-z0610kCIVs31x-lk6zp1ylmxD5zkdPB34X7UgDverA',
                            'Chennai, KA',
                            'Dark Spots: Broken Streetlights in Jayanagar',
                            '840 supporting',
                            'In Progress',
                            amber,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Browse by state Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              const Icon(Icons.map, color: saffron, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'BROWSE BY STATE',
                                style: GoogleFonts.hankenGrotesk(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 48,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            children: [
                              _buildStatePill('Tamil Nadu', '847', isActive: true),
                              const SizedBox(width: 8),
                              _buildStatePill('Tamil Nadu', '623'),
                              const SizedBox(width: 8),
                              _buildStatePill('Maharashtra', '1.2k'),
                              const SizedBox(width: 8),
                              _buildStatePill('Delhi', '950'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWardPin(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.hankenGrotesk(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }



  Widget _buildHotIssueCard(
    String imageUrl,
    String location,
    String title,
    String supportCount,
    String statusLabel,
    Color statusColor,
  ) {
    return GestureDetector(
      onTap: () {
        if (_wards.isNotEmpty) {
          final targetWard = _wards.firstWhere(
            (w) => w.wardId == "TN-CHN-170",
            orElse: () => _wards.first,
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AreaDetailScreen(ward: targetWard),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: darkSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.04),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.toUpperCase(),
                    style: GoogleFonts.hankenGrotesk(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        supportCount,
                        style: GoogleFonts.inter(
                          color: saffron,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: statusColor.withOpacity(0.2)),
                        ),
                        child: Text(
                          statusLabel.toUpperCase(),
                          style: GoogleFonts.hankenGrotesk(
                            color: statusColor,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatePill(String name, String count, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? saffron.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? saffron : Colors.white.withOpacity(0.12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: GoogleFonts.hankenGrotesk(
              color: isActive ? saffron : Colors.white.withOpacity(0.6),
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            count,
            style: GoogleFonts.hankenGrotesk(
              color: isActive ? saffron.withOpacity(0.7) : Colors.white.withOpacity(0.3),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

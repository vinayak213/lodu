import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../constants/colors.dart';
import '../models/club.dart';
import '../services/club_service.dart';
import '../services/places_service.dart';
import '../services/besttime_service.dart';
import '../services/groq_service.dart';
import 'club_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<Club> clubs = [];
  bool isLoading = true;
  Club? selectedClub;
  double userLat = 12.9716;
  double userLng = 77.5946;

  @override
  void initState() {
    super.initState();
    _loadClubs();
  }

  Future<void> _loadClubs() async {
    final googleKey = dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';
    final besttimeKey = dotenv.env['BESTTIME_API_KEY'] ?? '';
    final groqKey = dotenv.env['GROQ_API_KEY'] ?? '';

    final service = ClubService(
      placesService: googleKey.isNotEmpty ? PlacesService(apiKey: googleKey) : null,
      besttimeService: besttimeKey.isNotEmpty ? BesttimeService(apiKey: besttimeKey) : null,
      groqService: groqKey.isNotEmpty ? GroqService(apiKey: groqKey) : null,
    );

    try {
      final results = await service.getNearbyClubs(lat: userLat, lng: userLng);
      setState(() {
        clubs = results;
        isLoading = false;
      });
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  Color _crowdColor(int crowd) {
    if (crowd < 15) return const Color(0xFF30D158);
    if (crowd < 35) return AppColors.accent;
    if (crowd < 55) return const Color(0xFFFFD60A);
    if (crowd < 75) return AppColors.warning;
    return const Color(0xFFFF2D55);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  Text(
                    'MAP VIEW',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.accent,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.infoDim,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${clubs.length} clubs',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        color: AppColors.info,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Map area
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
                  : Stack(
                      children: [
                        // Simplified map grid background
                        _buildMapGrid(),
                        // Club markers
                        ...clubs.asMap().entries.map((entry) {
                          final i = entry.key;
                          final club = entry.value;
                          return _buildClubMarker(club, i);
                        }),
                        // User location marker
                        Center(
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: AppColors.info,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.info.withValues(alpha: 0.4),
                                  blurRadius: 10,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Selected club card
                        if (selectedClub != null)
                          Positioned(
                            left: 14,
                            right: 14,
                            bottom: 14,
                            child: _buildSelectedClubCard(),
                          ),
                        // Legend
                        Positioned(
                          top: 12,
                          right: 12,
                          child: _buildLegend(),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapGrid() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: CustomPaint(
        painter: _GridPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }

  Widget _buildClubMarker(Club club, int index) {
    final rng = Random(club.name.hashCode);
    final screenWidth = MediaQuery.of(context).size.width - 28;
    final screenHeight = MediaQuery.of(context).size.height * 0.5;

    // Distribute markers pseudo-randomly
    final x = 30.0 + rng.nextDouble() * (screenWidth - 80);
    final y = 60.0 + rng.nextDouble() * (screenHeight - 120);
    final isSelected = selectedClub?.id == club.id;
    final color = _crowdColor(club.currentCrowd);

    return Positioned(
      left: x,
      top: y,
      child: GestureDetector(
        onTap: () => setState(() => selectedClub = isSelected ? null : club),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(isSelected ? 6 : 4),
                decoration: BoxDecoration(
                  color: isSelected ? color : color.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 12, spreadRadius: 2)]
                      : [],
                ),
                child: Text(
                  '${club.currentCrowd}',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: isSelected ? 10 : 8,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              if (isSelected)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: color),
                  ),
                  child: Text(
                    club.name,
                    style: TextStyle(fontSize: 8, color: color, fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedClubCard() {
    final club = selectedClub!;
    final color = _crowdColor(club.currentCrowd);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ClubDetailScreen(club: club)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          border: Border.all(color: color.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20),
          ],
        ),
        child: Row(
          children: [
            // Crowd circle
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.15),
                border: Border.all(color: color, width: 2),
              ),
              child: Center(
                child: Text(
                  '${club.currentCrowd}%',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    club.name,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.text),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '${club.distanceKm.toStringAsFixed(1)} km',
                        style: GoogleFonts.jetBrainsMono(fontSize: 11, color: AppColors.textMuted),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.star, size: 12, color: const Color(0xFFFFD60A)),
                      Text(' ${club.rating.toStringAsFixed(1)}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ),
                  if (club.aiInsight != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '🤖 ${club.aiInsight}',
                        style: TextStyle(fontSize: 10, color: AppColors.accent),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textDim),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Crowd Level', style: GoogleFonts.jetBrainsMono(fontSize: 8, color: AppColors.textMuted)),
          const SizedBox(height: 6),
          _legendItem(const Color(0xFF30D158), 'Dead <15%'),
          _legendItem(AppColors.accent, 'Chill 15-35%'),
          _legendItem(const Color(0xFFFFD60A), 'Moderate 35-55%'),
          _legendItem(AppColors.warning, 'Busy 55-75%'),
          _legendItem(const Color(0xFFFF2D55), 'Packed 75%+'),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.jetBrainsMono(fontSize: 8, color: AppColors.textDim)),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.3)
      ..strokeWidth = 0.5;

    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

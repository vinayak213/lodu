import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';
import '../models/club.dart';
import '../widgets/crowd_indicator.dart';
import '../widgets/crowd_chart.dart';

class ClubDetailScreen extends StatefulWidget {
  final Club club;

  const ClubDetailScreen({super.key, required this.club});

  @override
  State<ClubDetailScreen> createState() => _ClubDetailScreenState();
}

class _ClubDetailScreenState extends State<ClubDetailScreen> {
  bool hasCheckedIn = false;
  String? selectedCrowdReport;

  @override
  Widget build(BuildContext context) {
    final club = widget.club;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          // App bar with image
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.card,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: club.photoUrl != null
                  ? Image.network(
                      club.photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildHeroPlaceholder(club),
                    )
                  : _buildHeroPlaceholder(club),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Club name + type
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              club.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppColors.text,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              club.vicinity ?? club.address,
                              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      CrowdIndicator(crowdPercent: club.currentCrowd, size: 64),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Quick info row
                  _buildInfoRow(club),

                  const SizedBox(height: 16),

                  // AI Insight Card
                  if (club.aiInsight != null) _buildAiInsightCard(club),

                  const SizedBox(height: 20),

                  // Crowd Timeline Chart
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: CrowdChart(
                      history: club.crowdHistory,
                      currentHour: DateTime.now().hour,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Check-in Section
                  _buildCheckinSection(),

                  const SizedBox(height: 20),

                  // Details Section
                  _buildDetailsSection(club),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroPlaceholder(Club club) {
    Color typeColor;
    IconData typeIcon;
    switch (club.type) {
      case 'nightclub':
        typeColor = AppColors.secondary;
        typeIcon = Icons.nightlife;
        break;
      case 'bar':
        typeColor = AppColors.warning;
        typeIcon = Icons.local_bar;
        break;
      case 'lounge':
        typeColor = AppColors.info;
        typeIcon = Icons.weekend;
        break;
      default:
        typeColor = AppColors.accent;
        typeIcon = Icons.sports_bar;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [typeColor.withValues(alpha: 0.4), AppColors.bg],
        ),
      ),
      child: Center(
        child: Icon(typeIcon, size: 80, color: typeColor.withValues(alpha: 0.4)),
      ),
    );
  }

  Widget _buildInfoRow(Club club) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _infoItem(Icons.star, club.rating.toStringAsFixed(1), 'Rating', const Color(0xFFFFD60A)),
          _divider(),
          _infoItem(Icons.location_on, '${club.distanceKm.toStringAsFixed(1)} km', 'Distance', AppColors.info),
          _divider(),
          _infoItem(
            Icons.circle,
            club.isOpen ? 'Open' : 'Closed',
            'Status',
            club.isOpen ? const Color(0xFF30D158) : const Color(0xFFFF2D55),
          ),
          if (club.cover != null) ...[
            _divider(),
            _infoItem(Icons.confirmation_number, club.cover!, 'Cover', AppColors.secondary),
          ],
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textDim)),
      ],
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 35, color: AppColors.border);
  }

  Widget _buildAiInsightCard(Club club) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withValues(alpha: 0.08),
            AppColors.secondary.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🤖', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                'AI CROWD INSIGHT',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.secondaryDim,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Groq + LLaMA 3',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 8,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            club.aiInsight!,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.text,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckinSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📍 CHECK IN',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Help others — report how crowded it is!',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 14),
          if (!hasCheckedIn) ...[
            // Crowd report options
            Text(
              'How crowded is it?',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _crowdReportOption('Dead', '💀', const Color(0xFF30D158)),
                _crowdReportOption('Chill', '😎', AppColors.accent),
                _crowdReportOption('Moderate', '🙂', const Color(0xFFFFD60A)),
                _crowdReportOption('Busy', '😰', AppColors.warning),
                _crowdReportOption('Packed', '🤯', const Color(0xFFFF2D55)),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: selectedCrowdReport != null
                    ? () {
                        setState(() => hasCheckedIn = true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Check-in recorded! 🎉 Thanks for helping the community.'),
                            backgroundColor: AppColors.card,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: selectedCrowdReport != null
                        ? AppColors.accent
                        : AppColors.border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'CHECK IN',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: selectedCrowdReport != null
                            ? AppColors.bg
                            : AppColors.textDim,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF30D158).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF30D158), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You checked in as "$selectedCrowdReport" — thanks! 🙌',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF30D158)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _crowdReportOption(String label, String emoji, Color color) {
    final isSelected = selectedCrowdReport == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedCrowdReport = label),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.02),
            border: Border.all(
              color: isSelected ? color : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? color : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsSection(Club club) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DETAILS',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          if (club.music != null)
            _detailRow(Icons.music_note, 'Music', club.music!, AppColors.secondary),
          if (club.cover != null)
            _detailRow(Icons.confirmation_number, 'Cover', club.cover!, AppColors.warning),
          _detailRow(Icons.people, 'Reviews', '${club.userRatingsTotal} reviews', AppColors.info),
          _detailRow(Icons.category, 'Type', club.type[0].toUpperCase() + club.type.substring(1), AppColors.accent),
          _detailRow(Icons.location_on, 'Address', club.address, AppColors.textMuted),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 10),
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                color: AppColors.textDim,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

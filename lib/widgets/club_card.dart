import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';
import '../models/club.dart';
import 'crowd_indicator.dart';

class ClubCard extends StatelessWidget {
  final Club club;
  final VoidCallback onTap;

  const ClubCard({super.key, required this.club, required this.onTap});

  Color get typeColor {
    switch (club.type) {
      case 'nightclub':
        return AppColors.secondary;
      case 'bar':
        return AppColors.warning;
      case 'lounge':
        return AppColors.info;
      default:
        return AppColors.accent;
    }
  }

  IconData get typeIcon {
    switch (club.type) {
      case 'nightclub':
        return Icons.nightlife;
      case 'bar':
        return Icons.local_bar;
      case 'lounge':
        return Icons.weekend;
      default:
        return Icons.sports_bar;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Photo section
            if (club.photoUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: Image.network(
                    club.photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                  ),
                ),
              )
            else
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: _buildPlaceholderImage(),
              ),
            // Info section
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Club info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name + type badge
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                club.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.text,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: typeColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(typeIcon, size: 10, color: typeColor),
                                  const SizedBox(width: 3),
                                  Text(
                                    club.type.toUpperCase(),
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w700,
                                      color: typeColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Distance + Rating
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 12, color: AppColors.textMuted),
                            const SizedBox(width: 3),
                            Text(
                              '${club.distanceKm.toStringAsFixed(1)} km',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(Icons.star, size: 12, color: const Color(0xFFFFD60A)),
                            const SizedBox(width: 3),
                            Text(
                              club.rating.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                            if (club.music != null) ...[
                              const SizedBox(width: 10),
                              Icon(Icons.music_note, size: 12, color: AppColors.textDim),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  club.music!,
                                  style: const TextStyle(fontSize: 10, color: AppColors.textDim),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        // AI Insight
                        if (club.aiInsight != null)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.accentDim,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Text('🤖', style: TextStyle(fontSize: 12)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    club.aiInsight!,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.accent,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 8),
                        // Crowd bar
                        CrowdBar(crowdPercent: club.currentCrowd),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Crowd indicator
                  CrowdIndicator(crowdPercent: club.currentCrowd),
                ],
              ),
            ),
            // Bottom row: cover + open status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (club.cover != null)
                    Row(
                      children: [
                        Icon(Icons.confirmation_number_outlined, size: 12, color: AppColors.textDim),
                        const SizedBox(width: 4),
                        Text(
                          club.cover!,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  else
                    const SizedBox(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: club.isOpen
                          ? const Color(0xFF30D158).withValues(alpha: 0.15)
                          : const Color(0xFFFF2D55).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      club.isOpen ? 'OPEN NOW' : 'CLOSED',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: club.isOpen
                            ? const Color(0xFF30D158)
                            : const Color(0xFFFF2D55),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            typeColor.withValues(alpha: 0.3),
            AppColors.card,
          ],
        ),
      ),
      child: Center(
        child: Icon(typeIcon, size: 40, color: typeColor.withValues(alpha: 0.5)),
      ),
    );
  }
}

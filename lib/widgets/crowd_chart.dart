import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';
import '../models/club.dart';

class CrowdChart extends StatelessWidget {
  final List<CrowdSnapshot> history;
  final int currentHour;

  const CrowdChart({
    super.key,
    required this.history,
    required this.currentHour,
  });

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: Text('No crowd data available', style: TextStyle(color: AppColors.textDim)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CROWD TIMELINE',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: history.asMap().entries.map((entry) {
              final i = entry.key;
              final snap = entry.value;
              final isCurrentHour = snap.hour.hour == currentHour;
              final barHeight = (snap.crowd / 100) * 100;
              final color = _barColor(snap.crowd);

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (isCurrentHour)
                        Text(
                          '${snap.crowd}%',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 7,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      const SizedBox(height: 2),
                      Container(
                        height: barHeight.clamp(2.0, 100.0),
                        decoration: BoxDecoration(
                          color: isCurrentHour ? color : color.withValues(alpha: 0.4),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                          border: isCurrentHour ? Border.all(color: color, width: 1) : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (i % 3 == 0)
                        Text(
                          '${snap.hour.hour.toString().padLeft(2, '0')}',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 7,
                            color: isCurrentHour ? AppColors.accent : AppColors.textDim,
                          ),
                        )
                      else
                        const SizedBox(height: 10),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Color _barColor(int crowd) {
    if (crowd < 15) return const Color(0xFF30D158);
    if (crowd < 35) return AppColors.accent;
    if (crowd < 55) return const Color(0xFFFFD60A);
    if (crowd < 75) return AppColors.warning;
    return const Color(0xFFFF2D55);
  }
}

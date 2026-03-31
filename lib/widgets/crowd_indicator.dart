import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';

class CrowdIndicator extends StatelessWidget {
  final int crowdPercent;
  final double size;
  final bool showLabel;

  const CrowdIndicator({
    super.key,
    required this.crowdPercent,
    this.size = 52,
    this.showLabel = true,
  });

  Color get crowdColor {
    if (crowdPercent < 15) return const Color(0xFF30D158);
    if (crowdPercent < 35) return AppColors.accent;
    if (crowdPercent < 55) return const Color(0xFFFFD60A);
    if (crowdPercent < 75) return AppColors.warning;
    return const Color(0xFFFF2D55);
  }

  String get crowdLabel {
    if (crowdPercent < 15) return 'Dead';
    if (crowdPercent < 35) return 'Chill';
    if (crowdPercent < 55) return 'Moderate';
    if (crowdPercent < 75) return 'Busy';
    return 'Packed';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: crowdPercent / 100,
                  strokeWidth: 3.5,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation(crowdColor),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Text(
                '$crowdPercent%',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: size * 0.26,
                  fontWeight: FontWeight.w800,
                  color: crowdColor,
                ),
              ),
            ],
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: crowdColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              crowdLabel,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: crowdColor,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class CrowdBar extends StatelessWidget {
  final int crowdPercent;

  const CrowdBar({super.key, required this.crowdPercent});

  Color get crowdColor {
    if (crowdPercent < 15) return const Color(0xFF30D158);
    if (crowdPercent < 35) return AppColors.accent;
    if (crowdPercent < 55) return const Color(0xFFFFD60A);
    if (crowdPercent < 75) return AppColors.warning;
    return const Color(0xFFFF2D55);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: crowdPercent / 100,
        child: Container(
          decoration: BoxDecoration(
            color: crowdColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class SurveyProgressBar extends StatelessWidget {
  final double progress;

  final Animation<double> opacity;

  const SurveyProgressBar({
    super.key,
    required this.progress,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
return Positioned(
  left: 0,
  right: 0,
  bottom: 24,          // lifts it above the screen edge so it's visible
  child: FadeTransition(
    opacity: opacity,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: progress,
          minHeight: 6,          // slightly thicker than 4
          backgroundColor: AppColors.surface,
          valueColor: const AlwaysStoppedAnimation<Color>(
            AppColors.progressStart,
          ),
        ),
      ),
    ),
  ),
);
  }
}
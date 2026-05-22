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
      bottom: 0,
      child: FadeTransition(
        opacity: opacity,
        child: LinearProgressIndicator(
          value: progress,
          minHeight: 4,
          backgroundColor: AppColors.surface,
          valueColor: const AlwaysStoppedAnimation<Color>(
            AppColors.progressStart,
          ),
        ),
      ),
    );
  }
}
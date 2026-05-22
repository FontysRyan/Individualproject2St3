import 'package:flutter/material.dart';

import '../../core/theme/text_styles.dart';

class SurveySectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const SurveySectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.displayMedium,
        ),

        const SizedBox(height: 8),

        Text(
          subtitle,
          style: AppTextStyles.subtitle,
        ),
      ],
    );
  }
}
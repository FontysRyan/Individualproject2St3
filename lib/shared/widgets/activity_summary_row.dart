import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';

class ActivitySummaryRow extends StatelessWidget {
  final String name;

  final String durationLabel;

  final VoidCallback onDelete;

  const ActivitySummaryRow({
    super.key,
    required this.name,
    required this.durationLabel,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? 'Unnamed' : name,
                  style:
                      AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),

                const SizedBox(height: 2),

                Text(
                  durationLabel,
                  style:
                      AppTextStyles.labelSmall.copyWith(
                        color:
                            AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),

          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(
              10,
            ),
            child: InkWell(
              onTap: onDelete,
              borderRadius:
                  BorderRadius.circular(10),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color:
                      AppColors.statusOverloaded
                          .withValues(alpha: 0.12),
                  borderRadius:
                      BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  size: 16,
                  color:
                      AppColors.statusOverloaded,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
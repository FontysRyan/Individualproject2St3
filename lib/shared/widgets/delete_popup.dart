import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';

/// Generic confirmation bottom sheet for destructive actions.
/// This is a reusable widget that can be used anywhere in the app where you need to confirm a destructive action (like deleting an activity).
///
/// Usage:
/// ```dart
/// final confirmed = await showConfirmDialog(
///   context,
///   title: 'Remove activity?',
///   description: 'Remove "Kanban board". This can\'t be undone.',
///   icon: Icons.delete_outline_rounded,
///   confirmLabel: 'Remove',
/// );
/// ```
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String description,
  required IconData icon,
  required String confirmLabel,

  String cancelLabel = 'Cancel',

  // Confirm/destructive styling
  Color? confirmColor,

  // Icon styling
  Color? iconColor,
  Color? iconBackground,

  // Cancel/safe styling
  Color? cancelColor,
  Color? cancelTextColor,
  BorderSide? cancelBorder,
}) async {
  final destructiveColor = confirmColor ?? Colors.redAccent;

  final result = await showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ConfirmSheet(
      title: title,
      description: description,
      icon: icon,

      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,

      confirmColor: destructiveColor,

      iconColor: iconColor ?? destructiveColor,

      iconBackground: iconBackground ??
          destructiveColor.withValues(alpha: 0.12),

      cancelColor:
          cancelColor ?? AppColors.surfaceElevated,

      cancelTextColor:
          cancelTextColor ?? AppColors.textPrimary,

      cancelBorder:
          cancelBorder ??
          const BorderSide(color: AppColors.border),
    ),
  );

  return result ?? false;
}

class _ConfirmSheet extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  final String confirmLabel;
  final String cancelLabel;

  final Color confirmColor;

  final Color iconColor;
  final Color iconBackground;

  final Color cancelColor;
  final Color cancelTextColor;
  final BorderSide cancelBorder;

  const _ConfirmSheet({
    required this.title,
    required this.description,
    required this.icon,

    required this.confirmLabel,
    required this.cancelLabel,

    required this.confirmColor,

    required this.iconColor,
    required this.iconBackground,

    required this.cancelColor,
    required this.cancelTextColor,
    required this.cancelBorder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.surveyBackground_3,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tinted icon badge — color matches the action so the user. Eg red for delete, blue for archive, etc.
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  title,
                  style: AppTextStyles.displayMedium,
                ),

                const SizedBox(height: 8),

                Text(
                  description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 28),

                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () =>
                            Navigator.of(context).pop(true),
                        style: FilledButton.styleFrom(
                          backgroundColor: confirmColor,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          confirmLabel,
                          style:
                              AppTextStyles.labelLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: FilledButton(
                        onPressed: () =>
                            Navigator.of(context).pop(false),
                        style: FilledButton.styleFrom(
                          backgroundColor: cancelColor,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(14),
                            side: cancelBorder,
                          ),
                        ),
                        child: Text(
                          cancelLabel,
                          style:
                              AppTextStyles.labelLarge.copyWith(
                            color: cancelTextColor,
                          ),
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
    );
  }
}
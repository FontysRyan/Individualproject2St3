import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../shared/models/survey_data.dart';

import 'pill_button.dart';
import 'survey_section_header.dart';

// ─────────────────────────────────────────────────────────────
// SurveyStepReady
// read-only overview before the swipe game starts.
//
// This screen shows the planned activities but does not allow editing
// or deleting. The user goes back to the activity screen for that.
//
// Why no remove icon here? (Ryan)
// The ready screen's job is to give the user a confident final look at
// their plan before committing. Offering delete here creates two places
// to manage the same list, and the user can already go back with one tap.
// ─────────────────────────────────────────────────────────────
class SurveyStepReady extends StatelessWidget {
  final List<ActivityEntry> activities;

  /// Sends the user back to the activity planning screen to make changes.
  final VoidCallback onGoBack;

  final VoidCallback onConfirm;

  const SurveyStepReady({
    super.key,
    required this.activities,
    required this.onGoBack,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SurveySectionHeader(
          title: 'Ready?',
          subtitle: 'Here\'s your plan. Go back to make changes.',
        ),

        const SizedBox(height: 20),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              children: [
                for (final activity in activities)
                  _ActivityReadOnlyRow(activity: activity),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: PillButton(
                label: 'Edit',
                icon: Icons.arrow_back_rounded,
                alignment: MainAxisAlignment.center,
                // Surface color so this reads as secondary — the user's
                // attention should go to the green "Let's go" button.
                backgroundColor: AppColors.warning.withValues(alpha: 0.9),
                onTap: onGoBack,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: PillButton(
                label: 'Let\'s go',
                icon: Icons.play_arrow_rounded,
                alignment: MainAxisAlignment.center,
                onTap: onConfirm,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// _ActivityReadOnlyRow
//
// A single activity displayed as a clean label + duration pair.
// No actions, this is intentionally display-only. The user can go back to the previous screen to edit.
// Why? we wanna do the managing on previous screen and this is just a overview screen to make sure ur fine with it. (Extra validation)
class _ActivityReadOnlyRow extends StatelessWidget {
  final ActivityEntry activity;

  const _ActivityReadOnlyRow({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [


          const SizedBox(width: 12),

          Expanded(
            child: Text(
              activity.name.isNotEmpty ? activity.name : 'Unnamed activity',
              style: AppTextStyles.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(width: 8),

          Text(
            activity.durationLabel,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

import '../../core/constants/survey_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../shared/models/survey_data.dart';

import 'activity_input_card.dart';
import 'pill_button.dart';
import 'survey_section_header.dart';

// ─────────────────────────────────────────────────────────────
// SurveyStepActivities
//
// Responsibilities:
//   - Render the list of ActivityEntry inputs.
//   - Show "Add activity" button.
//   - Show delete confirmation (via onActivityDeleteRequested).
//   - Show overflow warning when planned time exceeds available time.
//   - Block "Continue" when canContinue is false.
//
// This widget never modifies the list directly. We rely on the parent to manage the list and pass in updated versions via props.
// Why? It keeps all the state management in one place (the parent) instead of spreading it across multiple widgets. 
// The input cards are also simpler this way since they don't have to know about the overall list, just their own fields and index.
// ─────────────────────────────────────────────────────────────
class SurveyStepActivities extends StatelessWidget {
  final List<ActivityEntry> activities;
  final List<int> activityKeys;

  final int totalAvailableMinutes;
  final int totalPlannedMinutes;

  final bool canContinue;

  /// Called when the user taps the "Add activity" button.
  final VoidCallback onActivityAdded;

  /// Called when an input card's field changes.
  /// Parent replaces activities[index] with [updated].
  final void Function(int index, ActivityEntry updated) onActivityUpdated;

  /// Called when the user taps delete on an activity card.
  /// Parent shows the confirmation popup, then removes on confirm.
  final Future<void> Function(int index) onActivityDeleteRequested;

  final VoidCallback onContinue;

  const SurveyStepActivities({
    super.key,
    required this.activities,
    required this.activityKeys,
    required this.totalAvailableMinutes,
    required this.totalPlannedMinutes,
    required this.canContinue,
    required this.onActivityAdded,
    required this.onActivityUpdated,
    required this.onActivityDeleteRequested,
    required this.onContinue,
  });

  bool get _isOverflowing => totalPlannedMinutes > totalAvailableMinutes;

  String _overflowLabel() {
    final over = totalPlannedMinutes - totalAvailableMinutes;
    final h = over ~/ 60;
    final m = over % 60;
    if (h == 0) return '${m}m over your available time';
    if (m == 0) return '${h}h over your available time';
    return '${h}h ${m}m over your available time';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SurveySectionHeader(
          title: 'Activities',
          subtitle: 'What are your responsibilities for today?',
        ),

        const SizedBox(height: 20),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              children: [
                // Identity-based keys so deleting an item in the middle
                // doesn't cause adjacent cards to adopt the wrong state.
                // eg: if you have [A, B, C] and delete B, C doesn't become the new B.
                for (int i = 0; i < activities.length; i++)
                  ActivityInputCard(
                    key: ValueKey(activityKeys[i]),
                    index: i,
                    initialName: activities[i].name,
                    initialHours: activities[i].hours,
                    initialMinutes: activities[i].minutes,
                    onChanged: (updated) => onActivityUpdated(i, updated),
                    onDeleteRequested: () => onActivityDeleteRequested(i),
                  ),

                _AddActivityButton(onTap: onActivityAdded),
              ],
            ),
          ),
        ),

        // Overflow warning, shown instead of the generic "can't continue"
        // so the user knows exactly why the button is disabled.
        if (_isOverflowing) ...[
          const SizedBox(height: 8),
          _OverflowWarning(label: _overflowLabel()),
        ],

        const SizedBox(height: 12),

        PillButton(
          label: 'Continue',
          icon: Icons.arrow_forward_rounded,
          alignment: MainAxisAlignment.start,
          onTap: canContinue ? onContinue : null,
        ),
      ],
    );
  }
}

// Private sub-widgets
// These are only used inside SurveyStepActivities, so we keep them in the same file.
class _AddActivityButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddActivityButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.35),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline_rounded,
              size: 18,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Add activity',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverflowWarning extends StatelessWidget {
  final String label;

  const _OverflowWarning({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.warning_amber_rounded,
          size: 14,
          color: AppColors.statusBusy,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.statusBusy,
          ),
        ),
      ],
    );
  }
}
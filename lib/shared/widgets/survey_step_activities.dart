import 'package:flutter/material.dart';

import '../../core/constants/survey_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';

import 'activity_input_card.dart';
import 'pill_button.dart';
import 'survey_section_header.dart';

class SurveyStepActivities extends StatelessWidget {
  final List<({String name, int hours, int minutes})> activities;

  final ValueChanged<
    List<({String name, int hours, int minutes})>
  >
  onActivitiesChanged;

  final bool canContinue;

  final VoidCallback onContinue;

  const SurveyStepActivities({
    super.key,
    required this.activities,
    required this.onActivitiesChanged,
    required this.canContinue,
    required this.onContinue,
  });

  void _addActivity() {
    onActivitiesChanged([
      ...activities,
      (
        name: '',
        hours: SurveyConstants.defaultActivityHours,
        minutes: SurveyConstants.defaultActivityMinutes,
      ),
    ]);
  }

  void _updateActivity(
    int index,
    ({String name, int hours, int minutes}) updated,
  ) {
    final list = [...activities];

    list[index] = updated;

    onActivitiesChanged(list);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SurveySectionHeader(
          title: 'Activities',
          subtitle:
              'What are your responsibilities for today?',
        ),

        const SizedBox(height: 20),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              children: [
                for (int i = 0; i < activities.length; i++)
                  ActivityInputCard(
                    key: ValueKey(i),
                    index: i,
                    initialName: activities[i].name,
                    initialHours: activities[i].hours,
                    initialMinutes: activities[i].minutes,
                    onChanged: (updated) {
                      _updateActivity(i, updated);
                    },
                  ),

                GestureDetector(
                  onTap: _addActivity,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.primary.withValues(
                          alpha: 0.35,
                        ),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(
                        16,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_circle_outline_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),

                        const SizedBox(width: 8),

                        Text(
                          'Add activity',
                          style:
                              AppTextStyles.labelMedium
                                  .copyWith(
                                    color:
                                        AppColors.primary,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        PillButton(
          label: 'Continue',
          icon: Icons.arrow_forward_rounded,
          alignment: MainAxisAlignment.start,
          disabled: !canContinue,
          onTap: canContinue ? onContinue : null,
        ),
      ],
    );
  }
}
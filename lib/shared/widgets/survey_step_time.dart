import 'package:flutter/material.dart';

import '../../core/constants/survey_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';

import '../../shared/widgets/number_stepper_field.dart';
import '../../shared/widgets/pill_button.dart';
import '../../shared/widgets/survey_section_header.dart';
import '../../shared/widgets/time_picker_field.dart';

class SurveyStepTime extends StatelessWidget {
  final String userName;

  final int availableHours;
  final int availableMinutes;

  final TimeOfDay? startTime;

  final ValueChanged<int> onHoursChanged;
  final ValueChanged<int> onMinutesChanged;
  final ValueChanged<TimeOfDay?> onStartTimeChanged;

  /// PillButton disables itself when onTap is null, so callers never need to check the conditions themselves. They can just pass null for now on.
  /// also pass disabled: true. This also allows us to show the inline validation message in the same condition without having to pass another flag.
  final VoidCallback? onContinue;

  const SurveyStepTime({
    super.key,
    required this.userName,
    required this.availableHours,
    required this.availableMinutes,
    required this.startTime,
    required this.onHoursChanged,
    required this.onMinutesChanged,
    required this.onStartTimeChanged,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final bool startTimeIsMissing = startTime == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SurveySectionHeader(
          title: 'Time',
          subtitle: userName.isNotEmpty
              ? 'Let\'s see how much time you have today, $userName.'
              : 'Let\'s see how much time you have today.',
        ),

        const SizedBox(height: 28),

        NumberStepperField(
          label: 'Available hours',
          icon: Icons.schedule_outlined,
          value: availableHours,
          min: SurveyConstants.minAvailableHours,
          max: SurveyConstants.maxAvailableHours,
          unit: 'hr',
          onChanged: onHoursChanged,
        ),

        const SizedBox(height: 14),

        NumberStepperField(
          label: 'Extra minutes',
          icon: Icons.timelapse_outlined,
          value: availableMinutes,
          min: 0,
          max: SurveyConstants.maxAvailableMinutes,
          step: SurveyConstants.minuteStep,
          unit: 'min',
          onChanged: onMinutesChanged,
        ),

        const SizedBox(height: 14),

        TimePickerField(
          label: 'Start time',
          icon: Icons.timer_outlined,
          value: startTime,
          onChanged: (t) => onStartTimeChanged(t),
        ),

        // Just to make sure you have starttime else it give a warning and you know why you cant continue. (Validation)
        if (startTimeIsMissing) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: AppColors.statusBusy,
              ),
              const SizedBox(width: 6),
              Text(
                'Set a start time to continue.',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.statusBusy,
                ),
              ),
            ],
          ),
        ],

        const Spacer(),

        PillButton(
          label: 'Continue',
          icon: Icons.arrow_forward_rounded,
          alignment: MainAxisAlignment.start,
          onTap: onContinue,
        ),
      ],
    );
  }
}
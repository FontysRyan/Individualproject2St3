import 'package:flutter/material.dart';

import '../../core/constants/survey_constants.dart';

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

  final VoidCallback onContinue;

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SurveySectionHeader(
          title: 'Time',
          subtitle:
              userName.isNotEmpty
                  ? 'Lets see how much time you have today, $userName.'
                  : 'Lets see how much time you have today.',
        ),

        const SizedBox(height: 28),

        NumberStepperField(
          label: 'Available hours',
          icon: Icons.schedule_outlined,
          value: availableHours,
          min: 0,
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
          onChanged: onStartTimeChanged,
        ),

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
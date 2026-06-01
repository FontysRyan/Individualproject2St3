import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/constants/survey_constants.dart';

/// A single activity row with name input, hour stepper, and minute stepper.
/// Used in the Activities step of the survey.
/// TODO: hourstepper and minutestepper way to genericname. change to something better?
class ActivityInputCard extends StatefulWidget {
  final int index;
  final String initialName;
  final int initialHours;
  final int initialMinutes;
  final ValueChanged<({String name, int hours, int minutes})> onChanged;

  const ActivityInputCard({
    super.key,
    required this.index,
    this.initialName = '',
    this.initialHours = SurveyConstants.defaultActivityHours,
    this.initialMinutes = SurveyConstants.defaultActivityMinutes,
    required this.onChanged,
  });

  @override
  State<ActivityInputCard> createState() => _ActivityInputCardState();
}

class _ActivityInputCardState extends State<ActivityInputCard> {
  late final TextEditingController _nameCtrl;
  late int _hours;
  late int _minutes;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
    _hours = widget.initialHours;
    _minutes = widget.initialMinutes;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _notify() {
    widget.onChanged((
      name: _nameCtrl.text,
      hours: _hours,
      minutes: _minutes,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Activity name field
          TextField(
            controller: _nameCtrl,
            onChanged: (_) => _notify(),
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Activity name',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              filled: false,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.6),
                  width: 1,
                ),
              ),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),

          const SizedBox(height: 12),

          // Duration row
          Row(
            children: [
              Icon(
                Icons.schedule_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Duration:',
                style: AppTextStyles.labelSmall,
              ),
              const SizedBox(width: 12),

              // Hours stepper
              _DurationStepper(
                value: _hours,
                unit: 'h',
                min: SurveyConstants.activityMinHours,
                max: SurveyConstants.activityMaxHours,
                onChanged: (v) {
                  // Enforce minimum total duration
                  if (v == 0 && _minutes < SurveyConstants.activityMinDurationMinutes) return;
                  setState(() => _hours = v);
                  _notify();
                },
              ),

              const SizedBox(width: 8),

              // Minutes stepper (steps of 15)
              _DurationStepper(
                value: _minutes,
                unit: 'm',
                min: SurveyConstants.activityMinMinutes,
                max: SurveyConstants.activityMaxMinutes,
                step: SurveyConstants.minuteStep,
                onChanged: (v) {
                  if (_hours == 0 && v < SurveyConstants.activityMinDurationMinutes) return;
                  setState(() => _minutes = v);
                  _notify();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DurationStepper extends StatelessWidget {
  final int value;
  final String unit;
  final int min;
  final int max;
  final int step;
  final ValueChanged<int> onChanged;

  const _DurationStepper({
    required this.value,
    required this.unit,
    required this.min,
    required this.max,
    this.step = 1,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepButton(
          icon: Icons.remove,
          onTap: value > min ? () => onChanged(value - step) : null,
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 36,
          child: Text(
            '$value$unit',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 6),
        _StepButton(
          icon: Icons.add,
          onTap: value < max ? () => onChanged(value + step) : null,
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled
              ? AppColors.primary
              : AppColors.textSecondary.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
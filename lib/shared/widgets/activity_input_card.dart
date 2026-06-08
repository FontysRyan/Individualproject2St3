import 'package:flutter/material.dart';

import '../../core/constants/survey_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../shared/models/survey_data.dart';
import 'package:flutter/services.dart';


class ActivityInputCard extends StatefulWidget {
  final int index;
  final String initialName;
  final int initialHours;
  final int initialMinutes;

  final ValueChanged<ActivityEntry> onChanged;
  final VoidCallback onDeleteRequested;

  const ActivityInputCard({
    super.key,
    required this.index,
    this.initialName = '',
    this.initialHours = SurveyConstants.defaultActivityHours,
    this.initialMinutes = SurveyConstants.defaultActivityMinutes,
    required this.onChanged,
    required this.onDeleteRequested,
  });

  @override
  State<ActivityInputCard> createState() => _ActivityInputCardState();
}

class _ActivityInputCardState extends State<ActivityInputCard> {
  late final TextEditingController _activityNameController;

  late int _selectedHours;
  late int _selectedMinutes;

  @override
  void initState() {
    super.initState();

    _activityNameController = TextEditingController(text: widget.initialName);

    _selectedHours = widget.initialHours;
    _selectedMinutes = widget.initialMinutes;
  }

  @override
  void dispose() {
    _activityNameController.dispose();
    super.dispose();
  }

  /// duration is valid when it meets the rule: at least 15 minutes OR at least 1 full hour.
  bool get _isDurationValid {
    return _selectedHours > 0 ||
        _selectedMinutes >= SurveyConstants.activityMinDurationMinutes;
  }

  void _notifyActivityChanged() {
    widget.onChanged(
      ActivityEntry(
        name: _activityNameController.text,
        hours: _selectedHours,
        minutes: _selectedMinutes,
      ),
    );
  }

  void _updateHours(int newHours) {
    setState(() {
      _selectedHours = newHours;
    });

    _notifyActivityChanged();
  }

  void _updateMinutes(int newMinutes) {
    setState(() {
      _selectedMinutes = newMinutes;
    });

    _notifyActivityChanged();
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
          color: _isDurationValid
              ? AppColors.border
              : AppColors.error.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          _buildDurationSection(),

          if (!_isDurationValid) ...[
            const SizedBox(height: 8),
            Text(
              'Select at least 1 hour or ${SurveyConstants.activityMinDurationMinutes} minutes',
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.error),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: _activityNameController,
            onChanged: (_) {
              _notifyActivityChanged();
            },
            maxLength: SurveyConstants.activityNameMaxLength,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            style: AppTextStyles.bodyMedium,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Activity name',
              counterText:
                  '', // hides the "0/50" counter Flutter adds by default
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
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: widget.onDeleteRequested,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.delete_outline,
              size: 18,
              color: AppColors.error,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationSection() {
    return Row(
      children: [
        Icon(Icons.schedule_outlined, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text('Duration:', style: AppTextStyles.labelSmall),
        const SizedBox(width: 12),

        _ActivityDurationSelector(
          value: _selectedHours,
          unitLabel: 'h',
          minValue: SurveyConstants.activityMinHours,
          maxValue: SurveyConstants.activityMaxHours,
          onChanged: _updateHours,
        ),

        const SizedBox(width: 8),

        _ActivityDurationSelector(
          value: _selectedMinutes,
          unitLabel: 'm',
          minValue: SurveyConstants.activityMinMinutes,
          maxValue: SurveyConstants.activityMaxMinutes,
          stepAmount: SurveyConstants.minuteStep,
          onChanged: _updateMinutes,
        ),
      ],
    );
  }
}

class _ActivityDurationSelector extends StatelessWidget {
  final int value;
  final String unitLabel;

  final int minValue;
  final int maxValue;

  final int stepAmount;

  final ValueChanged<int> onChanged;

  const _ActivityDurationSelector({
    required this.value,
    required this.unitLabel,
    required this.minValue,
    required this.maxValue,
    this.stepAmount = 1,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _DurationAdjustButton(
          icon: Icons.remove,
          onTap: value > minValue ? () => onChanged(value - stepAmount) : null,
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 40,
          child: Text(
            '$value$unitLabel',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 6),
        _DurationAdjustButton(
          icon: Icons.add,
          onTap: value < maxValue ? () => onChanged(value + stepAmount) : null,
        ),
      ],
    );
  }
}

class _DurationAdjustButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _DurationAdjustButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isEnabled
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isEnabled
              ? AppColors.primary
              : AppColors.textSecondary.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

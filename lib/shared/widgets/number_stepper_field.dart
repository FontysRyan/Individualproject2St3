import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';


class NumberStepperField extends StatelessWidget {
  final String label;
  final IconData icon;

  final int value;
  final int min;
  final int max;

  final String? unit;

  final int step;


  final ValueChanged<int> onChanged;

  const NumberStepperField({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 99,
    this.unit,
    this.step = 1,
  });

void _decrement() {
  if (value <= min) return;
  HapticFeedback.lightImpact();
  onChanged((value - step).clamp(min, max));
}

void _increment() {
  if (value >= max) return;
  HapticFeedback.lightImpact();
  onChanged((value + step).clamp(min, max));
}


  @override
  Widget build(BuildContext context) {
    final atMin = value <= min;
    final atMax = value >= max;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Leading icon
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),

          // Label
          Expanded(
            child: Text(label, style: AppTextStyles.titleSmall),
          ),

          // − button
          _StepButton(
            icon: Icons.remove_rounded,
            onTap: atMin ? null : _decrement,
          ),

          const SizedBox(width: 12),

          // Current value
          SizedBox(
            width: 40,
            child: Text(
              unit != null ? '$value $unit' : '$value',
              textAlign: TextAlign.center,
              style: AppTextStyles.titleSmall,
            ),
          ),

          const SizedBox(width: 12),

          // + button
          _StepButton(
            icon: Icons.add_rounded,
            onTap: atMax ? null : _increment,
          ),
        ],
      ),
    );
  }
}

/// The small circular −/+ button used inside [NumberStepperField].
/// Disabled appearance when [onTap] is null (at min/max boundary). Allow user to know they can't go further in that direction.
/// Like we don't want activity to last over 24hr or abover 45 min, cause 60 min = 1 hour and can easy to just better tap 1 hour.
class _StepButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepButton({required this.icon, required this.onTap});

  @override
  State<_StepButton> createState() => _StepButtonState();
}

class _StepButtonState extends State<_StepButton> {
  bool _pressed = false;

  bool get _isDisabled => widget.onTap == null;

  void _onTapDown(TapDownDetails _) {
    if (_isDisabled) return;
    setState(() => _pressed = true);
  }

  void _onTapUp(TapUpDetails _) {
    if (_isDisabled) return;
    setState(() => _pressed = false);
    widget.onTap?.call();
  }

  void _onTapCancel() => setState(() => _pressed = false);

  @override
  Widget build(BuildContext context) {
    final color = _isDisabled ? AppColors.textMuted : AppColors.primary;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _pressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _isDisabled
                ? AppColors.surface
                : AppColors.primary.withAlpha(26), // ~10% tint
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isDisabled ? AppColors.border : AppColors.primary,
              width: 1,
            ),
          ),
          child: Icon(widget.icon, size: 16, color: color),
        ),
      ),
    );
  }
}
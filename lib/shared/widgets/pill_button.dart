import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';

/// A full-width pill-shaped button used throughout Cards On Time.
///
/// Color system:
/// [backgroundColor] overrides the fill. Defaults to [AppColors.primary].
/// [textColor] overrides the label/icon color. Defaults to white.
/// When [onTap] is null, the button automatically renders in its disabled
/// state using [AppColors.primaryDisabled] regardless of [backgroundColor].
/// The [disabled] flag is kept for cases where the tap handler exists but the
/// button should visually block interaction (e.g. async submission in progress like a input field that is required).
class PillButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool disabled;
  final Color? backgroundColor;
  final Color? textColor;
  final MainAxisAlignment alignment;

  const PillButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.disabled = false,
    this.backgroundColor,
    this.textColor,
    this.alignment = MainAxisAlignment.center,
  });

  @override
  State<PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<PillButton> {
  bool _pressed = false;

  bool get _isDisabled => widget.disabled || widget.onTap == null;

  void _onTapDown(TapDownDetails _) {
    if (_isDisabled) return;
    setState(() => _pressed = true);
  }

  void _onTapUp(TapUpDetails _) {
    if (_isDisabled) return;
    setState(() => _pressed = false);
    HapticFeedback.lightImpact();
    widget.onTap?.call();
  }

  void _onTapCancel() => setState(() => _pressed = false);

  @override
  Widget build(BuildContext context) {
    final resolvedBackground = _isDisabled
        ? AppColors.primaryDisabled
        : (widget.backgroundColor ?? AppColors.primary);


    final resolvedTextColor =
        _isDisabled ? AppColors.textMuted : (widget.textColor ?? Colors.white);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          decoration: BoxDecoration(
            color: resolvedBackground,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            mainAxisAlignment: widget.alignment,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: resolvedTextColor, size: 20),
                const SizedBox(width: 10),
              ],
              Text(
                widget.label,
                style: AppTextStyles.buttonLabel.copyWith(
                  color: resolvedTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
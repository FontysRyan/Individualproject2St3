import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';

/// A reusable full-width pill-shaped button used throughout Cards On Time.
class PillButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool disabled;
  final Color? color;

  const PillButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.disabled = false,
    this.color,
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
    final bgColor = _isDisabled
        ? AppColors.primaryDisabled
        : (widget.color ?? AppColors.primary);

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
            color: bgColor,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: Colors.white, size: 20),
                const SizedBox(width: 10),
              ],
              Text(widget.label, style: AppTextStyles.buttonLabel),
            ],
          ),
        ),
      ),
    );
  }
}
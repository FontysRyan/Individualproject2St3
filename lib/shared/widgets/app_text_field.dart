import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';

/// Reusable styled text field matching the Cards On Time dark theme.
///
/// Usage:
/// ```dart
/// AppTextField(
///   controller: _nameController,
///   label: 'Name',
///   hint: 'Please fill in your name',
/// )
///
/// // Number input:
/// AppTextField(
///   controller: _hoursController,
///   label: 'Hours',
///   hint: 'e.g. 4',
///   keyboardType: TextInputType.number,
///   suffix: 'hrs',
/// )
/// ```
class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onSubmitted;
  final bool showClearButton;

  /// Optional trailing text label (e.g. "hrs", "min")
  final String? suffix;

  /// Optional list of input formatters (e.g. digits only)
  final List<TextInputFormatter>? inputFormatters;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.textCapitalization = TextCapitalization.none,
    this.onSubmitted,
    this.showClearButton = true,
    this.suffix,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onSubmitted: onSubmitted,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      style: AppTextStyles.inputText,
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.inputLabel,
        hintText: hint,
        hintStyle: AppTextStyles.inputHint,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        // Clear button
        suffixIcon: showClearButton && controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.cancel, color: AppColors.textMuted, size: 20),
                onPressed: () => controller.clear(),
              )
            : suffix != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Text(suffix!, style: AppTextStyles.inputLabel),
                  )
                : null,
        suffixIconConstraints: suffix != null
            ? const BoxConstraints(minWidth: 0, minHeight: 0)
            : null,
      ),
    );
  }
}
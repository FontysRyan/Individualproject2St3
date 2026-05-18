import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController controller;

  final String label;
  final String? hint;

  final FocusNode? focusNode;

  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;

  final ValueChanged<String>? onSubmitted;

  final bool showClearButton;

  final TextAlign textAlign;


  final bool useFloatingLabel;

  final String? suffix;

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
    this.textAlign = TextAlign.left,
    this.useFloatingLabel = true,
    this.suffix,
    this.inputFormatters,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  /// Centred fields always use the external label to avoid the
  /// "rests-left / floats-centre" jump that Flutter's floating label produces.
  bool get _useFloatingLabel =>
      widget.useFloatingLabel && widget.textAlign != TextAlign.center;

  bool get _isCentered => widget.textAlign == TextAlign.center;

  bool get _showClear =>
      widget.showClearButton && widget.controller.text.isNotEmpty;

  /// A transparent icon used as a left-side counterweight so the typed text
  /// stays visually centred when the clear button is visible on the right.
  Widget get _balancingPrefix => const SizedBox(
        width: 40, // same effective width as the clear IconButton
      );

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!_useFloatingLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.label,
              textAlign: widget.textAlign,
              style: AppTextStyles.inputLabel,
            ),
          ),
        TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          onSubmitted: widget.onSubmitted,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          inputFormatters: widget.inputFormatters,
          textAlign: widget.textAlign,
          style: AppTextStyles.inputText,
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            // Floating label (left / right aligned fields only)
            labelText: _useFloatingLabel ? widget.label : null,
            labelStyle: AppTextStyles.inputLabel,

            hintText: widget.hint,
            hintStyle: AppTextStyles.inputHint,

            filled: true,
            fillColor: AppColors.surface,

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.border,
                width: 1,
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),

            prefixIcon: (_isCentered && _showClear) ? _balancingPrefix : null,
            prefixIconConstraints: (_isCentered && _showClear)
                ? const BoxConstraints(minWidth: 0, minHeight: 0)
                : null,

            suffixIcon: _showClear
                ? IconButton(
                    icon: const Icon(
                      Icons.cancel,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                    onPressed: () => widget.controller.clear(),
                  )
                : widget.suffix != null
                    ? Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Center(
                          widthFactor: 1,
                          child: Text(
                            widget.suffix!,
                            style: AppTextStyles.inputLabel,
                          ),
                        ),
                      )
                    : null,

            suffixIconConstraints: widget.suffix != null && !_showClear
                ? const BoxConstraints(minWidth: 0, minHeight: 0)
                : null,
          ),
        ),
      ],
    );
  }
}
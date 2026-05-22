import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';

class TimePickerField extends StatelessWidget {
  final String label;
  final IconData icon;

  /// Currently selected time. Pass null to show the placeholder.
  final TimeOfDay? value;

  final ValueChanged<TimeOfDay> onChanged;

  const TimePickerField({
    super.key,
    required this.label,
    required this.icon,
    required this.onChanged,
    this.value,
  });

  String get _displayValue {
    if (value == null) return 'Tap to set';
    final h = value!.hour.toString().padLeft(2, '0');
    final m = value!.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _openPicker(BuildContext context) async {
    HapticFeedback.lightImpact();

    final picked = await showModalBottomSheet<TimeOfDay>(
      context: context,
      // Clips the sheet to M3 rounded top corners
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: AppColors.surface,
      builder: (_) => _TimePickerSheet(initial: value),
    );

    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;

    return GestureDetector(
      onTap: () => _openPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    _displayValue,
                    style: hasValue
                        ? AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          )
                        : AppTextStyles.subtitleSmall,
                  ),
                ],
              ),
            ),

            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

// Bottom sheet
// A separate StatefulWidget to hold the scroll controllers and selected time

class _TimePickerSheet extends StatefulWidget {
  final TimeOfDay? initial;

  const _TimePickerSheet({this.initial});

  @override
  State<_TimePickerSheet> createState() => _TimePickerSheetState();
}

class _TimePickerSheetState extends State<_TimePickerSheet> {
  late int _hour;
  late int _minute;

  // Scroll controllers for the two wheels
  late final FixedExtentScrollController _hourCtrl;
  late final FixedExtentScrollController _minuteCtrl;

  // Minute wheel shows steps of 5: 0, 5, 10 … 55  (12 items)
  static const int _minuteStep = 5;
  static const int _minuteItems = 60 ~/ _minuteStep; // 12

  @override
  void initState() {
    super.initState();
    _hour = widget.initial?.hour ?? TimeOfDay.now().hour;
    _minute = widget.initial?.minute ?? 0;

    // Snap minute to nearest step
    _minute = (_minute / _minuteStep).round() * _minuteStep % 60;

    _hourCtrl = FixedExtentScrollController(initialItem: _hour);
    _minuteCtrl = FixedExtentScrollController(
      initialItem: _minute ~/ _minuteStep,
    );
  }

  @override
  void dispose() {
    _hourCtrl.dispose();
    _minuteCtrl.dispose();
    super.dispose();
  }

  void _confirm() {
    Navigator.of(context).pop(TimeOfDay(hour: _hour, minute: _minute));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Sheet title
          Text('Pick a start time', style: AppTextStyles.titleMedium),
          const SizedBox(height: 24),

          // Wheels row
          SizedBox(
            height: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hour wheel  (0–23)
                _WheelColumn(
                  controller: _hourCtrl,
                  itemCount: 24,
                  labelBuilder: (i) => i.toString().padLeft(2, '0'),
                  onChanged: (i) => setState(() => _hour = i),
                ),

                // Separator
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(':', style: AppTextStyles.displayMedium),
                ),

                // Minute wheel (0, 5, 10 … 55)
                _WheelColumn(
                  controller: _minuteCtrl,
                  itemCount: _minuteItems,
                  labelBuilder: (i) =>
                      (i * _minuteStep).toString().padLeft(2, '0'),
                  onChanged: (i) =>
                      setState(() => _minute = i * _minuteStep),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Confirm button
          // but built inline to avoid an import cycle with PillButton.
          GestureDetector(
            onTap: _confirm,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                'Confirm',
                textAlign: TextAlign.center,
                style: AppTextStyles.buttonLabel,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Scroll wheel column ───────────────────────────────────────────────────────

class _WheelColumn extends StatelessWidget {
  final FixedExtentScrollController controller;
  final int itemCount;
  final String Function(int index) labelBuilder;
  final ValueChanged<int> onChanged;

  const _WheelColumn({
    required this.controller,
    required this.itemCount,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Selection highlight band
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary.withAlpha(80)),
            ),
          ),

          // Scroll wheel
          ListWheelScrollView.useDelegate(
            controller: controller,
            itemExtent: 48,
            diameterRatio: 1.4,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (i) {
              HapticFeedback.selectionClick();
              onChanged(i);
            },
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: itemCount,
              builder: (context, index) {
                final isSelected = controller.hasClients &&
                    controller.selectedItem == index;
                return Center(
                  child: Text(
                    labelBuilder(index),
                    style: isSelected
                        ? AppTextStyles.titleMedium.copyWith(
                            color: AppColors.primary,
                          )
                        : AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textMuted,
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

/// Floating "+X" label that drifts upward and fades out after an activity
/// is added to the plan (swipe right → DO).
///
/// Usage: add to the widget tree unconditionally and set [visible] = true
/// to trigger. The widget self-manages the animation and calls [onComplete]
/// when done so the parent can reset [visible].
///
/// Example:
/// ```dart
/// TimeGainPopup(
///   label: '+30m',
///   visible: _showPopup,
///   onComplete: () => setState(() => _showPopup = false),
/// )
/// ```
class TimeGainPopup extends StatefulWidget {
  final String label;
  final bool visible;
  final VoidCallback onComplete;

  const TimeGainPopup({
    super.key,
    required this.label,
    required this.visible,
    required this.onComplete,
  });

  @override
  State<TimeGainPopup> createState() => _TimeGainPopupState();
}

class _TimeGainPopupState extends State<TimeGainPopup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Fade in fast, hold briefly, fade out.
    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 55),
    ]).animate(_ctrl);

    // Drifts upward the whole time.
    _slide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1.8),
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(TimeGainPopup old) {
    super.didUpdateWidget(old);

    if (widget.visible && !old.visible) {
      _ctrl.forward(from: 0.0).then((_) => widget.onComplete());
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible && !_ctrl.isAnimating) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => FractionalTranslation(
        translation: _slide.value,
        child: Opacity(
          opacity: _opacity.value,
          child: Text(
            widget.label,
            style: const TextStyle(
              color: Color(0xFF52C97A),
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
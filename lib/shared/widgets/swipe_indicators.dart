import 'package:flutter/material.dart';

/// The two pill/circle indicators shown left and right of the swipe card.
///
/// [dragProgress] runs from -1.0 (full left / DO) to +1.0 (full right / DONT).
/// At 0.0 both circles are at their resting size.
///
/// Left  (red)   = skip / DONT  — grows when dragProgress < 0
/// Right (green) = plan / DO    — grows when dragProgress > 0
///
/// Visual reference: Figma mockup — pixel-style circles, no label text.
/// TODO: clean this code up to make more understandable for myself and fix the comments.

class SwipeIndicators extends StatelessWidget {
  final double dragProgress; // -1.0 … +1.0

  const SwipeIndicators({super.key, required this.dragProgress});

  // Resting diameter of each circle.
  static const double _restSize = 64.0;
  // Maximum diameter at full drag.
  static const double _maxSize = 92.0;

  double get _leftScale {
    // Left (red/skip) grows when dragProgress is negative.
    final t = (-dragProgress).clamp(0.0, 1.0);
    return _lerp(_restSize, _maxSize, t);
  }

  double get _rightScale {
    // Right (green/plan) grows when dragProgress is positive.
    final t = dragProgress.clamp(0.0, 1.0);
    return _lerp(_restSize, _maxSize, t);
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left — red — skip
        _IndicatorCircle(
          size: _leftScale,
          color: const Color(0xFFE05252),
          icon: Icons.close_rounded,
        ),

        // Right — green — plan
        _IndicatorCircle(
          size: _rightScale,
          color: const Color(0xFF52C97A),
          icon: Icons.check_rounded,
        ),
      ],
    );
  }
}

class _IndicatorCircle extends StatelessWidget {
  final double size;
  final Color color;
  final IconData icon;

  const _IndicatorCircle({
    required this.size,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 60),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2.5),
      ),
      child: Icon(icon, color: color, size: size * 0.42),
    );
  }
}
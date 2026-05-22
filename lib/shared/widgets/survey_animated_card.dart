import 'package:flutter/material.dart';

class SurveyAnimatedCard extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  final BoxDecoration decoration;

  final Animation<double> opacity;

  final Widget child;

  const SurveyAnimatedCard({
    super.key,
    required this.width,
    required this.height,
    required this.radius,
    required this.decoration,
    required this.opacity,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, 0.18),
      child: SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: decoration,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: FadeTransition(
              opacity: opacity,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 28,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
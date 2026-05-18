import 'package:flutter/material.dart';

/// Reusable gradient background used on every screen.

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF26264B), // top
            Color(0xFF18182B), // bottom
          ],
        ),
      ),
      child: child,
    );
  }
}
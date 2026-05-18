import 'dart:math';
import 'package:flutter/material.dart';

// Floating Cards Background

class FloatingCardsBackground extends StatefulWidget {
  final int cardCount;
  final Duration driftDuration;

  const FloatingCardsBackground({
    super.key,
    this.cardCount = 10,
    this.driftDuration = const Duration(seconds: 18),
  });

  @override
  State<FloatingCardsBackground> createState() =>
      _FloatingCardsBackgroundState();
}

class _FloatingCardsBackgroundState extends State<FloatingCardsBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_CardData> _cards;

  static const _suits = ['Plan', 'Time', 'Task', 'Play'];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.driftDuration,
    )..repeat();

    final rng = Random(7);

    _cards = List.generate(widget.cardCount, (_) {
      return _CardData(
        startX: rng.nextDouble(),
        startY: rng.nextDouble(),
        width: 44 + rng.nextDouble() * 32,
        angle: (rng.nextDouble() - 0.5) * pi * 0.6,
        speed: 0.35 + rng.nextDouble() * 0.65,
        opacity: 0.06 + rng.nextDouble() * 0.10,
        suit: _suits[rng.nextInt(_suits.length)],
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.lastElapsedDuration?.inMilliseconds ?? 0;

        return Stack(
          clipBehavior: Clip.hardEdge,
          children: _cards.expand((card) {
            final baseProgress = (t / (8000 + card.speed * 4000)) + card.startY;

            List<Widget> widgets = [];

            for (int i = 0; i < 2; i++) {
              final progress = (baseProgress + i) % 1.0;

              // Vertical movement
              final dy = screenSize.height * (1 - progress);

              // Horizontal sway
              final sway = sin(progress * pi * 2 + card.startX * 5) * 16;
              final dx = card.startX * screenSize.width + sway;

              // Fade logic
              double opacity;
              if (progress < 0.12) {
                opacity = progress / 0.12;
              } else if (progress > 0.85) {
                opacity = (1 - progress) / 0.15;
              } else {
                opacity = 1;
              }

              opacity *= card.opacity;

              widgets.add(
                Positioned(
                  left: dx - card.width / 2,
                  top: dy - (card.width * 1.4) / 2,
                  child: Transform.rotate(
                    angle: card.angle + progress * 0.6,
                    child: Opacity(
                      opacity: opacity.clamp(0.0, 1.0),
                      child: _PlayingCardShape(
                        width: card.width,
                        suit: card.suit,
                      ),
                    ),
                  ),
                ),
              );
            }

            return widgets;
          }).toList(),
        );
      },
    );
  }
}

// Playing Card Shape
class _PlayingCardShape extends StatelessWidget {
  final double width;
  final String suit;

  const _PlayingCardShape({
    required this.width,
    required this.suit,
  });

  @override
  Widget build(BuildContext context) {
    final height = width * 1.4;
    final radius = width * 0.16;

    final _CardStyle style = _getStyle(suit);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),

        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            style.color.withValues(alpha:0.20),
            style.color.withValues(alpha: 0.05),
          ],
        ),

        border: Border.all(
          color: style.color.withValues(alpha:0.4),
          width: 1.2,
        ),

        boxShadow: [
          BoxShadow(
            color: style.color.withValues(alpha:0.15),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: width * 0.10,
            left: width * 0.12,
            child: Text(
              suit.toUpperCase(),
              style: TextStyle(
                color: style.color.withValues(alpha:0.8),
                fontSize: width * 0.14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),

          // Bottom label (mirrored)
          Positioned(
            bottom: width * 0.10,
            right: width * 0.12,
            child: Transform.rotate(
              angle: pi,
              child: Text(
                suit.toUpperCase(),
                style: TextStyle(
                  color: style.color.withValues(alpha: 0.8),
                  fontSize: width * 0.14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),

          Center(
            child: Text(
              suit,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: style.color.withValues(alpha: 0.9),
                fontSize: width * 0.32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _CardStyle _getStyle(String suit) {
    switch (suit) {
      case 'Plan':
        return _CardStyle(const Color(0xFF4DA3FF)); 
      case 'Time':
        return _CardStyle(const Color(0xFF2F80ED)); 
      case 'Task':
        return _CardStyle(const Color(0xFF56CCF2)); 
      case 'Play':
        return _CardStyle(const Color(0xFF1C6DD0));
      default:
        return _CardStyle(Colors.white);
    }
  }
}

class _CardStyle {
  final Color color;
  const _CardStyle(this.color);
}

class _CardData {
  final double startX;
  final double startY;
  final double width;
  final double angle;
  final double speed;
  final double opacity;
  final String suit;

  const _CardData({
    required this.startX,
    required this.startY,
    required this.width,
    required this.angle,
    required this.speed,
    required this.opacity,
    required this.suit,
  });
}
import 'dart:math';
import 'package:flutter/material.dart';

/// Animated floating background cards used to reinforce
/// the Cards On Time visual identity.
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

class _FloatingCardsBackgroundState
    extends State<FloatingCardsBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_CardData> _cards;

  static const List<String> _suits = [
    'Plan',
    'Time',
    'Task',
    'Play',
  ];

  static const Map<String, Color> _cardColors = {
    'Plan': Color(0xFF4DA3FF),
    'Time': Color(0xFF2F80ED),
    'Task': Color(0xFF56CCF2),
    'Play': Color(0xFF1C6DD0),
  };

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.driftDuration,
    )..repeat();

    final random = Random(7);

    _cards = List.generate(widget.cardCount, (_) {
      final suit = _suits[random.nextInt(_suits.length)];

      return _CardData(
        startX: random.nextDouble(),
        startY: random.nextDouble(),
        width: 44 + random.nextDouble() * 32,
        angle: (random.nextDouble() - 0.5) * pi * 0.6,
        speed: 0.35 + random.nextDouble() * 0.65,
        opacity: 0.06 + random.nextDouble() * 0.10,
        suit: suit,
        color: _cardColors[suit] ?? Colors.white,
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
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final elapsed =
                  _controller.lastElapsedDuration?.inMilliseconds ?? 0;

              final children = <Widget>[];

              for (final card in _cards) {
                final baseProgress =
                    (elapsed / (8000 + card.speed * 4000)) + card.startY;

                for (int i = 0; i < 2; i++) {
                  final progress = (baseProgress + i) % 1.0;

                  final dy = height * (1 - progress);

                  final sway =
                      sin(progress * pi * 2 + card.startX * 5) * 16;

                  final dx = card.startX * width + sway;

                  double opacity;

                  if (progress < 0.12) {
                    opacity = progress / 0.12;
                  } else if (progress > 0.85) {
                    opacity = (1 - progress) / 0.15;
                  } else {
                    opacity = 1;
                  }

                  opacity *= card.opacity;

                  children.add(
                    Positioned(
                      left: dx - card.width / 2,
                      top: dy - (card.width * 1.4) / 2,
                      child: Transform.rotate(
                        angle: card.angle + progress * 0.6,
                        child: Opacity(
                          opacity: opacity.clamp(0.0, 1.0),
                          child: _PlayingCardShape(card: card),
                        ),
                      ),
                    ),
                  );
                }
              }

              return Stack(
                clipBehavior: Clip.hardEdge,
                children: children,
              );
            },
          );
        },
      ),
    );
  }
}

class _PlayingCardShape extends StatelessWidget {
  final _CardData card;

  const _PlayingCardShape({
    required this.card,
  });

  @override
  Widget build(BuildContext context) {
    final height = card.width * 1.4;
    final radius = card.width * 0.16;

    final smallTextStyle = TextStyle(
      color: card.color.withAlpha((0.8 * 255).round()),
      fontSize: card.width * 0.14,
      fontWeight: FontWeight.w600,
      letterSpacing: 1,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
              card.color.withAlpha((0.20 * 255).round()),
              card.color.withAlpha((0.05 * 255).round()),
            ],
        ),
        border: Border.all(
          color: card.color.withAlpha((0.4 * 255).round()),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: card.color.withAlpha((0.15 * 255).round()),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: SizedBox(
        width: card.width,
        height: height,
        child: Stack(
          children: [
            Positioned(
              top: card.width * 0.10,
              left: card.width * 0.12,
              child: Text(
                card.suit.toUpperCase(),
                style: smallTextStyle,
              ),
            ),

            Positioned(
              bottom: card.width * 0.10,
              right: card.width * 0.12,
              child: Transform.rotate(
                angle: pi,
                child: Text(
                  card.suit.toUpperCase(),
                  style: smallTextStyle,
                ),
              ),
            ),

            Center(
              child: Text(
                card.suit,
                textAlign: TextAlign.center,
                  style: TextStyle(
                  color: card.color.withAlpha((0.9 * 255).round()),
                  fontSize: card.width * 0.32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardData {
  final double startX;
  final double startY;
  final double width;
  final double angle;
  final double speed;
  final double opacity;
  final String suit;
  final Color color;

  const _CardData({
    required this.startX,
    required this.startY,
    required this.width,
    required this.angle,
    required this.speed,
    required this.opacity,
    required this.suit,
    required this.color,
  });
}
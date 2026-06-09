import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';

import '../../screens/swipe_game/swipe_game_screen.dart'; // CardEntry, WorkCard, BreakCard

/// A single draggable planning card shown during the swipe game.
///
/// Accepts a [CardEntry] — either a [WorkCard] or a [BreakCard].
/// Break cards render with a distinct icon and softer colour scheme
/// so the user instantly recognises them without needing to read.
///
/// Gesture contract:
///   onDragUpdate — -1.0…+1.0 every frame; feeds SwipeIndicators.
///   onSwiped(true)  — threshold crossed toward right (plan / take break).
///   onSwiped(false) — threshold crossed toward left  (skip / skip break).
/// TODO: clean this code up to make more understandable for myself and fix the comments.

class SwipeCard extends StatefulWidget {
  final CardEntry card;

  /// Running total of minutes already scheduled — used in the question text.
  final int minutesScheduled;

  final ValueChanged<double> onDragUpdate;
  final ValueChanged<bool> onSwiped;

  const SwipeCard({
    super.key,
    required this.card,
    required this.minutesScheduled,
    required this.onDragUpdate,
    required this.onSwiped,
  });

  @override
  State<SwipeCard> createState() => _SwipeCardState();
}

class _SwipeCardState extends State<SwipeCard>
    with SingleTickerProviderStateMixin {
  double _offsetX = 0.0;
  bool _isDragging = false;

  late final AnimationController _snapCtrl;
  late Animation<double> _snapAnim;

  static const double _swipeThreshold = 100.0;
  static const double _maxRotation = 0.12;

  @override
  void initState() {
    super.initState();

    _snapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    _snapAnim = Tween<double>(begin: 0.0, end: 0.0).animate(_snapCtrl);

    _snapCtrl.addListener(() {
      setState(() => _offsetX = _snapAnim.value);
      widget.onDragUpdate(_offsetX / _swipeThreshold);
    });
  }

  @override
  void dispose() {
    _snapCtrl.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails _) {
    _snapCtrl.stop();
    setState(() => _isDragging = true);
  }

  void _onPanUpdate(DragUpdateDetails d) {
    setState(() => _offsetX += d.delta.dx);
    widget.onDragUpdate((_offsetX / _swipeThreshold).clamp(-1.0, 1.0));
  }

  void _onPanEnd(DragEndDetails _) {
    setState(() => _isDragging = false);

    if (_offsetX.abs() >= _swipeThreshold) {
      _commitSwipe(_offsetX > 0);
    } else {
      _snapBack();
    }
  }

  void _commitSwipe(bool accepted) {
    HapticFeedback.mediumImpact();
    widget.onDragUpdate(0.0);
    widget.onSwiped(accepted);
  }

  void _snapBack() {
    _snapAnim = Tween<double>(begin: _offsetX, end: 0.0).animate(
      CurvedAnimation(parent: _snapCtrl, curve: Curves.elasticOut),
    );
    _snapCtrl.forward(from: 0.0);
  }

  double get _rotation =>
      (_offsetX / _swipeThreshold).clamp(-1.0, 1.0) * _maxRotation;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Transform.translate(
        offset: Offset(_offsetX, 0),
        child: Transform.rotate(
          angle: _rotation,
          child: _CardBody(
            card: widget.card,
            minutesScheduled: widget.minutesScheduled,
            isDragging: _isDragging,
          ),
        ),
      ),
    );
  }
}

// ── Card visual ───────────────────────────────────────────────────────────────

class _CardBody extends StatelessWidget {
  final CardEntry card;
  final int minutesScheduled;
  final bool isDragging;

  const _CardBody({
    required this.card,
    required this.minutesScheduled,
    required this.isDragging,
  });

  String _buildQuestion() {
    if (card is BreakCard) {
      return 'You\'ve been working hard.\nWould you like to take a ${card.durationLabel} break?';
    }

    final work = card as WorkCard;
    final name =
        work.baseName.isNotEmpty ? work.baseName : 'this activity';
    final dur = card.durationLabel;

    if (minutesScheduled == 0) {
      return 'Would you like to plan $dur for $name today?';
    }

    final h = minutesScheduled ~/ 60;
    final m = minutesScheduled % 60;
    final spent =
        h > 0 ? (m > 0 ? '${h}h ${m}m' : '${h}h') : '${m}m';

    return 'You have put $spent into your day.\nWould you like to put $dur into $name?';
  }

  // Break cards get a warmer accent; work cards use the primary blue.
  Color get _accentColor =>
      card.isBreak ? const Color(0xFFFFB347) : AppColors.primary;

  IconData get _cardIcon => card.isBreak
      ? Icons.coffee_outlined
      : Icons.work_outline_rounded;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.surveyBackground_3,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: _accentColor.withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDragging ? 0.35 : 0.18),
            blurRadius: isDragging ? 32 : 20,
            spreadRadius: isDragging ? 2 : 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: _accentColor.withValues(alpha: 0.3), width: 1),
            ),
            child: Icon(_cardIcon, color: _accentColor, size: 22),
          ),

          const SizedBox(height: 16),

          // Activity / break name
          Text(
            card.displayName,
            style: AppTextStyles.displayMedium,
          ),

          const SizedBox(height: 8),

          // Duration badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: _accentColor.withValues(alpha: 0.3), width: 1),
            ),
            child: Text(
              card.durationLabel,
              style: AppTextStyles.labelSmall.copyWith(
                color: _accentColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Question
          Text(
            _buildQuestion(),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../shared/models/survey_data.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/widgets/pill_button.dart';

import '../../shared/widgets/swipe_card.dart';
import '../../shared/widgets/swipe_indicators.dart';
import '../../shared/widgets/swipe_time_gain_popup.dart';

// TODO: summary being builded here which should be a seprate screen
// TODO: models, data, widgets, should be seprated objects to have cleaner view of the code. Widgets be named then swipe_name.dart, 
// TODO: models in swipe_game_models.dart, etc or even swipe_game_data.dart. 
// TODO: alot of styling not fitting the design, must update this after the game logic is solid. 
// TODO: don't fully understand code, must make it my own and update it fully to fit the design and my vision for the game.
// TODO: must use shape pixel circle instead of how they show the circles now.
/// TODO: clean this code up to make more understandable for myself and fix the comments.
/// TODO: add a swipe_game_constants.dart for all the magic numbers in this file and make them easily tweakable for playtesting and future updates.


// ─────────────────────────────────────────────────────────────────────────────
// CardEntry  —  sealed union for the two card types in the deck.
// CardEntry is the base class; WorkCard and BreakCard extend it with their specific fields.
//
// WorkCard  — one 30-minute (or shorter) chunk of an activity.
// BreakCard — inserted after every 30 minutes of consecutive accepted work.
// ─────────────────────────────────────────────────────────────────────────────
sealed class CardEntry { 
  const CardEntry();

  String get displayName;
  int get durationMinutes;

  String get durationLabel {
    final h = durationMinutes ~/ 60;
    final m = durationMinutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  bool get isBreak => this is BreakCard;
}

class WorkCard extends CardEntry {
  final String baseName;

  /// Null when the activity was not split into chunks.
  /// Used for display purposes only (e.g. "Reading (Part 1/3)").
  final int? partNumber;
  final int? totalParts;

  @override
  final int durationMinutes;

  const WorkCard({
    required this.baseName,
    required this.durationMinutes,
    this.partNumber,
    this.totalParts,
  });

  @override
  String get displayName {
    if (partNumber != null && totalParts != null) {
      return '$baseName (Part $partNumber/$totalParts)';
    }
    return baseName;
  }
}

class BreakCard extends CardEntry {
  @override
  final int durationMinutes;

  /// How many consecutive work minutes triggered this break — used for the
  /// subtitle so the copy matches reality (e.g. 15+15, 30, 45, etc.).
  final int workedMinutes;

  const BreakCard({
    this.durationMinutes = _kBreakMinutes,
    this.workedMinutes = _kBreakTriggerMinutes,
  });

  @override
  String get displayName => 'Take a break';

  String get subtitle {
    final h = workedMinutes ~/ 60;
    final m = workedMinutes % 60;
    final label = h == 0 ? '${m}m' : (m == 0 ? '${h}h' : '${h}h ${m}m');
    return "You've been working for $label straight. A short rest helps you stay focused.";
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Constants
// ─────────────────────────────────────────────────────────────────────────────
const int _kWorkChunkMinutes = 30; // activities are split into 30-min pieces
const int _kBreakMinutes = 15;     // each break card costs 15 minutes
const int _kBreakTriggerMinutes = 30; // consecutive work before a break appears

// ─────────────────────────────────────────────────────────────────────────────
// Deck builder  —  pure function, no side effects.
//
// Every activity is split into chunks of at most 30 minutes.
// Example: 60 min  → Part 1/2 (30m), Part 2/2 (30m)
//          75 min  → Part 1/3 (30m), Part 2/3 (30m), Part 3/3 (15m)
//
// No break cards are pre-inserted; they are injected at runtime by the state
// machine based on cumulative accepted work time.
// ─────────────────────────────────────────────────────────────────────────────
List<CardEntry> buildDeck(List<ActivityEntry> activities) {
  final deck = <CardEntry>[];

  for (final activity in activities) {
    final total = activity.totalMinutes;

    if (total <= _kWorkChunkMinutes) {
      deck.add(WorkCard(baseName: activity.name, durationMinutes: total));
    } else {
      final parts = (total / _kWorkChunkMinutes).ceil();
      int remaining = total;

      for (int part = 1; part <= parts; part++) {
        final chunkMinutes = remaining.clamp(0, _kWorkChunkMinutes);
        remaining -= chunkMinutes;
        deck.add(WorkCard(
          baseName: activity.name,
          durationMinutes: chunkMinutes,
          partNumber: part,
          totalParts: parts,
        ));
      }
    }
  }

  return deck;
}

// ─────────────────────────────────────────────────────────────────────────────
// SwipeGameScreen
// ─────────────────────────────────────────────────────────────────────────────
class SwipeGameScreen extends StatefulWidget {
  final SurveyDayData surveyData;

  const SwipeGameScreen({super.key, required this.surveyData});

  @override
  State<SwipeGameScreen> createState() => _SwipeGameScreenState();
}

class _SwipeGameScreenState extends State<SwipeGameScreen>
    with SingleTickerProviderStateMixin {
  // ── Deck state ──────────────────────────────────────────────
  late List<CardEntry> _deck;
  final List<CardEntry> _scheduled = [];
  final List<CardEntry> _skipped = [];

  int _minutesUsed = 0;

  // ── Break tracking ───────────────────────────────────────────
  // Tracks consecutive accepted work minutes since the last accepted break.
  // Resets to 0 whenever a break card is accepted.
  int _consecutiveWorkMinutes = 0;

  // ── Energy meter (0.0 – 1.0, starts full) ───────────────────
  // Drops when the player skips a break; recovers slightly on accepted break.
  double _energy = 1.0;

  // ── Swipe indicator ─────────────────────────────────────────
  double _dragProgress = 0.0;

  // ── Time-gain popup ─────────────────────────────────────────
  bool _showPopup = false;
  String _popupLabel = '';

  // ── Card entrance animation ──────────────────────────────────
  late final AnimationController _cardEnterCtrl;
  late final Animation<double> _cardScale;
  late final Animation<double> _cardOpacity;

  // ─────────────────────────────────────────────────────────────
  // Derived state
  // ─────────────────────────────────────────────────────────────

  int get _totalAvailableMinutes => widget.surveyData.totalAvailableMinutes;

  int get _minutesRemaining => _totalAvailableMinutes - _minutesUsed;

  bool get _gameOver {
    if (_minutesUsed >= _totalAvailableMinutes) return true;
    // Also done when deck AND skipped pile are both empty (all work exhausted).
    final onlyBreaksLeft =
        _deck.isNotEmpty && _deck.every((c) => c.isBreak) && _skipped.isEmpty;
    return (_deck.isEmpty && _skipped.isEmpty) || onlyBreaksLeft;
  }

  // ─────────────────────────────────────────────────────────────
  // Init / dispose
  // ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _deck = buildDeck(widget.surveyData.activities);

    _cardEnterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _cardScale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _cardEnterCtrl, curve: Curves.easeOutBack),
    );

    _cardOpacity = CurvedAnimation(
      parent: _cardEnterCtrl,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _cardEnterCtrl.forward();
  }

  @override
  void dispose() {
    _cardEnterCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────
  // Break injection
  // ─────────────────────────────────────────────────────────────
  //
  // Called after every accepted work card.  If consecutive work time has
  // reached 30 minutes AND there is still work left to do, a break card is
  // inserted at the front of the deck.

  void _maybeInjectBreakCard() {
    // Guard: no point suggesting a break if there is no more work coming.
    final hasWorkAhead =
        _deck.any((c) => !c.isBreak) || _skipped.isNotEmpty;
    if (!hasWorkAhead) return;

    // Guard: don't double-inject if there's already a break at the front.
    if (_deck.isNotEmpty && _deck.first.isBreak) return;

    if (_consecutiveWorkMinutes >= _kBreakTriggerMinutes) {
      _deck.insert(0, BreakCard(workedMinutes: _consecutiveWorkMinutes));
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Swipe handlers
  // ─────────────────────────────────────────────────────────────

  void _onDragUpdate(double progress) {
    setState(() => _dragProgress = progress);
  }

  void _onSwiped(bool accepted) {
    if (_deck.isEmpty) return;
    final current = _deck.first;
    if (accepted) {
      _acceptCard(current);
    } else {
      _skipCard(current);
    }
  }

  void _acceptCard(CardEntry card) {
    setState(() {
      _deck.removeAt(0);
      _scheduled.add(card);
      _minutesUsed += card.durationMinutes; // break costs time too
      _dragProgress = 0.0;

      if (card.isBreak) {
        _consecutiveWorkMinutes = 0;
        _energy = (_energy + 0.10).clamp(0.0, 1.0);
      } else {
        _consecutiveWorkMinutes += card.durationMinutes;
        _maybeInjectBreakCard();
      }

      _popupLabel = card.isBreak
          ? '-${_formatDuration(card.durationMinutes)}'
          : '+${_formatDuration(card.durationMinutes)}';
      _showPopup = true;
    });

    _nextCard();
  }

  void _skipCard(CardEntry card) {
    setState(() {
      _deck.removeAt(0);
      _dragProgress = 0.0;

      if (card.isBreak) {
        // Skipped break — energy penalty; consecutive work counter keeps running.
        _energy = (_energy - 0.20).clamp(0.0, 1.0);
        // Re-inject at same threshold so the suggestion repeats.
        // (consecutive work hasn't reset, so _maybeInjectBreakCard will fire
        // again after the next work card is accepted.)
      } else {
        _skipped.add(card);
      }
    });

    _nextCard();
  }

  String _formatDuration(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  void _nextCard() {
    if (_deck.isEmpty) {
      if (_skipped.isNotEmpty && _minutesRemaining > 0) {
        setState(() {
          _deck = List.of(_skipped);
          _skipped.clear();
          _maybeInjectBreakCard();
        });
      }
    }

    if (_deck.isNotEmpty) {
      _cardEnterCtrl.forward(from: 0.0);
    }
  }

  void _onPopupComplete() {
    setState(() => _showPopup = false);
  }

  // ─────────────────────────────────────────────────────────────
  // Time bar helpers
  // ─────────────────────────────────────────────────────────────

  String get _timeRemainingLabel {
    final m = _minutesRemaining;
    final h = m ~/ 60;
    final mins = m % 60;
    if (h == 0) return '${mins}m left';
    if (mins == 0) return '${h}h left';
    return '${h}h ${mins}m left';
  }

  double get _timeBarProgress {
    if (_totalAvailableMinutes == 0) return 0.0;
    return (_minutesUsed / _totalAvailableMinutes).clamp(0.0, 1.0);
  }

  // ─────────────────────────────────────────────────────────────
  // Unfinished activities for summary
  // ─────────────────────────────────────────────────────────────
  //
  // An activity is "unfinished" if at least one of its chunks ended up in the
  // skipped pile when time ran out, or if it was never reached at all.
  // We report it with how many minutes were completed vs total.

  List<_UnfinishedActivity> get _unfinishedActivities {
    // Group scheduled work minutes by base name.
    final doneMinutes = <String, int>{};
    for (final card in _scheduled.whereType<WorkCard>()) {
      doneMinutes[card.baseName] =
          (doneMinutes[card.baseName] ?? 0) + card.durationMinutes;
    }

    // Collect all original activities from the survey.
    final result = <_UnfinishedActivity>[];
    for (final activity in widget.surveyData.activities) {
      final done = doneMinutes[activity.name] ?? 0;
      if (done < activity.totalMinutes) {
        result.add(_UnfinishedActivity(
          name: activity.name,
          totalMinutes: activity.totalMinutes,
          doneMinutes: done,
        ));
      }
    }
    return result;
  }

  // ─────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final showSummary = _gameOver || _deck.isEmpty;
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: showSummary ? _buildSummary() : _buildGame(),
        ),
      ),
    );
  }

  // ── Game view ────────────────────────────────────────────────

  Widget _buildGame() {
    final current = _deck.first;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),

          _TimeBar(
            progress: _timeBarProgress,
            label: _timeRemainingLabel,
          ),

          const SizedBox(height: 8),

          _EnergyBar(energy: _energy),

          const SizedBox(height: 24),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SwipeIndicators(dragProgress: _dragProgress),

                const SizedBox(height: 24),

                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 420),
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      ScaleTransition(
                        scale: _cardScale,
                        child: FadeTransition(
                          opacity: _cardOpacity,
                          child: SwipeCard(
                            key: ValueKey(
                                '${current.displayName}_${current.durationMinutes}_${current.isBreak}'),
                            card: current,
                            minutesScheduled: _minutesUsed,
                            onDragUpdate: _onDragUpdate,
                            onSwiped: _onSwiped,
                          ),
                        ),
                      ),

                      Positioned(
                        top: -40,
                        child: TimeGainPopup(
                          label: _popupLabel,
                          visible: _showPopup,
                          onComplete: _onPopupComplete,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                _SwipeHintRow(isBreak: current.isBreak),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Summary view ─────────────────────────────────────────────

  Widget _buildSummary() {
    // Use the full scheduled list (work + breaks) to preserve insertion order.
    final allScheduled = _scheduled;
    final workCards = allScheduled.whereType<WorkCard>().toList();
    final unfinished = _unfinishedActivities;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          Text('Your plan', style: AppTextStyles.displayMedium),
          const SizedBox(height: 4),
          Text(
            workCards.isEmpty
                ? 'No activities planned.'
                : '${workCards.length} block${workCards.length == 1 ? '' : 's'} scheduled.',
            style: AppTextStyles.subtitle,
          ),

          const SizedBox(height: 20),

          Expanded(
            child: ListView(
              children: [
                // ── Scheduled blocks (work + breaks, in order) ─
                ...allScheduled.map((card) => card is BreakCard
                    ? _BreakSummaryRow(card: card)
                    : _SummaryRow(card: card as WorkCard)),

                // ── Unfinished activities ─────────────────────
                if (unfinished.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    "Didn't fit today",
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  ...unfinished.map((u) => _UnfinishedRow(item: u)),
                ],
              ],
            ),
          ),

          const SizedBox(height: 12),

          PillButton(
            label: 'Done',
            icon: Icons.check_rounded,
            onTap: () {
              Navigator.of(context)
                  .popUntil((route) => route.settings.name == '/home');
            },
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data class for unfinished activities
// ─────────────────────────────────────────────────────────────────────────────

class _UnfinishedActivity {
  final String name;
  final int totalMinutes;
  final int doneMinutes;

  const _UnfinishedActivity({
    required this.name,
    required this.totalMinutes,
    required this.doneMinutes,
  });

  int get remainingMinutes => totalMinutes - doneMinutes;
}

// ── Private sub-widgets ───────────────────────────────────────────────────────

class _TimeBar extends StatelessWidget {
  final double progress;
  final String label;

  const _TimeBar({required this.progress, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall
              .copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: AppColors.surface,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.progressStart,
            ),
          ),
        ),
      ],
    );
  }
}

class _EnergyBar extends StatelessWidget {
  final double energy;

  const _EnergyBar({required this.energy});

  Color get _barColor {
    if (energy > 0.6) return const Color(0xFF52C97A);
    if (energy > 0.3) return const Color(0xFFF5A623);
    return const Color(0xFFE05252);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.bolt_rounded, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: energy,
              minHeight: 5,
              backgroundColor: AppColors.surface,
              valueColor: AlwaysStoppedAnimation<Color>(_barColor),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'Energy',
          style:
              AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _SwipeHintRow extends StatelessWidget {
  final bool isBreak;

  const _SwipeHintRow({required this.isBreak});

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.labelSmall.copyWith(
      color: AppColors.textMuted,
      letterSpacing: 0.4,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isBreak ? 'Swipe left to take break' : 'Swipe left to skip',
          style: style,
        ),
        Text(
          isBreak ? 'Swipe right to skip break' : 'Swipe right to plan',
          style: style,
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final WorkCard card;

  const _SummaryRow({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded,
              size: 18, color: Color(0xFF52C97A)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(card.displayName, style: AppTextStyles.bodyMedium),
          ),
          Text(
            card.durationLabel,
            style: AppTextStyles.labelMedium
                .copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _BreakSummaryRow extends StatelessWidget {
  final BreakCard card;

  const _BreakSummaryRow({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF52C97A).withOpacity(0.25),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.self_improvement_rounded,
              size: 16, color: Color(0xFF52C97A)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Break',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
          ),
          Text(
            card.durationLabel,
            style: AppTextStyles.labelMedium
                .copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _UnfinishedRow extends StatelessWidget {
  final _UnfinishedActivity item;

  const _UnfinishedRow({required this.item});

  String _fmt(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final didPartial = item.doneMinutes > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF5A623).withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule_rounded,
                  size: 18, color: Color(0xFFF5A623)),
              const SizedBox(width: 12),
              Expanded(
                child:
                    Text(item.name, style: AppTextStyles.bodyMedium),
              ),
              Text(
                _fmt(item.remainingMinutes),
                style: AppTextStyles.labelMedium
                    .copyWith(color: const Color(0xFFF5A623)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            didPartial
                ? 'Only ${_fmt(item.doneMinutes)} of ${_fmt(item.totalMinutes)} done — plan the remaining ${_fmt(item.remainingMinutes)} for another day.'
                : 'No time left for this today — consider planning it for another day.',
            style: AppTextStyles.labelSmall
                .copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
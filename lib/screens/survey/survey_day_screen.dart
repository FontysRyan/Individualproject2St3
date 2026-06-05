import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/constants/survey_constants.dart';
import '../../shared/widgets/survey_animated_card.dart';
import '../../shared/widgets/survey_progress_bar.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/widgets/survey_step_time.dart';
import '../../shared/widgets/survey_step_activities.dart';
import '../../shared/widgets/survey_step_ready.dart';
import '../../shared/models/survey_data.dart';
import '../../shared/widgets/delete_popup.dart';

// ─────────────────────────────────────────────────────────────
// SurveyDayScreen — "Plan today" entry point.
//
// Owns all survey state and drives the 3-screen flow:
//   timeSelection (0) → activityPlanning (1) → readyOverview (2)
//
// Screen indices are integer constants from SurveyConstants.
//
// On mount, a one-shot AnimationController runs the intro sequence
// (small circle → full card, title fade-out, background color shift).
// After _introCtrl completes the survey content fades in and the
// controller is never used again.
// ─────────────────────────────────────────────────────────────
class SurveyDayScreen extends StatefulWidget {
  final String userName;

  const SurveyDayScreen({
    super.key,
    required this.userName,
  });

  @override
  State<SurveyDayScreen> createState() => _SurveyDayScreenState();
}

class _SurveyDayScreenState extends State<SurveyDayScreen>
    with SingleTickerProviderStateMixin {
  // ── Intro animation controller (runs once, 0.0 → 1.0) ──────
  late final AnimationController _introCtrl;

  // Title fades in then slides upward and out before the card expands.
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleSlide;

  // _shapeProgress drives width/height from the small pill to full card size.
  // _radiusProgress drives border-radius from fully round to M3 corner radius —
  // it starts later so the shape is already large before it flattens.
  late final Animation<double> _shapeProgress;
  late final Animation<double> _radiusProgress;

  // Fades in the survey content and progress bar once the card is full size.
  late final Animation<double> _surveyContentOpacity;

  // ── Survey state ────────────────────────────────────────────
  int _currentScreenIndex = SurveyConstants.stepTime;

  int _availableHours = SurveyConstants.defaultAvailableHours;
  int _availableMinutes = SurveyConstants.defaultAvailableMinutes;

  /// Null until the user picks a time; the time screen blocks "Continue" while null.
  TimeOfDay? _startTime;

  final List<ActivityEntry> _plannedActivities = [];
  final List<int> _activityKeys = [];
  int _nextActivityKey = 0;

  // ── Derived validation ──────────────────────────────────────

  /// Progress bar value: advances evenly across the 3 screens (0.33 → 0.66 → 1.0).
  double get _screenProgress =>
      (_currentScreenIndex + 1) / SurveyConstants.totalSteps;

  int get _totalAvailableMinutes => _availableHours * 60 + _availableMinutes;

  int get _totalPlannedMinutes =>
      _plannedActivities.fold(0, (sum, a) => sum + a.totalMinutes);

  bool get _plannedActivitiesFitAvailableTime =>
      _totalPlannedMinutes <= _totalAvailableMinutes;

  /// All activities have a valid name and a duration of at least 15 min or 1 h.
  bool get _allActivitiesAreValid =>
      _plannedActivities.isNotEmpty &&
      _plannedActivities.every((a) => a.isValid);

  /// "Continue" on the activity planning screen is enabled only when there is
  /// at least one valid activity that doesn't overflow the available time.
  bool get _canLeaveActivityPlanningScreen =>
      _allActivitiesAreValid && _plannedActivitiesFitAvailableTime;

  @override
  void initState() {
    super.initState();

    _introCtrl = AnimationController(
      vsync: this,
      duration: SurveyConstants.introAnimationDuration,
    );

    // Title: fade in → hold → fade out. Weights are proportional to total duration.
    _titleOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 12), // fade in
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 8),            // hold
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 16), // fade out
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 64),           // gone
    ]).animate(_introCtrl);

    // Slides the title upward while it fades out (interval 0.20–0.36).
    _titleSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -2.5),
    ).animate(CurvedAnimation(
      parent: _introCtrl,
      curve: const Interval(0.20, 0.36, curve: Curves.easeIn),
    ));

    // Card grows from pill to full size between 0.28 and 0.82.
    _shapeProgress = CurvedAnimation(
      parent: _introCtrl,
      curve: const Interval(0.28, 0.82, curve: Curves.easeInOut),
    );

    // Border-radius flattens from fully round to M3 corner.
    // Starts at 0.54 so it only flattens once the card is already large.
    _radiusProgress = CurvedAnimation(
      parent: _introCtrl,
      curve: const Interval(0.54, 0.82, curve: Curves.easeOut),
    );

    // Survey content fades in at the very end, after the card is fully open.
    _surveyContentOpacity = CurvedAnimation(
      parent: _introCtrl,
      curve: const Interval(0.88, 1.0, curve: Curves.easeOut),
    );

    _introCtrl.forward();
  }

  @override
  void dispose() {
    _introCtrl.dispose();
    super.dispose();
  }

  // ── Screen navigation ────────────────────────────────────────

  void _advanceToNextScreen() {
    if (_currentScreenIndex < SurveyConstants.stepReady) {
      setState(() => _currentScreenIndex++);
    } else {
      _onSurveyConfirmed();
    }
  }

  void _returnToPreviousScreen() {
    if (_currentScreenIndex > SurveyConstants.stepTime) {
      setState(() => _currentScreenIndex--);
    }
  }

  // Called when the user confirms on the ready overview screen.
  // Converts raw state into a typed SurveyDayData and hands it off.
  // TimeOfDay is merged with today's date because the swipe game
  // needs a full DateTime to calculate time slots.
  void _onSurveyConfirmed() {
    final data = SurveyDayData(
      availableHours: _availableHours,
      availableMinutes: _availableMinutes,
      startTime: _startTime != null
          ? DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day,
              _startTime!.hour,
              _startTime!.minute,
            )
          : null,
      activities: List.unmodifiable(_plannedActivities),
    );

    debugPrint('Survey complete: $data');
    // TODO: push to swipe game screen with data
  }

  // ── Activity mutations (owned here, passed down as callbacks) ─

  void _addActivity() {
    setState(() {
      _plannedActivities.add(const ActivityEntry(
        name: '',
        hours: SurveyConstants.defaultActivityHours,
        minutes: SurveyConstants.defaultActivityMinutes,
      ));
      _activityKeys.add(_nextActivityKey++);
    });
  }

  void _updateActivity(int index, ActivityEntry updated) {
    setState(() => _plannedActivities[index] = updated);
  }

  Future<void> _confirmAndDeleteActivity(int index) async {
    final activityName = _plannedActivities[index].name;
    final confirmed = await showConfirmDialog(
      context,
      title: 'Remove activity?',
      description: activityName.trim().isNotEmpty
          ? 'Remove "$activityName" from your plan. This can\'t be undone.'
          : 'Remove this activity from your plan.',
      icon: Icons.delete_outline_rounded,
      confirmLabel: 'Remove',
      cancelLabel: 'Cancel',
      confirmColor: AppColors.oppositeOfPrimary, // material red is universally recognized as "destructive" but not too harsh on the eyes
      cancelColor: AppColors.primary, // a positive color to balance the red and make the choice clearer
    );
    if (confirmed) {
      setState(() {
        _plannedActivities.removeAt(index);
        _activityKeys.removeAt(index);
      });
    }
  }

  // ── Helpers ──────────────────────────────────────────────────

  // Maps the animation progress value (0.0–1.0) to a background color.
  // The card transitions through 3 colors: background_1 → _2 (before 0.50)
  // then _2 → _3 (after 0.50), matching the card expansion timing.
  Color _cardBackgroundColor(double animationValue) {
    if (animationValue < 0.50) {
      final t = ((animationValue - 0.28) / 0.22).clamp(0.0, 1.0);
      return Color.lerp(AppColors.surveyBackground_1, AppColors.surveyBackground_2, t)!;
    }
    final t = ((animationValue - 0.50) / 0.22).clamp(0.0, 1.0);
    return Color.lerp(AppColors.surveyBackground_2, AppColors.surveyBackground_3, t)!;
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  // ── Screen builders ──────────────────────────────────────────

  /// Returns the widget for the current survey screen.
  /// AnimatedSwitcher in [build] handles the crossfade between screens.
  Widget _buildCurrentScreen() {
    switch (_currentScreenIndex) {
      case SurveyConstants.stepTime:
        return _buildTimeSelectionScreen();

      case SurveyConstants.stepActivities:
        return _buildActivityPlanningScreen();

      case SurveyConstants.stepReady:
        return _buildReadyOverviewScreen();

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTimeSelectionScreen() {
    return SurveyStepTime(
      userName: widget.userName,
      availableHours: _availableHours,
      availableMinutes: _availableMinutes,
      startTime: _startTime,
      onHoursChanged: (v) => setState(() => _availableHours = v),
      onMinutesChanged: (v) => setState(() => _availableMinutes = v),
      onStartTimeChanged: (t) => setState(() => _startTime = t),
      // Start time is required; the screen itself shows a validation message
      // when the user taps Continue without having set one.
      onContinue: _startTime != null ? _advanceToNextScreen : null,
    );
  }

  Widget _buildActivityPlanningScreen() {
    return SurveyStepActivities(
      activities: _plannedActivities,
      activityKeys: _activityKeys,
      totalAvailableMinutes: _totalAvailableMinutes,
      totalPlannedMinutes: _totalPlannedMinutes,
      canContinue: _canLeaveActivityPlanningScreen,
      onActivityAdded: _addActivity,
      onActivityUpdated: _updateActivity,
      onActivityDeleteRequested: _confirmAndDeleteActivity,
      onContinue: _advanceToNextScreen,
    );
  }

  Widget _buildReadyOverviewScreen() {
    return SurveyStepReady(
      // Ready screen is read-only; activities are passed for display only.
      // Editing/deleting happens in the activity planning screen (go back).
      activities: _plannedActivities,
      onGoBack: _returnToPreviousScreen,
      onConfirm: _onSurveyConfirmed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final maxCardWidth = size.width - SurveyConstants.cardHorizontalGap * 2;
    final maxCardHeight =
        size.height - SurveyConstants.cardTopGap - SurveyConstants.cardBottomGap;

    return Scaffold(
      body: AppBackground(
        child: AnimatedBuilder(
          animation: _introCtrl,
          builder: (context, _) {
            final animValue = _introCtrl.value;

            final cardWidth =
                _lerp(SurveyConstants.cardMinWidth, maxCardWidth, _shapeProgress.value);
            final cardHeight =
                _lerp(SurveyConstants.cardMinHeight, maxCardHeight, _shapeProgress.value);
            final cornerRadius = _lerp(
              SurveyConstants.archBorderRadius,
              SurveyConstants.m3BorderRadius,
              _radiusProgress.value,
            );

            final cardDecoration = BoxDecoration(
              color: _cardBackgroundColor(animValue),
              borderRadius: BorderRadius.circular(cornerRadius),
            );

            return Stack(
              children: [
                // Card is hidden until 0.27 to avoid a brief flash of a tiny
                // pill at the very start of the animation.
                if (animValue > 0.27)
                  SurveyAnimatedCard(
                    width: cardWidth,
                    height: cardHeight,
                    radius: cornerRadius,
                    decoration: cardDecoration,
                    opacity: _surveyContentOpacity,
                    // KeyedSubtree forces AnimatedSwitcher to treat each screen
                    // as a distinct widget so the crossfade triggers on change.
                    child: AnimatedSwitcher(
                      duration: SurveyConstants.stepSwitchDuration,
                      child: KeyedSubtree(
                        key: ValueKey(_currentScreenIndex),
                        child: _buildCurrentScreen(),
                      ),
                    ),
                  ),

                SurveyProgressBar(
                  progress: _screenProgress,
                  opacity: _surveyContentOpacity,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
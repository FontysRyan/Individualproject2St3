import 'package:flutter/material.dart';

// Styles
import '../../core/theme/app_colors.dart';
import '../../core/constants/survey_constants.dart';

// Widgets
import '../../shared/widgets/survey_animated_card.dart';
import '../../shared/widgets/survey_progress_bar.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/widgets/survey_step_time.dart';
import '../../shared/widgets/survey_step_activities.dart';
import '../../shared/widgets/survey_step_ready.dart';

// Models
import '../../shared/models/survey_data.dart';

// Helpers
import '../../shared/widgets/delete_popup.dart';

// ─────────────────────────────────────────────────────────────
// SurveyDayScreen
//
// Main controller screen for the daily survey flow.
//
// Responsibilities:
// - Controls survey navigation between steps (time, activities, ready)
// - Stores temporary survey state/data (available time, start time, activities)
// - Handles intro animations (card expansion, title fade/slide, progress bar)
// - Builds the active survey step widget (passing necessary data and callbacks)
//
// Step flow:
// 1. Time
// 2. Activities
// 3. Ready confirmation
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
  late final AnimationController _ctrl;
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _shapeProgress;
  late final Animation<double> _radiusProgress;
  late final Animation<double> _gradientOpacity;
  late final Animation<double> _surveyOpacity;

  int _currentStep = SurveyConstants.stepTime; // Start at the first step (time screen)

  int _availableHours = SurveyConstants.defaultAvailableHours; // Default to 1 hour available
  int _availableMinutes = SurveyConstants.defaultAvailableMinutes; // Default to 0 minutes available

  TimeOfDay? _startTime;

  final List<({String name, int hours, int minutes})> _activities = [];

  double get _stepProgress =>
      (_currentStep + 1) / SurveyConstants.totalSteps;

  bool get _canProceedFromActivities =>
      _activities.isNotEmpty &&
      _activities.every(
        (a) =>
            a.name.trim().isNotEmpty &&
            (a.hours > 0 ||
                a.minutes >=
                    SurveyConstants.activityMinDurationMinutes),
      );

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: SurveyConstants.introAnimationDuration,
    );

    _titleOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0),
        weight: 12,
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 8,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0),
        weight: 16,
      ),
      TweenSequenceItem(
        tween: ConstantTween(0.0),
        weight: 64,
      ),
    ]).animate(_ctrl);

    _titleSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -2.5),
    ).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(
          0.20,
          0.36,
          curve: Curves.easeIn,
        ),
      ),
    );

    _shapeProgress = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(
        0.28,
        0.82,
        curve: Curves.easeInOut,
      ),
    );

    _radiusProgress = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(
        0.54,
        0.82,
        curve: Curves.easeOut,
      ),
    );

    _gradientOpacity = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(
        0.72,
        0.86,
        curve: Curves.easeIn,
      ),
    );

    _surveyOpacity = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(
        0.88,
        1.0,
        curve: Curves.easeOut,
      ),
    );

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < SurveyConstants.stepReady) {
      setState(() => _currentStep++);
    } else {
      _onConfirm();
    }
  }

  void _prevStep() {
    if (_currentStep > SurveyConstants.stepTime) {
      setState(() => _currentStep--);
    }
  }

  void _onConfirm() {
    final data = SurveyDayData( // Construct final data object to be used in app logic
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
      activities: _activities
          .map(
            (a) => ActivityEntry(
              name: a.name,
              hours: a.hours,
              minutes: a.minutes,
            ),
          )
          .toList(),
    );

    debugPrint('Survey complete: $data');
  }

  Color _solidColor(double v) {
    if (v < 0.50) {
      final t = ((v - 0.28) / 0.22).clamp(0.0, 1.0);

      return Color.lerp(
        AppColors.surveyBackground_1,
        AppColors.surveyBackground_2,
        t,
      )!;
    }

    final t = ((v - 0.50) / 0.22).clamp(0.0, 1.0);

    return Color.lerp(
      AppColors.surveyBackground_2,
      AppColors.surveyBackground_3,
      t,
    )!;
  }

  static double _lerp(double a, double b, double t) {
    return a + (b - a) * t;
  }

  Widget _buildStep() {
    switch (_currentStep) {
      case SurveyConstants.stepTime:
        return SurveyStepTime(
          userName: widget.userName,
          availableHours: _availableHours,
          availableMinutes: _availableMinutes,
          startTime: _startTime,
          onHoursChanged: (v) {
            setState(() => _availableHours = v);
          },
          onMinutesChanged: (v) {
            setState(() => _availableMinutes = v);
          },
          onStartTimeChanged: (t) {
            setState(() => _startTime = t);
          },
          onContinue: _nextStep,
        );

      case SurveyConstants.stepActivities:
        return SurveyStepActivities(
          activities: _activities,
          canContinue: _canProceedFromActivities,
          onActivitiesChanged: (list) {
            setState(() {
              _activities
                ..clear()
                ..addAll(list);
            });
          },
          onContinue: _nextStep,
        );

      case SurveyConstants.stepReady:
        return SurveyStepReady(
          activities: _activities,
          onNotYet: _prevStep,
          onConfirm: _onConfirm,
          onDeleteActivity: (index) async {
            final confirmed = await showConfirmDialog(
              context,
              title: 'Remove activity?',
              description:
                  "Youre about to remove this activity.",
              icon: Icons.delete_outline_rounded,
              confirmLabel: 'Remove',
              cancelLabel: 'Keep it',
              confirmColor: Colors.redAccent,
            );

            if (confirmed) {
              setState(() {
                _activities.removeAt(index);
              });
            }
          },
        );

      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final maxW =
        size.width - SurveyConstants.cardHorizontalGap * 2;

    final maxH =
        size.height -
        SurveyConstants.cardTopGap -
        SurveyConstants.cardBottomGap;

    return Scaffold(
      body: AppBackground(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            final p = _ctrl.value;

            final shapeW = _lerp(
              SurveyConstants.cardMinWidth,
              maxW,
              _shapeProgress.value,
            );

            final shapeH = _lerp(
              SurveyConstants.cardMinHeight,
              maxH,
              _shapeProgress.value,
            );

            final radius = _lerp(
              SurveyConstants.archBorderRadius,
              SurveyConstants.m3BorderRadius,
              _radiusProgress.value,
            );

            final solid = _solidColor(p);

            final decoration = BoxDecoration(
              color: solid,
              borderRadius: BorderRadius.circular(radius),
            );

            return Stack(
              children: [
                if (p > 0.27)
                  SurveyAnimatedCard(
                    width: shapeW,
                    height: shapeH,
                    radius: radius,
                    decoration: decoration,
                    opacity: _surveyOpacity,
                    child: AnimatedSwitcher(
                      duration:
                          SurveyConstants.stepSwitchDuration,
                      child: KeyedSubtree(
                        key: ValueKey(_currentStep),
                        child: _buildStep(),
                      ),
                    ),
                  ),

                SurveyProgressBar(
                  progress: _stepProgress,
                  opacity: _surveyOpacity,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

// Styles
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';

// Constants
import '../../core/constants/survey_constants.dart';

// Widgets
import '../../shared/widgets/survey_animated_card.dart';
import '../../shared/widgets/survey_progress_bar.dart';
import '../../shared/widgets/survey_section_header.dart';
import '../../shared/widgets/number_stepper_field.dart';
import '../../shared/widgets/time_picker_field.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/widgets/pill_button.dart';
import '../../shared/widgets/activity_input_card.dart';
import '../../shared/widgets/delete_popup.dart';

// Models
import '../../shared/models/survey_data.dart';

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
  // ── Intro animation ──────────────────────────────────────────────────────
  late final AnimationController _ctrl;
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _shapeProgress;
  late final Animation<double> _radiusProgress;
  late final Animation<double> _gradientOpacity;
  late final Animation<double> _surveyOpacity;

  // ── Survey state ──────────────────────────────────────────────────────────
  int _currentStep = SurveyConstants.stepTime;

  // Step 0 – Time
  int _availableHours = SurveyConstants.defaultAvailableHours;
  int _availableMinutes = SurveyConstants.defaultAvailableMinutes;
  TimeOfDay? _startTime;

  // Step 1 – Activities
  final List<({String name, int hours, int minutes})> _activities = [];

  // ── Helpers ───────────────────────────────────────────────────────────────

  double get _stepProgress => (_currentStep + 1) / SurveyConstants.totalSteps;

  bool get _canProceedFromActivities =>
      _activities.isNotEmpty &&
      _activities.every((a) =>
          a.name.trim().isNotEmpty &&
          (a.hours > 0 || a.minutes >= SurveyConstants.activityMinDurationMinutes));

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: SurveyConstants.introAnimationDuration,
    );

    _titleOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 12),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 8),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 16),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 64),
    ]).animate(_ctrl);

    _titleSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -2.5),
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.20, 0.36, curve: Curves.easeIn),
    ));

    _shapeProgress = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.28, 0.82, curve: Curves.easeInOut),
    );

    _radiusProgress = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.54, 0.82, curve: Curves.easeOut),
    );

    _gradientOpacity = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.72, 0.86, curve: Curves.easeIn),
    );

    _surveyOpacity = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.88, 1.0, curve: Curves.easeOut),
    );

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ── Navigation ────────────────────────────────────────────────────────────

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
      activities: _activities
          .map((a) => ActivityEntry(
                name: a.name,
                hours: a.hours,
                minutes: a.minutes,
              ))
          .toList(),
    );

    // TODO: push to SwipeGameScreen and pass `data`
    // Navigator.of(context).pushReplacement(
    //   MaterialPageRoute(builder: (_) => SwipeGameScreen(data: data)),
    // );
    debugPrint('Survey complete: $data');
  }

  // ── Color helpers ─────────────────────────────────────────────────────────

  Color _solidColor(double v) {
    if (v < 0.50) {
      final t = ((v - 0.28) / 0.22).clamp(0.0, 1.0);
      return Color.lerp(AppColors.surveyBackground_1, AppColors.surveyBackground_2, t)!;
    }
    final t = ((v - 0.50) / 0.22).clamp(0.0, 1.0);
    return Color.lerp(AppColors.surveyBackground_2, AppColors.surveyBackground_3, t)!;
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final maxW = size.width - SurveyConstants.cardHorizontalGap * 2;
    final maxH = size.height -
        SurveyConstants.cardTopGap -
        SurveyConstants.cardBottomGap;

    return Scaffold(
      body: AppBackground(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            final p = _ctrl.value;
            final shapeW = _lerp(SurveyConstants.cardMinWidth, maxW, _shapeProgress.value);
            final shapeH = _lerp(SurveyConstants.cardMinHeight, maxH, _shapeProgress.value);
            final radius = _lerp(
              SurveyConstants.archBorderRadius,
              SurveyConstants.m3BorderRadius,
              _radiusProgress.value,
            );
            final solid = _solidColor(p);
            final useGradient = p >= 0.72;

            final decoration = BoxDecoration(
              color: useGradient ? null : solid,
              gradient: useGradient
                  ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.lerp(solid, AppColors.surveyBackground_3, _gradientOpacity.value)!,
                        Color.lerp(solid, AppColors.surveyBackground_4, _gradientOpacity.value)!,
                      ],
                    )
                  : null,
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
                      duration: SurveyConstants.stepSwitchDuration,
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.04, 0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: anim,
                            curve: Curves.easeOut,
                          )),
                          child: child,
                        ),
                      ),
                      child: KeyedSubtree(
                        key: ValueKey(_currentStep),
                        child: _buildStep(),
                      ),
                    ),
                  ),

                // Intro title
                Center(
                  child: FadeTransition(
                    opacity: _titleOpacity,
                    child: SlideTransition(
                      position: _titleSlide,
                      child: Text(
                        'Lets begin!',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.displayLarge,
                      ),
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

  Widget _buildStep() {
    switch (_currentStep) {
      case SurveyConstants.stepTime:
        return _StepTime(
          userName: widget.userName,
          availableHours: _availableHours,
          availableMinutes: _availableMinutes,
          startTime: _startTime,
          onHoursChanged: (v) => setState(() => _availableHours = v),
          onMinutesChanged: (v) => setState(() => _availableMinutes = v),
          onStartTimeChanged: (t) => setState(() => _startTime = t),
          onContinue: _nextStep,
        );

      case SurveyConstants.stepActivities:
        return _StepActivities(
          activities: _activities,
          onActivitiesChanged: (list) => setState(() {
            _activities
              ..clear()
              ..addAll(list);
          }),
          canContinue: _canProceedFromActivities,
          onContinue: _nextStep,
        );

      case SurveyConstants.stepReady:
        return _StepReady(
          activities: _activities,
          onDeleteActivity: (index) async {
            final confirmed = await showConfirmDialog(
              context,
              title: 'Remove activity?',
              description: _activities[index].name.trim().isEmpty
                  ? "Youre about to remove this activity from your plan. This can't be undone."
                  : "Youre about to remove " "${ _activities[index].name}" " from your plan. This cant be undone.",
              icon: Icons.delete_outline_rounded,
              confirmLabel: 'Remove',
              cancelLabel: 'Keep it',
              confirmColor: Colors.redAccent,
            );
            if (confirmed) {
              setState(() => _activities.removeAt(index));
              if (_activities.isEmpty) {
                setState(() => _currentStep = SurveyConstants.stepActivities);
              }
            }
          },
          onNotYet: _prevStep,
          onConfirm: _onConfirm,
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 0 – Time
// ─────────────────────────────────────────────────────────────────────────────

class _StepTime extends StatelessWidget {
  final String userName;
  final int availableHours;
  final int availableMinutes;
  final TimeOfDay? startTime;
  final ValueChanged<int> onHoursChanged;
  final ValueChanged<int> onMinutesChanged;
  final ValueChanged<TimeOfDay?> onStartTimeChanged;
  final VoidCallback onContinue;

  const _StepTime({
    required this.userName,
    required this.availableHours,
    required this.availableMinutes,
    required this.startTime,
    required this.onHoursChanged,
    required this.onMinutesChanged,
    required this.onStartTimeChanged,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SurveySectionHeader(
          title: 'Time',
          subtitle: userName.isNotEmpty
              ? 'Lets see how much time you have today, $userName.'
              : 'Lets see how much time you have today.',
        ),

        const SizedBox(height: 28),

        NumberStepperField(
          label: 'Available hours',
          icon: Icons.schedule_outlined,
          value: availableHours,
          min: 0,
          max: SurveyConstants.maxAvailableHours,
          unit: 'hr',
          onChanged: onHoursChanged,
        ),

        const SizedBox(height: 14),

        NumberStepperField(
          label: 'Extra minutes',
          icon: Icons.timelapse_outlined,
          value: availableMinutes,
          min: SurveyConstants.activityMinMinutes,
          max: SurveyConstants.maxAvailableMinutes,
          step: SurveyConstants.minuteStep,
          unit: 'min',
          onChanged: onMinutesChanged,
        ),

        const SizedBox(height: 14),

        TimePickerField(
          label: 'Start time',
          icon: Icons.timer_outlined,
          value: startTime,
          onChanged: onStartTimeChanged,
        ),

        const Spacer(),

        PillButton(
          label: 'Continue',
          icon: Icons.arrow_forward_rounded,
          alignment: MainAxisAlignment.start,
          onTap: onContinue,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 1 – Activities
// ─────────────────────────────────────────────────────────────────────────────

class _StepActivities extends StatelessWidget {
  final List<({String name, int hours, int minutes})> activities;
  final ValueChanged<List<({String name, int hours, int minutes})>> onActivitiesChanged;
  final bool canContinue;
  final VoidCallback onContinue;

  const _StepActivities({
    required this.activities,
    required this.onActivitiesChanged,
    required this.canContinue,
    required this.onContinue,
  });

  void _addActivity() {
    onActivitiesChanged([
      ...activities,
      (
        name: '',
        hours: SurveyConstants.defaultActivityHours,
        minutes: SurveyConstants.defaultActivityMinutes,
      ),
    ]);
  }

  void _updateActivity(
    int index,
    ({String name, int hours, int minutes}) updated,
  ) {
    final list = [...activities];
    list[index] = updated;
    onActivitiesChanged(list);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SurveySectionHeader(
          title: 'Activities',
          subtitle: 'What are your responsibilities for today?',
        ),

        const SizedBox(height: 20),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              children: [
                for (int i = 0; i < activities.length; i++)
                  ActivityInputCard(
                    key: ValueKey(i),
                    index: i,
                    initialName: activities[i].name,
                    initialHours: activities[i].hours,
                    initialMinutes: activities[i].minutes,
                    onChanged: (updated) => _updateActivity(i, updated),
                  ),

                // Add activity button
                GestureDetector(
                  onTap: _addActivity,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_circle_outline_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Add activity',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        PillButton(
          label: 'Continue',
          icon: Icons.arrow_forward_rounded,
          alignment: MainAxisAlignment.start,
          disabled: !canContinue,
          onTap: canContinue ? onContinue : null,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 2 – Ready
// ─────────────────────────────────────────────────────────────────────────────

class _StepReady extends StatelessWidget {
  final List<({String name, int hours, int minutes})> activities;
  final Future<void> Function(int index) onDeleteActivity;
  final VoidCallback onNotYet;
  final VoidCallback onConfirm;

  const _StepReady({
    required this.activities,
    required this.onDeleteActivity,
    required this.onNotYet,
    required this.onConfirm,
  });

  String _durationLabel(int hours, int minutes) {
    if (hours == 0) return '${minutes}m';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SurveySectionHeader(
          title: 'Ready?',
          subtitle: 'Got more activities or are you ready to start?',
        ),

        const SizedBox(height: 20),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              children: [
                for (int i = 0; i < activities.length; i++)
                  _ActivitySummaryRow(
                    name: activities[i].name,
                    durationLabel: _durationLabel(
                      activities[i].hours,
                      activities[i].minutes,
                    ),
                    onDelete: () => onDeleteActivity(i),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: PillButton(
                label: 'Not yet',
                icon: Icons.arrow_back_rounded,
                alignment: MainAxisAlignment.center,
                // Secondary style: transparent fill, muted text
                // secondary: true,
                onTap: onNotYet,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PillButton(
                label: 'Ready',
                icon: Icons.check_rounded,
                alignment: MainAxisAlignment.center,
                onTap: onConfirm,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Activity summary row (Ready step)
// ─────────────────────────────────────────────────────────────────────────────

class _ActivitySummaryRow extends StatelessWidget {
  final String name;
  final String durationLabel;
  final VoidCallback onDelete;

  const _ActivitySummaryRow({
    required this.name,
    required this.durationLabel,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        // Use surfaceElevated — matches the existing theme, no new color needed
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Accent dot using primary color
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? 'Unnamed' : name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  durationLabel,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Delete button
          GestureDetector(
            onTap: onDelete,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.statusOverloaded.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.close_rounded,
                size: 16,
                color: AppColors.statusOverloaded,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
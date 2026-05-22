import 'package:flutter/material.dart';

// Styles
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/app_theme.dart';

// widgets
import '../../shared/widgets/survey_animated_card.dart';
import '../../shared/widgets/survey_progress_bar.dart';
import '../../shared/widgets/survey_section_header.dart';
import '../../shared/widgets/number_stepper_field.dart';
import '../../shared/widgets/time_picker_field.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/widgets/pill_button.dart';

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

  int _availableHours = 4;

  TimeOfDay? _startTime;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    const gapH = 12.0;
    const gapTop = 60.0;
    const gapBottom = 48.0;

    const minW = 100.0;
    const minH = 88.0;

    final maxW = size.width - gapH * 2;
    final maxH = size.height - gapTop - gapBottom;

    const archRadius = 80.0;
    const m3Radius = 28.0;

    return Scaffold(
      body: AppBackground(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            final p = _ctrl.value;

            final shapeProgress = _shapeProgress.value;
            final radiusProgress = _radiusProgress.value;

            final shapeW = _lerp(minW, maxW, shapeProgress);
            final shapeH = _lerp(minH, maxH, shapeProgress);

            final radius = _lerp(
              archRadius,
              m3Radius,
              radiusProgress,
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
                        Color.lerp(
                          solid,
                          AppColors.surveyBackground_3,
                          _gradientOpacity.value,
                        )!,
                        Color.lerp(
                          solid,
                          AppColors.surveyBackground_4,
                          _gradientOpacity.value,
                        )!,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SurveySectionHeader(
                          title: 'Time',
                          subtitle: widget.userName.isNotEmpty
                              ? 'Lets see how much time you have today, ${widget.userName}.'
                              : 'Lets see how much time you have today.',
                        ),

                        const SizedBox(height: 28),

                        NumberStepperField(
                          label: 'Available hours',
                          icon: Icons.schedule_outlined,
                          value: _availableHours,
                          min: 1,
                          max: 24,
                          unit: 'hr',
                          onChanged: (v) {
                            setState(() {
                              _availableHours = v;
                            });
                          },
                        ),

                        const SizedBox(height: 14),

                        TimePickerField(
                          label: 'Start time',
                          icon: Icons.timer_outlined,
                          value: _startTime,
                          onChanged: (time) {
                            setState(() {
                              _startTime = time;
                            });
                          },
                        ),

                        const Spacer(),

                        PillButton(
                          label: 'Continue',
                          icon: Icons.arrow_forward_rounded,
                          alignment: MainAxisAlignment.start,
                        ),
                      ],
                    ),
                  ),

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
                  progress: 0.25,
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
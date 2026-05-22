import 'package:flutter/material.dart';
import '../../core/theme/text_styles.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/widgets/pill_button.dart';
// Import the new survey screen — adjust the path if your folder structure differs.
import '../survey/survey_day_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeIn =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onPlanToday() {
    // Use a custom fade-out/fade-in transition so the move to SurveyDayScreen
    // feels like an in-place change rather than a slide push.
    Navigator.of(context).push(
      PageRouteBuilder(
        // No back-swipe during an active planning session keeps the flow clean.
        fullscreenDialog: false,
        pageBuilder: (_, _, _) =>
            SurveyDayScreen(userName: widget.userName),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 280),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeIn,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),

                  Text(
                    'Hello ${widget.userName}!',
                    style: AppTextStyles.displayLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Shall we start planning?',
                    style: AppTextStyles.subtitle,
                  ),

                  const Spacer(flex: 1),

                  PillButton(
                    label: 'Start planning today',
                    icon: Icons.calendar_today_outlined,
                    onTap: _onPlanToday, // ← updated
                  ),

                  const SizedBox(height: 16),

                  // Week flow not yet built — disabled until ready.
                  PillButton(
                    label: 'Start planning this week',
                    icon: Icons.calendar_month_outlined,
                    disabled: true,
                  ),

                  const Spacer(flex: 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
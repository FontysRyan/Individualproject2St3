import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/widgets/pill_button.dart';

class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();

    // Simple fade — same as onboarding, keeps transitions consistent
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onPlanToday() {
    Navigator.pushNamed(context, '/survey', arguments: {
      'planType': 'today',
      'userName': widget.userName,
    });
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
                    onTap: _onPlanToday,
                  ),

                  const SizedBox(height: 16),

                  // disabled: true — remove when week flow is ready
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
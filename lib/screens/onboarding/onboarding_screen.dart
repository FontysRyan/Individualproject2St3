import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/pill_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late AnimationController _animController;
  late Animation<double> _fadeIn;

  bool get _canContinue => _nameController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();

    // Simple fade — no slide, keeps the screen clean and calm
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();

    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home', arguments: {
      'userName': name,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No backgroundColor needed — AppBackground handles it
      body: AppBackground(
        child: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: FadeTransition(
              opacity: _fadeIn,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(flex: 3),

                    Text('Have we met?', style: AppTextStyles.displayLarge),
                    const SizedBox(height: 8),
                    Text('What can we call you?', style: AppTextStyles.subtitle),

                    const Spacer(flex: 2),

                    AppTextField(
                      controller: _nameController,
                      focusNode: _focusNode,
                      label: 'Name',
                      hint: 'Please fill in your name',
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      onSubmitted: _canContinue ? (_) => _saveName() : null,
                    ),

                    const SizedBox(height: 24),

                    // Button fades in once something is typed
                    AnimatedOpacity(
                      opacity: _canContinue ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 250),
                      child: PillButton(
                        label: 'Continue',
                        onTap: _canContinue ? _saveName : null,
                      ),
                    ),

                    const Spacer(flex: 4),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
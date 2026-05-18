import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/dev_flags.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/home/home_screen.dart';
// Uncomment as you build each screen:
// import 'screens/survey/survey_screen.dart';
// import 'screens/swipe_game/swipe_screen.dart';
// import 'screens/overview/overview_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final String? savedName = prefs.getString('user_name');

  // DevFlags.forceShowOnboarding = true → always show onboarding (dev mode)
  // Set to false once you're done testing the onboarding flow.
  final bool goToOnboarding =
      DevFlags.forceShowOnboarding || savedName == null || savedName.isEmpty;

  runApp(CardsOnTimeApp(
    initialRoute: goToOnboarding ? '/onboarding' : '/home',
    savedName: savedName ?? '',
  ));
}

class CardsOnTimeApp extends StatelessWidget {
  final String initialRoute;
  final String savedName;

  const CardsOnTimeApp({
    super.key,
    required this.initialRoute,
    required this.savedName,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cards On Time',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: initialRoute,
      onGenerateRoute: (settings) {
        print('Navigating to: ${settings.name}');

        switch (settings.name) {

          case '/onboarding':
            return MaterialPageRoute(
              builder: (_) => const OnboardingScreen(),
            );

          case '/home':
            final args = settings.arguments as Map<String, dynamic>?;
            final name = args?['userName'] as String? ?? savedName;
            return MaterialPageRoute(
              builder: (_) => HomeScreen(userName: name),
            );

          default:
            print('Route not found: ${settings.name}');
            return MaterialPageRoute(
              builder: (ctx) => Scaffold(
                body: AppBackground( // reuse gradient even on error screen
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: Colors.redAccent),
                        const SizedBox(height: 12),
                        Text(
                          'Route "${settings.name}" not found',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushReplacementNamed(ctx, '/home'),
                          child: const Text('Go Home',
                              style: TextStyle(color: Color(0xFF4CAF70))),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
        }
      },
    );
  }
}
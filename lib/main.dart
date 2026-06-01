import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/dev_flags.dart';

// Screens
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/survey/survey_day_screen.dart';

// Uncomment screens for later, don't delete this code yet as I will need it for the next steps of development. -Past me
// import 'screens/swipe_game/swipe_screen.dart';
// import 'screens/overview/overview_screen.dart';

// TODO: fix navigation from home to survey screen and return not logging correctly.
// Navigating to: /home
// Navigating to: null
// Navigating to: null
// Returning to: null

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CardsOnTimeApp());
}

class CardsOnTimeApp extends StatelessWidget {
  const CardsOnTimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cards On Time',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const _StartupRouter(),
      navigatorObservers: [
        RouteLogger(),
      ],
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/onboarding':
            return _fadeRoute(
              const OnboardingScreen(),
              settings: settings,
            );

          case '/home':
            final userName = settings.arguments as String? ?? '';

            return _fadeRoute(
              HomeScreen(userName: userName),
              settings: settings,
            );

          case '/survey/day':
            final userName = settings.arguments as String? ?? '';

            return _fadeRoute(
              SurveyDayScreen(userName: userName),
              settings: settings,
            );

          default:
            // ignore: avoid_print
            print('Route not found: ${settings.name}');

            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const Scaffold(
                body: Center(
                  child: Text('404 – screen not found'),
                ),
              ),
            );
        }
      },
    );
  }
}

/// Logs all navigation events.
class RouteLogger extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // ignore: avoid_print
    print('Navigating to: ${route.settings.name}');
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({
    Route<dynamic>? newRoute,
    Route<dynamic>? oldRoute,
  }) {
    // ignore: avoid_print
    print('Navigating to: ${newRoute?.settings.name}');
    super.didReplace(
      newRoute: newRoute,
      oldRoute: oldRoute,
    );
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // ignore: avoid_print
    print('Returning to: ${previousRoute?.settings.name}');
    super.didPop(route, previousRoute);
  }
}

/// Reads SharedPreferences on startup and routes to onboarding or home.
class _StartupRouter extends StatefulWidget {
  const _StartupRouter();

  @override
  State<_StartupRouter> createState() => _StartupRouterState();
}

class _StartupRouterState extends State<_StartupRouter> {
  @override
  void initState() {
    super.initState();

    // ignore: avoid_print
    print('========================================');
    // ignore: avoid_print
    print('[StartupRouter] initState');
    // ignore: avoid_print
    print('========================================');

    _route();
  }

  Future<void> _route() async {
    // ignore: avoid_print
    print('========================================');
    // ignore: avoid_print
    print('[StartupRouter] Starting route check...');
    // ignore: avoid_print
    print('========================================');

    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('user_name') ?? '';

    // ignore: avoid_print
    print('[StartupRouter] savedName = "$savedName"');

    // ignore: avoid_print
    print(
      '[StartupRouter] forceShowOnboarding = '
      '${DevFlags.forceShowOnboarding}',
    );

    final hasSavedName = savedName.isNotEmpty;

    // ignore: avoid_print
    print('[StartupRouter] hasSavedName = $hasSavedName');

    if (!mounted) {
      // ignore: avoid_print
      print('[StartupRouter] Widget not mounted anymore, aborting.');

      // ignore: avoid_print
      print('========================================');

      return;
    }

    if (hasSavedName && !DevFlags.forceShowOnboarding) {
      // ignore: avoid_print
      print('[StartupRouter] Decision = HOME');

      // ignore: avoid_print
      print('[StartupRouter] Navigating to /home');

      // ignore: avoid_print
      print('========================================');

      Navigator.pushReplacementNamed(
        context,
        '/home',
        arguments: savedName,
      );
    } else {
      // ignore: avoid_print
      print('[StartupRouter] Decision = ONBOARDING');

      // ignore: avoid_print
      print('[StartupRouter] Navigating to /onboarding');

      // ignore: avoid_print
      print('========================================');

      Navigator.pushReplacementNamed(
        context,
        '/onboarding',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}

PageRoute<T> _fadeRoute<T>(
  Widget page, {
  required RouteSettings settings,
}) {
  return PageRouteBuilder<T>(
    settings: settings,
    pageBuilder: (_, _, _) => page,
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
  );
}
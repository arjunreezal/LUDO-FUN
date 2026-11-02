import 'package:flutter/material.dart';

import '../core/widgets/text_sections_screen.dart';
import '../features/game_setup/game_setup_screen.dart';
import '../features/games/ludo/models/match_setup.dart';
import '../features/games/ludo/models/match_summary.dart';
import '../features/games/ludo/screens/ludo_match_screen.dart';
import '../features/games/ludo/screens/ludo_results_screen.dart';
import '../features/home/home_shell.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/splash/splash_screen.dart';

abstract final class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String setup = '/setup';
  static const String match = '/match';
  static const String results = '/results';
  static const String settings = '/settings';
  static const String howToPlay = '/how-to-play';
  static const String privacy = '/privacy';
}

abstract final class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case AppRoutes.splash:
        return _fade(settings, const SplashScreen());
      case AppRoutes.onboarding:
        return _fade(settings, const OnboardingScreen());
      case AppRoutes.home:
        return _fade(settings, const HomeShell());
      case AppRoutes.setup:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => GameSetupScreen(
              mode: args is MatchMode ? args : MatchMode.computer),
        );
      case AppRoutes.match:
        if (args is MatchSetup) {
          return _fade(settings, LudoMatchScreen(setup: args));
        }
        return null;
      case AppRoutes.results:
        if (args is MatchSummary) {
          return _fade(settings, LudoResultsScreen(summary: args));
        }
        return null;
      case AppRoutes.settings:
        return MaterialPageRoute<void>(
            settings: settings, builder: (_) => const SettingsScreen());
      case AppRoutes.howToPlay:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (context) => const TextSectionsScreen(
              kind: TextSectionsKind.howToPlay),
        );
      case AppRoutes.privacy:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (context) =>
              const TextSectionsScreen(kind: TextSectionsKind.privacy),
        );
    }
    return null;
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) =>
      _fade(const RouteSettings(name: AppRoutes.home), const HomeShell());

  static Route<T> _fade<T>(RouteSettings settings, Widget child) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      ),
    );
  }
}

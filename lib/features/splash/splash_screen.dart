import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/router.dart';
import '../../core/widgets/ludo_logo.dart';

/// Launch screen: assembles the logo while preferences and the local profile
/// load, then opens onboarding (first launch) or home.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1100));
  bool _started = false;
  bool _storageFailed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }
    _started = true;
    unawaited(_initialise(context.reduceMotion));
  }

  Future<void> _initialise(bool reduceMotion) async {
    if (reduceMotion) {
      _intro.value = 1;
    } else {
      unawaited(_intro.forward());
    }
    final services = context.services;
    await Future.wait(<Future<void>>[
      services.load(),
      Future<void>.delayed(Duration(milliseconds: reduceMotion ? 300 : 1300)),
    ]);
    if (!mounted) {
      return;
    }
    if (services.storageFailed) {
      setState(() => _storageFailed = true);
      return;
    }
    _continue();
  }

  void _continue() {
    final done = context.services.settings.onboardingComplete;
    Navigator.of(context)
        .pushReplacementNamed(done ? AppRoutes.home : AppRoutes.onboarding);
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                AnimatedBuilder(
                  animation: _intro,
                  builder: (context, _) =>
                      LudoLogoMark(size: 112, progress: _intro.value),
                ),
                const SizedBox(height: 28),
                FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _intro,
                    curve: const Interval(0.55, 1, curve: Curves.easeOut),
                  ),
                  child: const LudoWordmark(fontSize: 40),
                ),
                if (_storageFailed) ...<Widget>[
                  const SizedBox(height: 32),
                  Text(
                    context.strings.storageError,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _continue,
                    child: Text(context.strings.continueLabel),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

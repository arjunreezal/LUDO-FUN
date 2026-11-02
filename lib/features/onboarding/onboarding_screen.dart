import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/router.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/ludo_logo.dart';
import '../games/ludo/widgets/ludo_board_view.dart';

/// Three short pages on first launch. Can be skipped.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pages = PageController();
  int _index = 0;

  static const int _pageCount = 3;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _finish() {
    context.services.settings.completeOnboarding();
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  void _next() {
    if (_index >= _pageCount - 1) {
      _finish();
      return;
    }
    _pages.nextPage(
      duration: Duration(milliseconds: context.reduceMotion ? 1 : 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.strings;
    final theme = Theme.of(context);
    final pages = <(Widget, String, String)>[
      (const LudoLogoMark(size: 132), l10n.onboardingTitle1, l10n.onboardingBody1),
      (const LudoBoardArt(size: 200), l10n.onboardingTitle2, l10n.onboardingBody2),
      (
        Icon(Icons.public_rounded, size: 120, color: theme.colorScheme.primary),
        l10n.onboardingTitle3,
        l10n.onboardingBody3,
      ),
    ];
    final last = _index == _pageCount - 1;

    return Scaffold(
      body: SafeArea(
        child: ContentWidth(
          maxWidth: 520,
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: TextButton(
                    onPressed: _finish,
                    child: Text(l10n.onboardingSkip),
                  ),
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pages,
                  onPageChanged: (index) => setState(() => _index = index),
                  children: <Widget>[
                    for (final (art, title, body) in pages)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            art,
                            const SizedBox(height: 40),
                            Text(title,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.headlineMedium),
                            const SizedBox(height: 12),
                            Text(
                              body,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  for (var i = 0; i < _pageCount; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == _index ? 22 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _index
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _next,
                    child: Text(last ? l10n.onboardingStart : l10n.onboardingNext),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo/app/app.dart';
import 'package:ludo/app/app_scope.dart';
import 'package:ludo/app/app_services.dart';
import 'package:ludo/app/theme.dart';
import 'package:ludo/core/l10n/app_strings.dart';
import 'package:ludo/core/storage/key_value_store.dart';
import 'package:ludo/features/game_setup/game_setup_screen.dart';
import 'package:ludo/features/games/ludo/models/match_setup.dart';
import 'package:ludo/features/games/ludo/widgets/ludo_board_view.dart';

import 'support/ludo_fixtures.dart';

Widget _harness(AppServices services, Widget child) => AppScope(
      services: services,
      language: AppLanguage.en,
      child: MaterialApp(theme: LudoTheme.dark(), home: child),
    );

void main() {
  testWidgets('first launch shows onboarding after the splash', (tester) async {
    await tester.pumpWidget(LudoApp(services: AppServices(store: MemoryStore())));
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to LUDO'), findsOneWidget);
  });

  testWidgets('returning players land on home with quick play', (tester) async {
    final store = MemoryStore(<String, Object>{'onboarding.done': true});
    await tester.pumpWidget(LudoApp(services: AppServices(store: store)));
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
    expect(find.text('Quick play'), findsOneWidget);
    expect(find.text('Classic Ludo'), findsWidgets);
  });

  testWidgets('setup screen changes the number of seats', (tester) async {
    final services = AppServices(store: MemoryStore());
    await services.load();
    await tester.pumpWidget(
        _harness(services, const GameSetupScreen(mode: MatchMode.computer)));
    await tester.pumpAndSettle();
    expect(find.text('Computer 3'), findsOneWidget);

    await tester.tap(find.text('2'));
    await tester.pumpAndSettle();
    expect(find.text('Computer 3'), findsNothing);
    expect(find.text('Computer 1'), findsOneWidget);
  });

  testWidgets('board reports taps on movable tokens', (tester) async {
    var state = engine.newGame(players: fourSeats());
    state = engine.roll(state, 6).state;
    int? tapped;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              height: 300,
              child: LudoBoardView(
                state: state,
                animation: null,
                movableTokens: const <int>{0, 1, 2, 3},
                onTokenTap: (token) => tapped = token,
                reduceMotion: true,
                semanticLabel: 'board',
              ),
            ),
          ),
        ),
      ),
    );
    // 300 px / 15 cells = 20 px per cell. Red's first base slot sits at
    // cell coordinates (2, 2).
    final origin = tester.getTopLeft(find.byType(LudoBoardView));
    await tester.tapAt(origin + const Offset(40, 40));
    expect(tapped, 0);
  });
}

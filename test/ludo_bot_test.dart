import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:ludo/features/bots/ludo_bot.dart';
import 'package:ludo/features/games/ludo/models/game_state.dart';
import 'package:ludo/features/games/ludo/models/ludo_color.dart';
import 'package:ludo/features/games/ludo/models/ludo_constants.dart';
import 'package:ludo/features/games/ludo/models/player_seat.dart';

import 'support/ludo_fixtures.dart';

int progressAt(LudoColor color, int index) =>
    (index - color.index * LudoConstants.seatOffset) %
    LudoConstants.trackLength;

void main() {
  test('every difficulty only picks legal tokens', () {
    final random = Random(11);
    for (final difficulty in BotDifficulty.values) {
      final bot = LudoBot(random: Random(difficulty.index));
      var state = engine.newGame(players: fourSeats());
      for (var step = 0; step < 600 && !state.isFinished; step++) {
        if (state.phase == TurnPhase.awaitingRoll) {
          state = engine.roll(state, random.nextInt(6) + 1).state;
          continue;
        }
        final legal = engine.legalMoves(state).map((move) => move.token).toSet();
        final token = bot.chooseToken(state, difficulty);
        expect(legal, contains(token));
        state = engine.move(state, token).state;
      }
    }
  });

  test('asking for a move when none is pending is an error', () {
    final bot = LudoBot(random: Random(1));
    final state = engine.newGame(players: fourSeats());
    expect(() => bot.chooseToken(state, BotDifficulty.hard), throwsStateError);
  });

  test('medium and hard take an available capture', () {
    final state = awaitingMove(tokens: <int, List<int>>{
      0: <int>[2, 30, base, base],
      1: <int>[progressAt(LudoColor.green, 5), base, base, base],
    }, dice: 3);
    for (final difficulty in <BotDifficulty>[
      BotDifficulty.medium,
      BotDifficulty.hard,
    ]) {
      final bot = LudoBot(random: Random(5));
      expect(bot.chooseToken(state, difficulty), 0, reason: difficulty.name);
    }
  });

  test('hard finishes a token rather than making a plain move', () {
    final state = awaitingMove(tokens: <int, List<int>>{
      0: <int>[52, 20, base, base],
    }, dice: 4);
    final bot = LudoBot(random: Random(5));
    expect(bot.chooseToken(state, BotDifficulty.hard), 0);
  });

  test('hard steps out of danger onto a safe square', () {
    // Red token 0 sits on absolute 4 with a green token two squares behind
    // it. Rolling 4 reaches the star square at absolute 8. Token 1 is far
    // away and safe either way.
    final state = awaitingMove(tokens: <int, List<int>>{
      0: <int>[4, 26, base, base],
      1: <int>[progressAt(LudoColor.green, 2), base, base, base],
    }, dice: 4);
    final bot = LudoBot(random: Random(5));
    expect(bot.chooseToken(state, BotDifficulty.hard), 0);
  });
}

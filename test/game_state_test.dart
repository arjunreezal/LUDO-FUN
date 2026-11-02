import 'package:flutter_test/flutter_test.dart';
import 'package:ludo/features/games/ludo/models/game_state.dart';
import 'package:ludo/features/games/ludo/models/ludo_color.dart';
import 'package:ludo/features/games/ludo/models/ludo_ruleset.dart';
import 'package:ludo/features/games/ludo/models/player_seat.dart';

import 'support/ludo_fixtures.dart';

void main() {
  test('copyWith keeps untouched fields and can clear the dice', () {
    final state = awaitingMove(tokens: <int, List<int>>{
      0: <int>[10, base, base, base],
    }, dice: 4);
    final moved = state.copyWith(currentPlayer: 2);
    expect(moved.dice, 4);
    expect(moved.tokens, state.tokens);
    expect(moved.currentPlayer, 2);
    expect(state.copyWith(clearDice: true).dice, isNull);
  });

  test('tokensCopy returns an independent mutable copy', () {
    final state = engine.newGame(players: fourSeats());
    final copy = state.tokensCopy();
    copy[0][0] = 12;
    expect(state.tokens[0][0], base);
  });

  test('progress score, placements and active seats', () {
    final state = stateWith(
      tokens: <int, List<int>>{
        0: <int>[home, home, home, home],
        1: <int>[0, 9, base, base],
      },
      placements: <int>[0],
    );
    expect(state.progressScore(1), 1 + 10);
    expect(state.progressScore(2), 0);
    expect(state.placementOf(0), 1);
    expect(state.placementOf(1), isNull);
    expect(state.activePlayers, <int>[1, 2, 3]);
    expect(state.finishedTokenCount(0), 4);
    expect(state.baseTokenCount(1), 2);
    expect(state.winner, 0);
  });

  test('ruleset survives a JSON round trip', () {
    const rules = LudoRuleset(
      entryRolls: <int>{1, 6},
      extraTurnOnSix: false,
      maxConsecutiveSixes: 2,
      extraTurnOnCapture: false,
      extraTurnOnFinish: false,
      safeSquaresEnabled: false,
      endCondition: MatchEndCondition.firstFinisher,
      rankComputersWhenHumansDone: false,
    );
    final restored = LudoRuleset.fromJson(rules.toJson());
    expect(restored.toJson(), rules.toJson());
  });

  test('malformed ruleset JSON falls back to the defaults', () {
    final restored = LudoRuleset.fromJson(<String, Object>{
      'entryRolls': <Object>['x', 9],
      'maxConsecutiveSixes': -3,
      'safeSquaresEnabled': 'yes',
    });
    expect(restored.toJson(), LudoRuleset.standard.toJson());
    expect(LudoRuleset.fromJson(null).toJson(), LudoRuleset.standard.toJson());
  });

  test('seats survive a JSON round trip', () {
    const seat = PlayerSeat(
      id: 'seat-1',
      name: 'Bot',
      color: LudoColor.blue,
      controller: SeatController.computer,
      difficulty: BotDifficulty.hard,
      isLocalProfile: false,
    );
    final restored = PlayerSeat.fromJson(seat.toJson());
    expect(restored, isNotNull);
    expect(restored!.toJson(), seat.toJson());
    expect(PlayerSeat.fromJson('nope'), isNull);
  });

  test('opposite colours face each other', () {
    expect(LudoColor.red.opposite, LudoColor.yellow);
    expect(LudoColor.green.opposite, LudoColor.blue);
  });

  test('phase helpers', () {
    final state = engine.newGame(players: fourSeats());
    expect(state.isFinished, isFalse);
    expect(state.phase, TurnPhase.awaitingRoll);
    expect(state.currentSeat.color, LudoColor.red);
  });
}

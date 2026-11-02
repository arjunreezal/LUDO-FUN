import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:ludo/features/bots/ludo_bot.dart';
import 'package:ludo/features/games/ludo/engine/ludo_engine.dart';
import 'package:ludo/features/games/ludo/engine/ludo_track.dart';
import 'package:ludo/features/games/ludo/models/game_state.dart';
import 'package:ludo/features/games/ludo/models/ludo_color.dart';
import 'package:ludo/features/games/ludo/models/ludo_constants.dart';
import 'package:ludo/features/games/ludo/models/ludo_event.dart';
import 'package:ludo/features/games/ludo/models/ludo_ruleset.dart';
import 'package:ludo/features/games/ludo/models/player_seat.dart';

import 'support/ludo_fixtures.dart';

/// Progress a token of [color] needs to stand on absolute track [index].
int progressAt(LudoColor color, int index) =>
    (index - color.index * LudoConstants.seatOffset) %
    LudoConstants.trackLength;

bool hasEvent(ActionResult result, LudoEventType type) =>
    result.events.any((event) => event.type == type);

final Matcher throwsIllegal = throwsA(isA<IllegalActionException>());

void main() {
  group('new game', () {
    test('every token starts in base and the first seat rolls', () {
      final state = engine.newGame(players: fourSeats());
      expect(state.phase, TurnPhase.awaitingRoll);
      expect(state.currentPlayer, 0);
      expect(state.dice, isNull);
      expect(state.version, 0);
      for (final row in state.tokens) {
        expect(row, everyElement(base));
      }
    });

    test('seats are ordered clockwise by colour', () {
      final state = engine.newGame(
          players:
              seatsFor(<LudoColor>[LudoColor.blue, LudoColor.red, LudoColor.yellow]));
      expect(state.players.map((seat) => seat.color).toList(),
          <LudoColor>[LudoColor.red, LudoColor.yellow, LudoColor.blue]);
    });

    test('rejects invalid seat lists and rules', () {
      expect(() => engine.newGame(players: seatsFor(<LudoColor>[LudoColor.red])),
          throwsArgumentError);
      expect(
        () => engine.newGame(players: const <PlayerSeat>[
          PlayerSeat(id: 'a', name: 'A', color: LudoColor.red),
          PlayerSeat(id: 'b', name: 'B', color: LudoColor.red),
        ]),
        throwsArgumentError,
      );
      expect(
        () => engine.newGame(
            players: fourSeats(),
            rules: const LudoRuleset(entryRolls: <int>{})),
        throwsArgumentError,
      );
    });
  });

  group('dice rolls', () {
    test('values outside 1-6 are rejected', () {
      final state = engine.newGame(players: fourSeats());
      expect(() => engine.roll(state, 0), throwsIllegal);
      expect(() => engine.roll(state, 7), throwsIllegal);
    });

    test('a roll cannot be made while a move is pending', () {
      final state = awaitingMove(tokens: <int, List<int>>{
        0: <int>[10, base, base, base],
      }, dice: 3);
      expect(() => engine.roll(state, 4), throwsIllegal);
    });

    test('without a six and with all tokens in base the turn passes', () {
      final state = engine.newGame(players: fourSeats());
      final result = engine.roll(state, 4);
      expect(hasEvent(result, LudoEventType.noLegalMoves), isTrue);
      expect(result.state.currentPlayer, 1);
      expect(result.state.phase, TurnPhase.awaitingRoll);
      expect(result.state.dice, isNull);
    });

    test('a six lets every base token enter', () {
      final state = engine.newGame(players: fourSeats());
      final result = engine.roll(state, 6);
      expect(result.state.phase, TurnPhase.awaitingMove);
      final moves = engine.legalMoves(result.state);
      expect(moves, hasLength(4));
      expect(moves.every((move) => move.entersBoard), isTrue);
    });
  });

  group('token entry', () {
    test('entering puts the token on its start square and a six rolls again', () {
      final rolled = engine.roll(engine.newGame(players: fourSeats()), 6).state;
      final result = engine.move(rolled, 2);
      expect(result.state.tokens[0][2], LudoConstants.startProgress);
      expect(hasEvent(result, LudoEventType.tokenEntered), isTrue);
      expect(result.state.currentPlayer, 0);
      expect(result.state.phase, TurnPhase.awaitingRoll);
    });

    test('entry rolls are configurable', () {
      final state = engine.newGame(
          players: fourSeats(),
          rules: const LudoRuleset(entryRolls: <int>{1, 6}));
      final result = engine.roll(state, 1);
      expect(result.state.phase, TurnPhase.awaitingMove);
      expect(engine.legalMoves(result.state), hasLength(4));
    });
  });

  group('movement', () {
    test('a token moves forward by the roll and the turn passes', () {
      final state = awaitingMove(tokens: <int, List<int>>{
        0: <int>[10, base, base, base],
      }, dice: 3);
      final result = engine.move(state, 0);
      expect(result.state.tokens[0][0], 13);
      expect(result.state.currentPlayer, 1);
    });

    test('an illegal token is rejected and the state is untouched', () {
      final state = awaitingMove(tokens: <int, List<int>>{
        0: <int>[10, base, base, base],
      }, dice: 3);
      expect(() => engine.move(state, 1), throwsIllegal);
      expect(() => engine.move(state, 9), throwsIllegal);
      expect(state.tokens[0], <int>[10, base, base, base]);
      expect(state.phase, TurnPhase.awaitingMove);
    });

    test('moving before rolling is rejected', () {
      final state = stateWith(tokens: <int, List<int>>{
        0: <int>[10, base, base, base],
      });
      expect(() => engine.move(state, 0), throwsIllegal);
    });

    test('state lists cannot be mutated from outside', () {
      final state = engine.newGame(players: fourSeats());
      expect(() => state.tokens[0][0] = 5, throwsUnsupportedError);
      expect(() => state.players.clear(), throwsUnsupportedError);
    });
  });

  group('captures', () {
    test('landing on an opponent sends it home and earns a roll', () {
      final state = awaitingMove(tokens: <int, List<int>>{
        0: <int>[2, base, base, base],
        1: <int>[progressAt(LudoColor.green, 5), base, base, base],
      }, dice: 3);
      final moves = engine.legalMoves(state);
      expect(moves.single.isCapture, isTrue);
      final result = engine.move(state, 0);
      expect(result.state.tokens[0][0], 5);
      expect(result.state.tokens[1][0], base);
      expect(hasEvent(result, LudoEventType.tokenCaptured), isTrue);
      expect(result.state.currentPlayer, 0);
      expect(result.state.phase, TurnPhase.awaitingRoll);
    });

    test('every opponent token on the square is captured', () {
      final square = progressAt(LudoColor.green, 5);
      final state = awaitingMove(tokens: <int, List<int>>{
        0: <int>[2, base, base, base],
        1: <int>[square, square, base, base],
      }, dice: 3);
      final result = engine.move(state, 0);
      expect(result.state.tokens[1], <int>[base, base, base, base]);
    });

    test('capture bonus can be switched off', () {
      final state = awaitingMove(
        tokens: <int, List<int>>{
          0: <int>[2, base, base, base],
          1: <int>[progressAt(LudoColor.green, 5), base, base, base],
        },
        dice: 3,
        rules: const LudoRuleset(extraTurnOnCapture: false),
      );
      final result = engine.move(state, 0);
      expect(result.state.currentPlayer, 1);
    });

    test('a seat never captures its own tokens', () {
      final state = awaitingMove(tokens: <int, List<int>>{
        0: <int>[2, 5, base, base],
      }, dice: 3);
      final result = engine.move(state, 0);
      expect(result.state.tokens[0], <int>[5, 5, base, base]);
      expect(hasEvent(result, LudoEventType.tokenCaptured), isFalse);
    });
  });

  group('safe squares', () {
    test('star squares protect opponents', () {
      expect(LudoTrack.isSafeIndex(8), isTrue);
      final state = awaitingMove(tokens: <int, List<int>>{
        0: <int>[3, base, base, base],
        1: <int>[progressAt(LudoColor.green, 8), base, base, base],
      }, dice: 5);
      expect(engine.legalMoves(state).single.isCapture, isFalse);
      final result = engine.move(state, 0);
      expect(result.state.tokens[0][0], 8);
      expect(result.state.tokens[1][0], progressAt(LudoColor.green, 8));
    });

    test('start squares protect their owner', () {
      final state = awaitingMove(tokens: <int, List<int>>{
        0: <int>[10, base, base, base],
        1: <int>[0, base, base, base],
      }, dice: 3);
      final result = engine.move(state, 0);
      expect(result.state.tokens[0][0], 13);
      expect(result.state.tokens[1][0], 0);
    });

    test('safe squares can be switched off', () {
      final state = awaitingMove(
        tokens: <int, List<int>>{
          0: <int>[3, base, base, base],
          1: <int>[progressAt(LudoColor.green, 8), base, base, base],
        },
        dice: 5,
        rules: const LudoRuleset(safeSquaresEnabled: false),
      );
      final result = engine.move(state, 0);
      expect(result.state.tokens[1][0], base);
    });

    test('there are exactly eight safe squares', () {
      final safe = <int>[
        for (var i = 0; i < LudoConstants.trackLength; i++)
          if (LudoTrack.isSafeIndex(i)) i,
      ];
      expect(safe, <int>[0, 8, 13, 21, 26, 34, 39, 47]);
    });
  });

  group('extra turns and sixes', () {
    test('a six earns another roll', () {
      final state = awaitingMove(
        tokens: <int, List<int>>{
          0: <int>[10, base, base, base],
        },
        dice: 6,
        consecutiveSixes: 1,
      );
      final result = engine.move(state, 0);
      expect(result.state.currentPlayer, 0);
      expect(result.state.phase, TurnPhase.awaitingRoll);
      expect(result.state.consecutiveSixes, 1);
    });

    test('the third six in a row forfeits the turn', () {
      var state = stateWith(tokens: <int, List<int>>{
        0: <int>[10, base, base, base],
      });
      state = engine.move(engine.roll(state, 6).state, 0).state;
      state = engine.move(engine.roll(state, 6).state, 0).state;
      expect(state.tokens[0][0], 22);
      expect(state.consecutiveSixes, 2);
      final result = engine.roll(state, 6);
      expect(hasEvent(result, LudoEventType.sixLimitReached), isTrue);
      expect(result.state.currentPlayer, 1);
      expect(result.state.tokens[0][0], 22);
      expect(result.state.consecutiveSixes, 0);
    });

    test('a limit of zero allows any number of sixes', () {
      final state = stateWith(
        tokens: <int, List<int>>{
          0: <int>[10, base, base, base],
        },
        consecutiveSixes: 5,
        rules: const LudoRuleset(maxConsecutiveSixes: 0),
      );
      final result = engine.roll(state, 6);
      expect(result.state.phase, TurnPhase.awaitingMove);
    });

    test('a non-six resets the streak', () {
      final state = stateWith(
        tokens: <int, List<int>>{
          0: <int>[10, base, base, base],
        },
        consecutiveSixes: 2,
      );
      final result = engine.roll(state, 3);
      expect(result.state.consecutiveSixes, 0);
    });
  });

  group('finishing', () {
    test('an overshooting roll is not a legal move', () {
      final state = stateWith(tokens: <int, List<int>>{
        0: <int>[53, home, home, home],
      });
      final result = engine.roll(state, 4);
      expect(hasEvent(result, LudoEventType.noLegalMoves), isTrue);
      expect(result.state.currentPlayer, 1);
    });

    test('an exact roll finishes the token and earns a roll', () {
      final state = awaitingMove(tokens: <int, List<int>>{
        0: <int>[53, 20, base, base],
      }, dice: 3);
      final result = engine.move(state, 0);
      expect(result.state.tokens[0][0], home);
      expect(hasEvent(result, LudoEventType.tokenFinished), isTrue);
      expect(result.state.currentPlayer, 0);
    });

    test('the home column cannot be attacked', () {
      final state = awaitingMove(tokens: <int, List<int>>{
        0: <int>[50, base, base, base],
      }, dice: 1);
      final result = engine.move(state, 0);
      expect(result.state.tokens[0][0], 51);
      expect(LudoTrack.isOnHomeColumn(51), isTrue);
      expect(engine.threatCount(result.state, 0, 51), 0);
    });
  });

  group('no legal moves', () {
    test('a six with no legal move still earns a roll', () {
      final state = stateWith(tokens: <int, List<int>>{
        0: <int>[53, 54, home, home],
      });
      final result = engine.roll(state, 6);
      expect(hasEvent(result, LudoEventType.noLegalMoves), isTrue);
      expect(hasEvent(result, LudoEventType.extraTurn), isTrue);
      expect(result.state.currentPlayer, 0);
      expect(result.state.consecutiveSixes, 1);
    });
  });

  group('turn progression', () {
    test('turns pass clockwise', () {
      var state = engine.newGame(
          players: seatsFor(
              <LudoColor>[LudoColor.red, LudoColor.yellow, LudoColor.blue]));
      final order = <int>[];
      for (var i = 0; i < 4; i++) {
        state = engine.roll(state, 2).state;
        order.add(state.currentPlayer);
      }
      expect(order, <int>[1, 2, 0, 1]);
      expect(state.turnNumber, 5);
    });

    test('finished seats are skipped', () {
      final state = stateWith(
        tokens: <int, List<int>>{
          1: <int>[home, home, home, home],
        },
        placements: <int>[1],
      );
      final result = engine.roll(state, 2);
      expect(result.state.currentPlayer, 2);
    });
  });

  group('winner detection', () {
    test('finishing the last token places the seat and play continues', () {
      final state = awaitingMove(tokens: <int, List<int>>{
        0: <int>[55, home, home, home],
      }, dice: 1);
      final result = engine.move(state, 0);
      expect(result.state.placements, <int>[0]);
      expect(result.state.phase, TurnPhase.awaitingRoll);
      expect(result.state.currentPlayer, 1);
      final finished = result.events
          .firstWhere((event) => event.type == LudoEventType.playerFinished);
      expect(finished.value, 1);
    });

    test('a two-seat match ends when one seat finishes', () {
      final seats = seatsFor(<LudoColor>[LudoColor.red, LudoColor.yellow]);
      final state = awaitingMove(
        seats: seats,
        tokens: <int, List<int>>{
          0: <int>[55, home, home, home],
        },
        dice: 1,
      );
      final result = engine.move(state, 0);
      expect(result.state.isFinished, isTrue);
      expect(result.state.placements, <int>[0, 1]);
      expect(result.state.winner, 0);
      expect(hasEvent(result, LudoEventType.matchFinished), isTrue);
    });

    test('first-finisher matches rank the rest by progress', () {
      final state = awaitingMove(
        tokens: <int, List<int>>{
          0: <int>[55, home, home, home],
          1: <int>[10, base, base, base],
          2: <int>[30, 20, base, base],
        },
        dice: 1,
        rules: const LudoRuleset(endCondition: MatchEndCondition.firstFinisher),
      );
      final result = engine.move(state, 0);
      expect(result.state.isFinished, isTrue);
      expect(result.state.placements, <int>[0, 2, 1, 3]);
    });

    test('computers are ranked once every human has finished', () {
      final seats = seatsFor(
        <LudoColor>[LudoColor.red, LudoColor.green, LudoColor.yellow],
        controllers: <SeatController>[
          SeatController.human,
          SeatController.computer,
          SeatController.computer,
        ],
      );
      final state = awaitingMove(
        seats: seats,
        tokens: <int, List<int>>{
          0: <int>[55, home, home, home],
          2: <int>[40, base, base, base],
        },
        dice: 1,
      );
      final result = engine.move(state, 0);
      expect(result.state.isFinished, isTrue);
      expect(result.state.placements, <int>[0, 2, 1]);
    });

    test('computers play on when ranking is switched off', () {
      final seats = seatsFor(
        <LudoColor>[LudoColor.red, LudoColor.green, LudoColor.yellow],
        controllers: <SeatController>[
          SeatController.human,
          SeatController.computer,
          SeatController.computer,
        ],
      );
      final state = awaitingMove(
        seats: seats,
        tokens: <int, List<int>>{
          0: <int>[55, home, home, home],
        },
        dice: 1,
        rules: const LudoRuleset(rankComputersWhenHumansDone: false),
      );
      final result = engine.move(state, 0);
      expect(result.state.isFinished, isFalse);
      expect(result.state.currentPlayer, 1);
    });
  });

  group('restart and versions', () {
    test('every successful action increases the version', () {
      var state = engine.newGame(players: fourSeats());
      state = engine.roll(state, 6).state;
      expect(state.version, 1);
      state = engine.move(state, 0).state;
      expect(state.version, 2);
    });

    test('restart keeps seats and rules and resets the board', () {
      var state = engine.newGame(
          players: fourSeats(),
          rules: const LudoRuleset(maxConsecutiveSixes: 2));
      state = engine.move(engine.roll(state, 6).state, 0).state;
      final fresh = engine.restart(state);
      expect(fresh.players.map((seat) => seat.id),
          state.players.map((seat) => seat.id));
      expect(fresh.rules.maxConsecutiveSixes, 2);
      expect(fresh.version, 0);
      for (final row in fresh.tokens) {
        expect(row, everyElement(base));
      }
    });
  });

  group('state consistency', () {
    test('random full games keep every invariant', () {
      final dice = Random(42);
      final bot = LudoBot(random: Random(7));
      for (var game = 0; game < 90; game++) {
        final count = 2 + game % 3;
        final colors = count == 2
            ? <LudoColor>[LudoColor.red, LudoColor.yellow]
            : LudoColor.values.take(count).toList();
        final seats = seatsFor(colors,
            controllers: List<SeatController>.filled(
                count, SeatController.computer));
        var state = engine.newGame(players: seats);
        var actions = 0;
        while (!state.isFinished) {
          if (state.phase == TurnPhase.awaitingRoll) {
            state = engine.roll(state, dice.nextInt(6) + 1).state;
          } else {
            final token = bot.chooseToken(
                state, BotDifficulty.values[game % BotDifficulty.values.length]);
            state = engine.move(state, token).state;
          }
          _expectConsistent(state);
          actions++;
          expect(actions, lessThan(20000), reason: 'game $game never ended');
        }
        expect(state.placements.toSet(), hasLength(state.playerCount));
      }
    });
  });
}

void _expectConsistent(GameState state) {
  expect(state.dice != null, state.phase == TurnPhase.awaitingMove);
  final occupants = <int, Set<int>>{};
  for (var player = 0; player < state.playerCount; player++) {
    final color = state.players[player].color;
    for (final progress in state.tokens[player]) {
      expect(progress, inInclusiveRange(base, home));
      final index = LudoTrack.absoluteIndex(color, progress);
      if (index != null) {
        occupants.putIfAbsent(index, () => <int>{}).add(player);
      }
    }
    if (!state.isFinished && state.isPlaced(player)) {
      expect(state.tokens[player], everyElement(home));
    }
  }
  occupants.forEach((index, players) {
    if (!LudoTrack.isSafeIndex(index)) {
      expect(players, hasLength(1),
          reason: 'two colours share unsafe square $index');
    }
  });
  if (!state.isFinished) {
    expect(state.isPlaced(state.currentPlayer), isFalse);
  }
}

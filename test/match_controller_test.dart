import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:ludo/features/bots/ludo_bot.dart';
import 'package:ludo/features/games/ludo/controllers/ludo_match_controller.dart';
import 'package:ludo/features/games/ludo/controllers/match_timing.dart';
import 'package:ludo/features/games/ludo/engine/dice.dart';
import 'package:ludo/features/games/ludo/models/game_state.dart';
import 'package:ludo/features/games/ludo/models/ludo_color.dart';
import 'package:ludo/features/games/ludo/models/match_setup.dart';
import 'package:ludo/features/games/ludo/models/player_seat.dart';

MatchSetup _youVsComputer() => const MatchSetup(
      mode: MatchMode.computer,
      players: <PlayerSeat>[
        PlayerSeat(
          id: 'you',
          name: 'You',
          color: LudoColor.red,
          isLocalProfile: true,
        ),
        PlayerSeat(
          id: 'bot',
          name: 'Computer 1',
          color: LudoColor.yellow,
          controller: SeatController.computer,
        ),
      ],
    );

void main() {
  test('plays computer turns and hands control back to the person', () async {
    final controller = LudoMatchController(
      setup: _youVsComputer(),
      timing: MatchTiming.instant,
      dice: ScriptedDiceRoller(<int>[6, 2, 3]),
      bot: LudoBot(random: Random(1)),
    );
    expect(controller.canRoll, isTrue);

    // A six with every token in base: all moves are equivalent, so the token
    // enters automatically and the six earns another roll.
    await controller.rollDice();
    expect(controller.state.tokens[0][0], 0);
    expect(controller.state.currentPlayer, 0);
    expect(controller.canRoll, isTrue);

    // A two has a single legal move; then the computer rolls a three, cannot
    // move, and the turn comes back.
    await controller.rollDice();
    expect(controller.state.tokens[0][0], 2);
    expect(controller.state.currentPlayer, 0);
    expect(controller.state.phase, TurnPhase.awaitingRoll);
    expect(controller.canRoll, isTrue);
    expect(controller.log, isNotEmpty);
    controller.dispose();
  });

  test('waits for a choice when moves differ', () async {
    final controller = LudoMatchController(
      setup: _youVsComputer(),
      timing: MatchTiming.instant,
      dice: ScriptedDiceRoller(<int>[6, 6]),
      bot: LudoBot(random: Random(1)),
    );
    await controller.rollDice();
    await controller.rollDice();
    // Token 0 is on the board and three are in base: two different moves.
    expect(controller.state.phase, TurnPhase.awaitingMove);
    expect(controller.movableTokens, <int>{0, 1, 2, 3});
    await controller.selectToken(0);
    expect(controller.state.tokens[0][0], 6);
    controller.dispose();
  });

  test('restart resets the board and keeps the seats', () async {
    final controller = LudoMatchController(
      setup: _youVsComputer(),
      timing: MatchTiming.instant,
      dice: ScriptedDiceRoller(<int>[6, 2, 3]),
      bot: LudoBot(random: Random(1)),
    );
    await controller.rollDice();
    controller.restart();
    expect(controller.state.tokens[0], everyElement(-1));
    expect(controller.state.players.map((seat) => seat.id), <String>['you', 'bot']);
    expect(controller.log, isEmpty);
    controller.dispose();
  });
}

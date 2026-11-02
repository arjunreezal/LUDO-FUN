import 'package:ludo/features/games/ludo/engine/ludo_engine.dart';
import 'package:ludo/features/games/ludo/models/game_state.dart';
import 'package:ludo/features/games/ludo/models/ludo_color.dart';
import 'package:ludo/features/games/ludo/models/ludo_constants.dart';
import 'package:ludo/features/games/ludo/models/ludo_ruleset.dart';
import 'package:ludo/features/games/ludo/models/player_seat.dart';

const engine = LudoEngine();

/// Four human seats. Seat index equals colour index:
/// 0 red, 1 green, 2 yellow, 3 blue.
List<PlayerSeat> fourSeats({
  SeatController controller = SeatController.human,
}) =>
    <PlayerSeat>[
      for (final color in LudoColor.values)
        PlayerSeat(
          id: color.name,
          name: color.name,
          color: color,
          controller: controller,
        ),
    ];

List<PlayerSeat> seatsFor(List<LudoColor> colors,
        {List<SeatController>? controllers}) =>
    <PlayerSeat>[
      for (var i = 0; i < colors.length; i++)
        PlayerSeat(
          id: colors[i].name,
          name: colors[i].name,
          color: colors[i],
          controller: controllers == null ? SeatController.human : controllers[i],
        ),
    ];

const int base = LudoConstants.inBase;
const int home = LudoConstants.finishedProgress;

/// Builds a state with explicit token positions. Missing seats keep all
/// tokens in base.
GameState stateWith({
  required Map<int, List<int>> tokens,
  List<PlayerSeat>? seats,
  int current = 0,
  TurnPhase phase = TurnPhase.awaitingRoll,
  int? dice,
  int consecutiveSixes = 0,
  LudoRuleset rules = LudoRuleset.standard,
  List<int> placements = const <int>[],
}) {
  final players = seats ?? fourSeats();
  final fresh = engine.newGame(players: players, rules: rules);
  final rows = <List<int>>[
    for (var i = 0; i < fresh.playerCount; i++)
      tokens[i] ?? List<int>.filled(4, base),
  ];
  return fresh.copyWith(
    tokens: rows,
    currentPlayer: current,
    phase: phase,
    dice: dice,
    consecutiveSixes: consecutiveSixes,
    placements: placements,
  );
}

/// Convenience: a state where [current] has already rolled [dice].
GameState awaitingMove({
  required Map<int, List<int>> tokens,
  required int dice,
  int current = 0,
  List<PlayerSeat>? seats,
  LudoRuleset rules = LudoRuleset.standard,
  int consecutiveSixes = 0,
}) =>
    stateWith(
      tokens: tokens,
      seats: seats,
      current: current,
      phase: TurnPhase.awaitingMove,
      dice: dice,
      rules: rules,
      consecutiveSixes: consecutiveSixes,
    );

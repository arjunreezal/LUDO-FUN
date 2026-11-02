import 'ludo_constants.dart';
import 'ludo_ruleset.dart';
import 'player_seat.dart';

/// What the engine is waiting for next.
enum TurnPhase { awaitingRoll, awaitingMove, finished }

/// An immutable snapshot of a Classic Ludo match.
///
/// Every successful action produces a new state with [version] increased by
/// one, so stale or duplicated actions can be detected (the online server
/// will rely on this).
class GameState {
  GameState({
    required this.rules,
    required List<PlayerSeat> players,
    required List<List<int>> tokens,
    required this.currentPlayer,
    required this.phase,
    this.dice,
    this.consecutiveSixes = 0,
    List<int> placements = const <int>[],
    this.version = 0,
    this.turnNumber = 1,
  })  : players = List<PlayerSeat>.unmodifiable(players),
        tokens = List<List<int>>.unmodifiable(
            <List<int>>[for (final row in tokens) List<int>.unmodifiable(row)]),
        placements = List<int>.unmodifiable(placements);

  final LudoRuleset rules;
  final List<PlayerSeat> players;

  /// `tokens[seat][token]` holds the token's progress. See [LudoConstants].
  final List<List<int>> tokens;

  /// Index into [players] of the seat whose turn it is.
  final int currentPlayer;
  final TurnPhase phase;

  /// The roll waiting to be used. Only set while [phase] is
  /// [TurnPhase.awaitingMove].
  final int? dice;

  /// Sixes rolled in a row during the current turn.
  final int consecutiveSixes;

  /// Seat indices in finishing order. The first entry is the winner.
  final List<int> placements;

  final int version;
  final int turnNumber;

  int get playerCount => players.length;
  PlayerSeat get currentSeat => players[currentPlayer];
  bool get isFinished => phase == TurnPhase.finished;
  int? get winner => placements.isEmpty ? null : placements.first;

  bool isPlaced(int player) => placements.contains(player);

  /// Seats that still have tokens to bring home.
  List<int> get activePlayers => <int>[
        for (var i = 0; i < players.length; i++)
          if (!placements.contains(i)) i,
      ];

  int finishedTokenCount(int player) => tokens[player]
      .where((progress) => progress == LudoConstants.finishedProgress)
      .length;

  int baseTokenCount(int player) =>
      tokens[player].where((progress) => progress == LudoConstants.inBase).length;

  /// Total distance travelled by a seat's tokens; used for tie-break ranking.
  int progressScore(int player) {
    var total = 0;
    for (final progress in tokens[player]) {
      if (progress >= 0) {
        total += progress + 1;
      }
    }
    return total;
  }

  /// 1-based placement of [player], or null if not yet placed.
  int? placementOf(int player) {
    final index = placements.indexOf(player);
    return index < 0 ? null : index + 1;
  }

  /// A mutable deep copy of [tokens].
  List<List<int>> tokensCopy() =>
      <List<int>>[for (final row in tokens) <int>[...row]];

  GameState copyWith({
    List<List<int>>? tokens,
    int? currentPlayer,
    TurnPhase? phase,
    int? dice,
    bool clearDice = false,
    int? consecutiveSixes,
    List<int>? placements,
    int? version,
    int? turnNumber,
  }) {
    return GameState(
      rules: rules,
      players: players,
      tokens: tokens ?? this.tokens,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      phase: phase ?? this.phase,
      dice: clearDice ? null : (dice ?? this.dice),
      consecutiveSixes: consecutiveSixes ?? this.consecutiveSixes,
      placements: placements ?? this.placements,
      version: version ?? this.version,
      turnNumber: turnNumber ?? this.turnNumber,
    );
  }
}

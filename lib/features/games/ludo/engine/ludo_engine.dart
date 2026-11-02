import '../models/game_state.dart';
import '../models/ludo_constants.dart';
import '../models/ludo_event.dart';
import '../models/ludo_move.dart';
import '../models/ludo_ruleset.dart';
import '../models/player_seat.dart';
import 'ludo_track.dart';

/// Thrown when an action is not allowed in the current state. The state is
/// never modified when this is thrown.
class IllegalActionException implements Exception {
  const IllegalActionException(this.message);

  final String message;

  @override
  String toString() => 'IllegalActionException: $message';
}

/// The new state produced by an action plus what happened along the way.
class ActionResult {
  const ActionResult(this.state, this.events);

  final GameState state;
  final List<LudoEvent> events;
}

/// The Classic Ludo rules engine.
///
/// Stateless and deterministic: dice values are passed in, so the same inputs
/// always produce the same output. The UI, the computer opponents and (later)
/// the online server all go through this class; none of them apply rules on
/// their own.
class LudoEngine {
  const LudoEngine();

  /// Creates a match. Seats are ordered clockwise by colour, and the first
  /// seat in that order starts unless [firstPlayer] is given.
  GameState newGame({
    required List<PlayerSeat> players,
    LudoRuleset rules = LudoRuleset.standard,
    int firstPlayer = 0,
  }) {
    rules.validate();
    if (players.length < LudoConstants.minPlayers ||
        players.length > LudoConstants.maxPlayers) {
      throw ArgumentError.value(players.length, 'players',
          'Classic Ludo needs between 2 and 4 seats');
    }
    final colors = players.map((seat) => seat.color).toSet();
    if (colors.length != players.length) {
      throw ArgumentError.value(
          players, 'players', 'Each seat needs a different colour');
    }
    final ids = players.map((seat) => seat.id).toSet();
    if (ids.length != players.length) {
      throw ArgumentError.value(players, 'players', 'Seat ids must be unique');
    }
    if (firstPlayer < 0 || firstPlayer >= players.length) {
      throw ArgumentError.value(firstPlayer, 'firstPlayer', 'Out of range');
    }
    final ordered = List<PlayerSeat>.of(players)
      ..sort((a, b) => a.color.index.compareTo(b.color.index));
    return GameState(
      rules: rules,
      players: ordered,
      tokens: <List<int>>[
        for (var i = 0; i < ordered.length; i++)
          List<int>.filled(LudoConstants.tokensPerPlayer, LudoConstants.inBase),
      ],
      currentPlayer: firstPlayer,
      phase: TurnPhase.awaitingRoll,
    );
  }

  /// A fresh match with the same seats and rules.
  GameState restart(GameState state) =>
      newGame(players: state.players, rules: state.rules);

  /// Legal moves for the roll waiting to be used. Empty unless the engine is
  /// waiting for a move.
  List<LudoMove> legalMoves(GameState state) {
    final dice = state.dice;
    if (state.phase != TurnPhase.awaitingMove || dice == null) {
      return const <LudoMove>[];
    }
    return movesFor(state, state.currentPlayer, dice);
  }

  /// The moves [player] could make with [roll] from [state]'s token layout.
  /// Used by [legalMoves] and by computer opponents for look-ahead.
  List<LudoMove> movesFor(GameState state, int player, int roll) {
    if (roll < 1 || roll > 6 || state.isPlaced(player)) {
      return const <LudoMove>[];
    }
    final moves = <LudoMove>[];
    final row = state.tokens[player];
    for (var token = 0; token < row.length; token++) {
      final from = row[token];
      final int to;
      if (from == LudoConstants.inBase) {
        if (!state.rules.entryRolls.contains(roll)) {
          continue;
        }
        to = LudoConstants.startProgress;
      } else if (from >= LudoConstants.finishedProgress) {
        continue;
      } else {
        to = from + roll;
        if (to > LudoConstants.finishedProgress) {
          // Exact roll required to finish.
          continue;
        }
      }
      moves.add(LudoMove(
        player: player,
        token: token,
        from: from,
        to: to,
        captures: _capturesAt(state, player, to),
      ));
    }
    return moves;
  }

  /// Number of opponent tokens that could land on [player]'s square at
  /// [progress] with their next single roll. Safe squares, the home column
  /// and the centre always return zero.
  int threatCount(GameState state, int player, int progress) {
    final color = state.players[player].color;
    final target = LudoTrack.absoluteIndex(color, progress);
    if (target == null) {
      return 0;
    }
    if (state.rules.safeSquaresEnabled && LudoTrack.isSafeIndex(target)) {
      return 0;
    }
    var threats = 0;
    for (var other = 0; other < state.players.length; other++) {
      if (other == player || state.isPlaced(other)) {
        continue;
      }
      final otherColor = state.players[other].color;
      for (final otherProgress in state.tokens[other]) {
        if (otherProgress == LudoConstants.inBase) {
          if (target == LudoTrack.startIndex(otherColor)) {
            threats++;
          }
          continue;
        }
        final from = LudoTrack.absoluteIndex(otherColor, otherProgress);
        if (from == null) {
          continue;
        }
        final distance = (target - from) % LudoConstants.trackLength;
        if (distance >= 1 &&
            distance <= 6 &&
            otherProgress + distance <= LudoConstants.lastTrackProgress) {
          threats++;
        }
      }
    }
    return threats;
  }

  /// Applies a dice roll for the current seat.
  ActionResult roll(GameState state, int value) {
    if (state.phase != TurnPhase.awaitingRoll) {
      throw const IllegalActionException('The engine is not waiting for a roll');
    }
    if (value < 1 || value > 6) {
      throw IllegalActionException('Dice value $value is outside 1-6');
    }
    final player = state.currentPlayer;
    final events = <LudoEvent>[
      LudoEvent(LudoEventType.rolled, player: player, value: value),
    ];
    final sixes = value == 6 ? state.consecutiveSixes + 1 : 0;
    var next = state.copyWith(
      dice: value,
      consecutiveSixes: sixes,
      version: state.version + 1,
    );

    final limit = state.rules.maxConsecutiveSixes;
    if (value == 6 && limit > 0 && sixes >= limit) {
      events.add(LudoEvent(LudoEventType.sixLimitReached,
          player: player, value: sixes));
      return ActionResult(_passTurn(next, events), events);
    }

    final moves = movesFor(next, player, value);
    if (moves.isEmpty) {
      events.add(LudoEvent(LudoEventType.noLegalMoves,
          player: player, value: value));
      if (value == 6 && state.rules.extraTurnOnSix) {
        events.add(LudoEvent(LudoEventType.extraTurn, player: player));
        next = next.copyWith(phase: TurnPhase.awaitingRoll, clearDice: true);
        return ActionResult(next, events);
      }
      return ActionResult(_passTurn(next, events), events);
    }

    next = next.copyWith(phase: TurnPhase.awaitingMove);
    return ActionResult(next, events);
  }

  /// Moves [token] of the current seat using the waiting roll.
  ActionResult move(GameState state, int token) {
    if (state.phase != TurnPhase.awaitingMove) {
      throw const IllegalActionException('The engine is not waiting for a move');
    }
    LudoMove? chosen;
    for (final candidate in legalMoves(state)) {
      if (candidate.token == token) {
        chosen = candidate;
        break;
      }
    }
    if (chosen == null) {
      throw IllegalActionException('Token $token has no legal move');
    }

    final player = state.currentPlayer;
    final rolled = state.dice ?? 0;
    final events = <LudoEvent>[];
    final tokens = state.tokensCopy();
    tokens[player][token] = chosen.to;
    events.add(LudoEvent(
      chosen.entersBoard ? LudoEventType.tokenEntered : LudoEventType.tokenMoved,
      player: player,
      token: token,
      value: chosen.entersBoard ? 0 : chosen.to - chosen.from,
    ));

    for (final victim in chosen.captures) {
      tokens[victim.player][victim.token] = LudoConstants.inBase;
      events.add(LudoEvent(
        LudoEventType.tokenCaptured,
        player: player,
        token: token,
        otherPlayer: victim.player,
        otherToken: victim.token,
      ));
    }

    if (chosen.finishesToken) {
      events.add(
          LudoEvent(LudoEventType.tokenFinished, player: player, token: token));
    }

    var next = state.copyWith(
      tokens: tokens,
      version: state.version + 1,
      clearDice: true,
    );

    final allHome = tokens[player]
        .every((progress) => progress == LudoConstants.finishedProgress);
    if (allHome) {
      final placements = <int>[...state.placements, player];
      events.add(LudoEvent(LudoEventType.playerFinished,
          player: player, value: placements.length));
      next = next.copyWith(placements: placements);
      return ActionResult(_passTurn(next, events), events);
    }

    final rules = state.rules;
    final extraTurn = (rolled == 6 && rules.extraTurnOnSix) ||
        (chosen.isCapture && rules.extraTurnOnCapture) ||
        (chosen.finishesToken && rules.extraTurnOnFinish);
    if (extraTurn) {
      events.add(LudoEvent(LudoEventType.extraTurn, player: player));
      next = next.copyWith(phase: TurnPhase.awaitingRoll);
      return ActionResult(next, events);
    }
    return ActionResult(_passTurn(next, events), events);
  }

  List<TokenRef> _capturesAt(GameState state, int player, int progress) {
    final target =
        LudoTrack.absoluteIndex(state.players[player].color, progress);
    if (target == null) {
      return const <TokenRef>[];
    }
    if (state.rules.safeSquaresEnabled && LudoTrack.isSafeIndex(target)) {
      return const <TokenRef>[];
    }
    final captures = <TokenRef>[];
    for (var other = 0; other < state.players.length; other++) {
      if (other == player) {
        continue;
      }
      final otherColor = state.players[other].color;
      final row = state.tokens[other];
      for (var token = 0; token < row.length; token++) {
        if (LudoTrack.absoluteIndex(otherColor, row[token]) == target) {
          captures.add(TokenRef(other, token));
        }
      }
    }
    return captures;
  }

  bool _matchShouldEnd(GameState state) {
    final remaining = state.activePlayers;
    if (remaining.length <= 1) {
      return true;
    }
    if (state.rules.endCondition == MatchEndCondition.firstFinisher &&
        state.placements.isNotEmpty) {
      return true;
    }
    if (state.rules.rankComputersWhenHumansDone &&
        state.players.any((seat) => seat.isHuman) &&
        remaining.every((index) => state.players[index].isComputer)) {
      return true;
    }
    return false;
  }

  GameState _finishMatch(GameState state, List<LudoEvent> events) {
    final remaining = state.activePlayers
      ..sort((a, b) {
        final byProgress =
            state.progressScore(b).compareTo(state.progressScore(a));
        return byProgress != 0 ? byProgress : a.compareTo(b);
      });
    final placements = <int>[...state.placements, ...remaining];
    events.add(LudoEvent(LudoEventType.matchFinished, player: placements.first));
    return state.copyWith(
      placements: placements,
      phase: TurnPhase.finished,
      clearDice: true,
      consecutiveSixes: 0,
    );
  }

  GameState _passTurn(GameState state, List<LudoEvent> events) {
    if (_matchShouldEnd(state)) {
      return _finishMatch(state, events);
    }
    var next = state.currentPlayer;
    for (var i = 0; i < state.players.length; i++) {
      next = (next + 1) % state.players.length;
      if (!state.isPlaced(next)) {
        break;
      }
    }
    events.add(LudoEvent(LudoEventType.turnPassed, player: next));
    return state.copyWith(
      currentPlayer: next,
      phase: TurnPhase.awaitingRoll,
      clearDice: true,
      consecutiveSixes: 0,
      turnNumber: state.turnNumber + 1,
    );
  }
}

import 'dart:math';

import '../games/ludo/engine/ludo_engine.dart';
import '../games/ludo/engine/ludo_track.dart';
import '../games/ludo/models/game_state.dart';
import '../games/ludo/models/ludo_constants.dart';
import '../games/ludo/models/ludo_move.dart';
import '../games/ludo/models/player_seat.dart';

/// Offline computer opponent for Classic Ludo.
///
/// The bot only ever picks from [LudoEngine.legalMoves], so it plays by
/// exactly the same rules as people do. It sees only what is on the board.
///
/// * Easy: a random legal move.
/// * Medium: simple priorities — finish, capture, enter, escape danger,
///   reach safety, avoid obvious danger, otherwise push the leading token.
/// * Hard: scores every legal move by progress, captures, safety, danger
///   before and after the move, home-column entry and follow-up capture
///   chances, then plays the best one.
class LudoBot {
  LudoBot({Random? random, LudoEngine engine = const LudoEngine()})
      : _random = random ?? Random(),
        _engine = engine;

  final Random _random;
  final LudoEngine _engine;

  /// The token the current seat should move. Throws [StateError] when the
  /// engine is not waiting for a move or no move is legal.
  int chooseToken(GameState state, BotDifficulty difficulty) {
    final moves = _engine.legalMoves(state);
    if (moves.isEmpty) {
      throw StateError('No legal move to choose from');
    }
    return chooseMove(state, moves, difficulty).token;
  }

  LudoMove chooseMove(
      GameState state, List<LudoMove> moves, BotDifficulty difficulty) {
    return switch (difficulty) {
      BotDifficulty.easy => moves[_random.nextInt(moves.length)],
      BotDifficulty.medium =>
        _best(moves, (move) => mediumScore(state, move)),
      BotDifficulty.hard => _best(moves, (move) => hardScore(state, move)),
    };
  }

  LudoMove _best(List<LudoMove> moves, double Function(LudoMove) score) {
    var bestScore = double.negativeInfinity;
    final best = <LudoMove>[];
    for (final move in moves) {
      final value = score(move);
      if (value > bestScore + 1e-9) {
        bestScore = value;
        best
          ..clear()
          ..add(move);
      } else if ((value - bestScore).abs() <= 1e-9) {
        best.add(move);
      }
    }
    return best[_random.nextInt(best.length)];
  }

  double mediumScore(GameState state, LudoMove move) {
    final player = move.player;
    var score = 0.0;
    if (move.finishesToken) {
      score += 100;
    }
    if (move.isCapture) {
      score += 80;
    }
    if (move.entersBoard) {
      score += 60;
    }
    final dangerBefore =
        move.entersBoard ? 0 : _engine.threatCount(state, player, move.from);
    final dangerAfter = _engine.threatCount(state, player, move.to);
    if (dangerBefore > 0 && dangerAfter == 0) {
      score += 40;
    }
    if (dangerAfter > 0) {
      score -= 50;
    }
    if (_landsSafe(state, move)) {
      score += 30;
    }
    score += move.to * 0.5;
    return score;
  }

  double hardScore(GameState state, LudoMove move) {
    final player = move.player;
    final after = _simulate(state, move);
    var score = 0.0;

    final gained = move.entersBoard ? 6 : move.to - move.from;
    score += gained.toDouble();
    if (move.entersBoard) {
      score += 14;
    }
    if (move.finishesToken) {
      score += 45;
    } else if (move.entersHomeColumn) {
      score += 16;
    }
    for (final victim in move.captures) {
      final victimProgress = state.tokens[victim.player][victim.token];
      score += 28 + victimProgress * 0.6;
    }
    if (!move.entersBoard) {
      final dangerBefore = _engine.threatCount(state, player, move.from);
      score += dangerBefore * (7 + move.from * 0.3);
    }
    final dangerAfter = _engine.threatCount(after, player, move.to);
    score -= dangerAfter * (9 + move.to * 0.35);
    if (_landsSafe(state, move) &&
        move.to <= LudoConstants.lastTrackProgress) {
      score += 5;
    }
    score += _captureChances(after, player, move.to) * 3;
    return score;
  }

  bool _landsSafe(GameState state, LudoMove move) {
    if (move.to > LudoConstants.lastTrackProgress) {
      return true;
    }
    final index =
        LudoTrack.absoluteIndex(state.players[move.player].color, move.to);
    return state.rules.safeSquaresEnabled &&
        index != null &&
        LudoTrack.isSafeIndex(index);
  }

  GameState _simulate(GameState state, LudoMove move) {
    final tokens = state.tokensCopy();
    tokens[move.player][move.token] = move.to;
    for (final victim in move.captures) {
      tokens[victim.player][victim.token] = LudoConstants.inBase;
    }
    return state.copyWith(tokens: tokens);
  }

  /// Opponent tokens that a token at [progress] could capture next turn.
  int _captureChances(GameState state, int player, int progress) {
    final from =
        LudoTrack.absoluteIndex(state.players[player].color, progress);
    if (from == null) {
      return 0;
    }
    var chances = 0;
    for (var other = 0; other < state.players.length; other++) {
      if (other == player) {
        continue;
      }
      final otherColor = state.players[other].color;
      for (final otherProgress in state.tokens[other]) {
        final target = LudoTrack.absoluteIndex(otherColor, otherProgress);
        if (target == null) {
          continue;
        }
        if (state.rules.safeSquaresEnabled && LudoTrack.isSafeIndex(target)) {
          continue;
        }
        final distance = (target - from) % LudoConstants.trackLength;
        if (distance >= 1 &&
            distance <= 6 &&
            progress + distance <= LudoConstants.lastTrackProgress) {
          chances++;
        }
      }
    }
    return chances;
  }
}

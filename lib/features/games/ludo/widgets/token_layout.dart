import 'dart:math' as math;

import '../controllers/ludo_match_controller.dart';
import '../engine/board_geometry.dart';
import '../models/game_state.dart';
import '../models/ludo_color.dart';
import '../models/ludo_constants.dart';
import '../models/ludo_move.dart';

/// Where and how one token is drawn in the current frame.
class TokenVisual {
  const TokenVisual({
    required this.ref,
    required this.color,
    required this.point,
    required this.scale,
    required this.lift,
    required this.movable,
    required this.inMotion,
  });

  final TokenRef ref;
  final LudoColor color;

  /// Ground position in board cells.
  final BoardPoint point;
  final double scale;

  /// Height above the ground in cells (hops and highlights).
  final double lift;
  final bool movable;
  final bool inMotion;
}

/// Computes token positions from the engine state plus the move currently
/// being animated. Shared by the painter and by tap hit-testing so both
/// always agree.
abstract final class TokenLayout {
  static List<TokenVisual> compute({
    required GameState state,
    required TokenAnimation? animation,
    required double progress,
    required Set<int> movableTokens,
    required double pulse,
  }) {
    final double travelFraction = animation?.travelFraction ?? 1.0;
    final double travelT = travelFraction <= 0
        ? 1.0
        : math.min(1.0, progress / travelFraction);
    final double returnT = travelFraction >= 1
        ? 1.0
        : ((progress - travelFraction) / (1 - travelFraction))
            .clamp(0.0, 1.0)
            .toDouble();

    final moving = <TokenVisual>[];
    final resting = <_Resting>[];

    for (var player = 0; player < state.playerCount; player++) {
      final color = state.players[player].color;
      for (var token = 0; token < LudoConstants.tokensPerPlayer; token++) {
        final ref = TokenRef(player, token);
        final progressValue = state.tokens[player][token];
        final movable =
            player == state.currentPlayer && movableTokens.contains(token);

        if (animation != null &&
            animation.player == player &&
            animation.token == token &&
            travelT < 1) {
          final hop = _alongPath(animation.path, travelT);
          moving.add(TokenVisual(
            ref: ref,
            color: color,
            point: hop.point,
            scale: 1,
            lift: hop.lift,
            movable: false,
            inMotion: true,
          ));
          continue;
        }

        CapturedToken? captured;
        if (animation != null) {
          for (final candidate in animation.captured) {
            if (candidate.player == player && candidate.token == token) {
              captured = candidate;
              break;
            }
          }
        }
        if (captured != null && returnT < 1) {
          final home = LudoBoardGeometry.baseSlot(color, token);
          final eased = _ease(returnT);
          moving.add(TokenVisual(
            ref: ref,
            color: color,
            point: captured.from.lerp(home, eased),
            scale: 1 - 0.15 * math.sin(math.pi * eased),
            lift: 0.35 * math.sin(math.pi * eased),
            movable: false,
            inMotion: returnT > 0,
          ));
          continue;
        }

        resting.add(_Resting(
          ref: ref,
          color: color,
          progress: progressValue,
          point: LudoBoardGeometry.tokenPoint(color, token, progressValue),
          movable: movable,
        ));
      }
    }

    final groups = <BoardPoint, List<_Resting>>{};
    for (final token in resting) {
      final onPath = token.progress > LudoConstants.inBase &&
          token.progress < LudoConstants.finishedProgress;
      if (onPath) {
        groups.putIfAbsent(token.point, () => <_Resting>[]).add(token);
      }
    }

    final visuals = <TokenVisual>[];
    for (final token in resting) {
      var point = token.point;
      var scale = 1.0;
      if (token.progress >= LudoConstants.finishedProgress) {
        scale = 0.6;
      }
      final group = groups[token.point];
      if (group != null && group.length > 1) {
        final offset = _stackOffset(group.indexOf(token), group.length);
        point = BoardPoint(point.x + offset.x, point.y + offset.y);
        scale = 0.74;
      }
      visuals.add(TokenVisual(
        ref: token.ref,
        color: token.color,
        point: point,
        scale: scale,
        lift: token.movable ? 0.05 + 0.07 * pulse : 0,
        movable: token.movable,
        inMotion: false,
      ));
    }

    visuals.sort((a, b) {
      if (a.movable != b.movable) {
        return a.movable ? 1 : -1;
      }
      return a.point.y.compareTo(b.point.y);
    });
    return <TokenVisual>[...visuals, ...moving];
  }

  static ({BoardPoint point, double lift}) _alongPath(
      List<BoardPoint> path, double t) {
    if (path.length < 2) {
      return (point: path.first, lift: 0.0);
    }
    final segments = path.length - 1;
    final position = t * segments;
    final index = math.min(position.floor(), segments - 1);
    final fraction = position - index;
    final eased = _ease(fraction);
    return (
      point: path[index].lerp(path[index + 1], eased),
      lift: 0.3 * math.sin(math.pi * fraction),
    );
  }

  static double _ease(double t) {
    if (t < 0.5) {
      return 2 * t * t;
    }
    final u = -2 * t + 2;
    return 1 - u * u / 2;
  }

  static BoardPoint _stackOffset(int index, int count) {
    const d = 0.19;
    if (count == 2) {
      return BoardPoint(index == 0 ? -d : d, 0);
    }
    if (count == 3) {
      const offsets = <BoardPoint>[
        BoardPoint(-d, d * 0.7),
        BoardPoint(d, d * 0.7),
        BoardPoint(0, -d),
      ];
      return offsets[index];
    }
    const offsets = <BoardPoint>[
      BoardPoint(-d, -d),
      BoardPoint(d, -d),
      BoardPoint(-d, d),
      BoardPoint(d, d),
    ];
    return index < offsets.length ? offsets[index] : const BoardPoint(0, 0);
  }
}

class _Resting {
  const _Resting({
    required this.ref,
    required this.color,
    required this.progress,
    required this.point,
    required this.movable,
  });

  final TokenRef ref;
  final LudoColor color;
  final int progress;
  final BoardPoint point;
  final bool movable;
}

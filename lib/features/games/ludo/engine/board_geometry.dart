import '../models/ludo_color.dart';
import '../models/ludo_constants.dart';

/// A point on the 15 x 15 board grid, measured in cells. Cell (row, col)
/// covers x in [col, col + 1) and y in [row, row + 1).
class BoardPoint {
  const BoardPoint(this.x, this.y);

  final double x;
  final double y;

  /// Rotates a quarter turn clockwise around the board centre.
  BoardPoint rotatedClockwise() =>
      BoardPoint(LudoBoardGeometry.gridSize - y, x);

  BoardPoint lerp(BoardPoint other, double t) =>
      BoardPoint(x + (other.x - x) * t, y + (other.y - y) * t);

  @override
  bool operator ==(Object other) =>
      other is BoardPoint &&
      (other.x - x).abs() < 1e-9 &&
      (other.y - y).abs() < 1e-9;

  @override
  int get hashCode => Object.hash((x * 1000).round(), (y * 1000).round());

  @override
  String toString() => 'BoardPoint($x, $y)';
}

/// Where everything sits on the drawn board. Pure Dart so it can be tested
/// without Flutter. Red occupies the top-left quadrant; every other colour
/// is red's layout rotated clockwise by its quadrant index.
abstract final class LudoBoardGeometry {
  static const int gridSize = 15;

  /// Red's share of the shared track as [row, col] cells, starting on red's
  /// start square and running clockwise.
  static const List<List<int>> _redTrackSegment = <List<int>>[
    <int>[6, 1],
    <int>[6, 2],
    <int>[6, 3],
    <int>[6, 4],
    <int>[6, 5],
    <int>[5, 6],
    <int>[4, 6],
    <int>[3, 6],
    <int>[2, 6],
    <int>[1, 6],
    <int>[0, 6],
    <int>[0, 7],
    <int>[0, 8],
  ];

  static const List<List<double>> _redBaseSlots = <List<double>>[
    <double>[2, 2],
    <double>[4, 2],
    <double>[2, 4],
    <double>[4, 4],
  ];

  static const List<List<double>> _redFinishSpots = <List<double>>[
    <double>[6.38, 7.08],
    <double>[6.38, 7.92],
    <double>[6.86, 7.3],
    <double>[6.86, 7.7],
  ];

  /// Centres of the 52 shared track squares, indexed by absolute track index.
  static final List<BoardPoint> track = _buildTrack();

  static List<BoardPoint> _buildTrack() {
    final points = <BoardPoint>[];
    for (var quadrant = 0; quadrant < LudoColor.values.length; quadrant++) {
      for (final cell in _redTrackSegment) {
        points.add(rotate(cellCenter(cell[0], cell[1]), quadrant));
      }
    }
    return List<BoardPoint>.unmodifiable(points);
  }

  static BoardPoint cellCenter(int row, int col) =>
      BoardPoint(col + 0.5, row + 0.5);

  static BoardPoint rotate(BoardPoint point, int quarterTurns) {
    var result = point;
    for (var i = 0; i < quarterTurns % 4; i++) {
      result = result.rotatedClockwise();
    }
    return result;
  }

  /// Centre of [color]'s home column square `step` (0..4, 0 nearest the edge).
  static BoardPoint homeColumn(LudoColor color, int step) =>
      rotate(cellCenter(7, 1 + step), color.index);

  /// Centre of [color]'s 6 x 6 base quadrant.
  static BoardPoint baseCenter(LudoColor color) =>
      rotate(const BoardPoint(3, 3), color.index);

  static BoardPoint baseSlot(LudoColor color, int token) {
    final slot = _redBaseSlots[token % _redBaseSlots.length];
    return rotate(BoardPoint(slot[0], slot[1]), color.index);
  }

  static BoardPoint finishSpot(LudoColor color, int token) {
    final spot = _redFinishSpots[token % _redFinishSpots.length];
    return rotate(BoardPoint(spot[0], spot[1]), color.index);
  }

  /// Where a token of [color] with [progress] is drawn.
  static BoardPoint tokenPoint(LudoColor color, int token, int progress) {
    if (progress <= LudoConstants.inBase) {
      return baseSlot(color, token);
    }
    if (progress >= LudoConstants.finishedProgress) {
      return finishSpot(color, token);
    }
    if (progress > LudoConstants.lastTrackProgress) {
      return homeColumn(
          color, progress - LudoConstants.lastTrackProgress - 1);
    }
    final index = (color.index * LudoConstants.seatOffset + progress) %
        LudoConstants.trackLength;
    return track[index];
  }

  /// Square-by-square path for an animated move, including the start point.
  static List<BoardPoint> movePath(
      LudoColor color, int token, int from, int to) {
    final path = <BoardPoint>[tokenPoint(color, token, from)];
    if (from <= LudoConstants.inBase) {
      path.add(tokenPoint(color, token, to));
      return path;
    }
    for (var progress = from + 1; progress <= to; progress++) {
      path.add(tokenPoint(color, token, progress));
    }
    return path;
  }
}

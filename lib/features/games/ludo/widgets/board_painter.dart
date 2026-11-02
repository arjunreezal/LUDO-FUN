import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../engine/board_geometry.dart';
import '../engine/ludo_track.dart';
import '../models/ludo_color.dart';
import '../models/ludo_constants.dart';

/// Paints the static Classic Ludo board: bases, track, safe squares, home
/// columns, entry arrows and the centre. Drawn entirely in Flutter so it
/// stays crisp at any size.
class LudoBoardPainter extends CustomPainter {
  const LudoBoardPainter({this.activeColors});

  /// Colours seated in this match. Unused bases are drawn faded. Null means
  /// every base is shown at full strength.
  final Set<LudoColor>? activeColors;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.shortestSide / LudoBoardGeometry.gridSize;
    final boardRect = Offset.zero & Size.square(cell * LudoBoardGeometry.gridSize);
    final corner = Radius.circular(cell * 0.7);
    final outline = RRect.fromRectAndRadius(boardRect, corner);

    canvas.save();
    canvas.clipRRect(outline);
    canvas.drawRect(boardRect, Paint()..color = LudoPalette.boardSurface);

    for (final color in LudoColor.values) {
      _paintBase(canvas, cell, color);
    }

    final linePaint = Paint()
      ..color = LudoPalette.boardLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, cell * 0.045);

    for (var index = 0; index < LudoConstants.trackLength; index++) {
      final rect = _cellRect(LudoBoardGeometry.track[index], cell);
      final owner = LudoTrack.startOwner(index);
      if (owner != null) {
        canvas.drawRect(rect, Paint()..color = _seatColor(owner));
        _paintStar(canvas, rect.center, cell * 0.3,
            Paint()..color = Colors.white.withValues(alpha: 0.9));
      } else if (LudoTrack.isSafeIndex(index)) {
        _paintStar(canvas, rect.center, cell * 0.32,
            Paint()..color = LudoPalette.boardStar);
      }
      canvas.drawRect(rect, linePaint);
    }

    for (final color in LudoColor.values) {
      final fill = Paint()..color = _seatColor(color);
      for (var step = 0; step < LudoConstants.homeColumnLength; step++) {
        final rect = _cellRect(LudoBoardGeometry.homeColumn(color, step), cell);
        canvas.drawRect(rect, fill);
        canvas.drawRect(rect, linePaint);
      }
      _paintEntryArrow(canvas, cell, color);
    }

    _paintCentre(canvas, cell);
    canvas.restore();

    canvas.drawRRect(
      outline.deflate(cell * 0.02),
      Paint()
        ..color = LudoPalette.boardInk.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.0, cell * 0.06),
    );
  }

  bool _isActive(LudoColor color) =>
      activeColors == null || activeColors!.contains(color);

  Color _seatColor(LudoColor color) {
    final base = LudoPalette.seat(color);
    return _isActive(color)
        ? base
        : Color.lerp(base, LudoPalette.boardSurface, 0.62) ?? base;
  }

  Rect _cellRect(BoardPoint point, double cell) => Rect.fromCenter(
        center: Offset(point.x * cell, point.y * cell),
        width: cell,
        height: cell,
      );

  void _paintBase(Canvas canvas, double cell, LudoColor color) {
    final centre = LudoBoardGeometry.baseCenter(color);
    final quadrant = Rect.fromCenter(
      center: Offset(centre.x * cell, centre.y * cell),
      width: cell * 6,
      height: cell * 6,
    );
    final seatColor = _seatColor(color);
    canvas.drawRect(quadrant, Paint()..color = seatColor);
    final inner = RRect.fromRectAndRadius(
        quadrant.deflate(cell * 0.9), Radius.circular(cell * 0.8));
    canvas.drawRRect(inner, Paint()..color = LudoPalette.boardSurface);

    final slotFill = Paint()..color = seatColor.withValues(alpha: 0.2);
    final slotRing = Paint()
      ..color = seatColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, cell * 0.08);
    for (var token = 0; token < LudoConstants.tokensPerPlayer; token++) {
      final slot = LudoBoardGeometry.baseSlot(color, token);
      final center = Offset(slot.x * cell, slot.y * cell);
      canvas.drawCircle(center, cell * 0.62, slotFill);
      canvas.drawCircle(center, cell * 0.62, slotRing);
    }
  }

  void _paintEntryArrow(Canvas canvas, double cell, LudoColor color) {
    final entryIndex =
        (LudoTrack.startIndex(color) + LudoConstants.lastTrackProgress) %
            LudoConstants.trackLength;
    final entry = LudoBoardGeometry.track[entryIndex];
    final firstHome = LudoBoardGeometry.homeColumn(color, 0);
    final dx = firstHome.x - entry.x;
    final dy = firstHome.y - entry.y;
    final angle = math.atan2(dy, dx);
    final centre = Offset(entry.x * cell, entry.y * cell);
    final arrow = Path()
      ..moveTo(cell * 0.28, 0)
      ..lineTo(-cell * 0.16, -cell * 0.24)
      ..lineTo(-cell * 0.16, cell * 0.24)
      ..close();
    canvas.save();
    canvas.translate(centre.dx, centre.dy);
    canvas.rotate(angle);
    canvas.drawPath(arrow, Paint()..color = _seatColor(color));
    canvas.restore();
  }

  void _paintCentre(Canvas canvas, double cell) {
    const apex = BoardPoint(7.5, 7.5);
    for (final color in LudoColor.values) {
      final a = LudoBoardGeometry.rotate(const BoardPoint(6, 6), color.index);
      final b = LudoBoardGeometry.rotate(const BoardPoint(6, 9), color.index);
      final path = Path()
        ..moveTo(a.x * cell, a.y * cell)
        ..lineTo(b.x * cell, b.y * cell)
        ..lineTo(apex.x * cell, apex.y * cell)
        ..close();
      canvas.drawPath(path, Paint()..color = _seatColor(color));
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1.0, cell * 0.06)
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  static void _paintStar(Canvas canvas, Offset centre, double radius, Paint paint) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final r = i.isEven ? radius : radius * 0.45;
      final angle = -math.pi / 2 + i * math.pi / 5;
      final point = centre + Offset(math.cos(angle) * r, math.sin(angle) * r);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(LudoBoardPainter oldDelegate) =>
      !_sameColors(oldDelegate.activeColors, activeColors);

  static bool _sameColors(Set<LudoColor>? a, Set<LudoColor>? b) {
    if (a == null || b == null) {
      return a == b;
    }
    return a.length == b.length && a.containsAll(b);
  }
}

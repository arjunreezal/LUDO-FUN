import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../ludo/widgets/ludo_board_view.dart';
import 'game_catalog.dart';

/// Original, Flutter-drawn artwork for each game tile.
class GameArt extends StatelessWidget {
  const GameArt({super.key, required this.game, this.size = 72});

  final GameId game;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (game == GameId.classicLudo) {
      return LudoBoardArt(size: size);
    }
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _GameArtPainter(game)),
    );
  }
}

class _GameArtPainter extends CustomPainter {
  const _GameArtPainter(this.game);

  final GameId game;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final tile = RRect.fromRectAndRadius(
        Offset.zero & Size.square(s), Radius.circular(s * 0.22));
    canvas.drawRRect(tile, Paint()..color = game.accent.withValues(alpha: 0.18));
    canvas.save();
    canvas.clipRRect(tile);
    switch (game) {
      case GameId.snakeLudo:
        _snake(canvas, s);
      case GameId.chess:
        _chess(canvas, s);
      case GameId.callBreak:
        _cards(canvas, s, count: 3, pip: LudoPalette.boardInk, pips: 1);
      case GameId.teenPatti:
        _cards(canvas, s, count: 3, pip: LudoPalette.red, pips: 3);
      case GameId.marriage:
        _cards(canvas, s, count: 5, pip: const Color(0xFFFF8A5B), pips: 2);
      case GameId.classicLudo:
        break;
    }
    canvas.restore();
  }

  void _snake(Canvas canvas, double s) {
    final cell = s / 4;
    for (var row = 0; row < 4; row++) {
      for (var col = 0; col < 4; col++) {
        if ((row + col).isEven) {
          canvas.drawRect(
            Rect.fromLTWH(col * cell, row * cell, cell, cell),
            Paint()..color = Colors.white.withValues(alpha: 0.12),
          );
        }
      }
    }
    final path = Path()
      ..moveTo(s * 0.2, s * 0.85)
      ..cubicTo(s * 0.05, s * 0.55, s * 0.6, s * 0.7, s * 0.5, s * 0.45)
      ..cubicTo(s * 0.4, s * 0.2, s * 0.85, s * 0.35, s * 0.78, s * 0.16);
    canvas.drawPath(
      path,
      Paint()
        ..color = LudoPalette.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.11
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(Offset(s * 0.78, s * 0.16), s * 0.085,
        Paint()..color = LudoPalette.green);
    canvas.drawCircle(Offset(s * 0.8, s * 0.14), s * 0.022,
        Paint()..color = LudoPalette.boardInk);
  }

  void _chess(Canvas canvas, double s) {
    final cell = s / 4;
    for (var row = 0; row < 4; row++) {
      for (var col = 0; col < 4; col++) {
        canvas.drawRect(
          Rect.fromLTWH(col * cell, row * cell, cell, cell),
          Paint()
            ..color = (row + col).isEven
                ? LudoPalette.boardSurface
                : LudoPalette.blue.withValues(alpha: 0.75),
        );
      }
    }
    final ink = Paint()..color = LudoPalette.boardInk;
    final cx = s * 0.5;
    canvas.drawCircle(Offset(cx, s * 0.33), s * 0.095, ink);
    final body = Path()
      ..moveTo(cx - s * 0.07, s * 0.42)
      ..lineTo(cx + s * 0.07, s * 0.42)
      ..lineTo(cx + s * 0.13, s * 0.7)
      ..lineTo(cx - s * 0.13, s * 0.7)
      ..close();
    canvas.drawPath(body, ink);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx, s * 0.74), width: s * 0.36, height: s * 0.08),
        Radius.circular(s * 0.03),
      ),
      ink,
    );
  }

  void _cards(Canvas canvas, double s,
      {required int count, required Color pip, required int pips}) {
    final width = s * 0.42;
    final height = s * 0.6;
    final pivot = Offset(s * 0.5, s * 0.92);
    final spread = count == 3 ? 0.42 : 0.3;
    for (var i = 0; i < count; i++) {
      final angle = (i - (count - 1) / 2) * spread;
      canvas.save();
      canvas.translate(pivot.dx, pivot.dy);
      canvas.rotate(angle);
      final card = RRect.fromRectAndRadius(
        Rect.fromLTWH(-width / 2, -height - s * 0.1, width, height),
        Radius.circular(s * 0.05),
      );
      canvas.drawRRect(card, Paint()..color = LudoPalette.boardSurface);
      canvas.drawRRect(
        card,
        Paint()
          ..color = LudoPalette.boardInk.withValues(alpha: 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.012,
      );
      final centre = card.outerRect.center;
      for (var p = 0; p < pips; p++) {
        final dy = (p - (pips - 1) / 2) * s * 0.13;
        _diamond(canvas, centre.translate(0, dy), s * 0.055, pip);
      }
      canvas.restore();
    }
  }

  void _diamond(Canvas canvas, Offset centre, double r, Color color) {
    final path = Path();
    for (var i = 0; i < 4; i++) {
      final angle = i * math.pi / 2;
      final point = centre + Offset(math.sin(angle) * r * 0.8, -math.cos(angle) * r);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_GameArtPainter oldDelegate) => oldDelegate.game != game;
}

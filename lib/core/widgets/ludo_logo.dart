import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../features/games/ludo/models/ludo_color.dart';

/// The LUDO mark: the board's centre pinwheel inside a rounded tile.
/// [progress] (0 to 1) assembles the four triangles for the launch animation.
class LudoLogoMark extends StatelessWidget {
  const LudoLogoMark({super.key, this.size = 72, this.progress = 1});

  final double size;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _LogoPainter(progress)),
    );
  }
}

class _LogoPainter extends CustomPainter {
  const _LogoPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final tile = RRect.fromRectAndRadius(
        Offset.zero & Size.square(s), Radius.circular(s * 0.26));
    canvas.drawRRect(tile, Paint()..color = LudoPalette.boardSurface);

    final inset = s * 0.17;
    final inner = Rect.fromLTWH(inset, inset, s - inset * 2, s - inset * 2);
    final centre = inner.center;
    // Triangle order matches the board: red left, green top, yellow right,
    // blue bottom.
    final corners = <List<Offset>>[
      <Offset>[inner.topLeft, inner.bottomLeft],
      <Offset>[inner.topRight, inner.topLeft],
      <Offset>[inner.bottomRight, inner.topRight],
      <Offset>[inner.bottomLeft, inner.bottomRight],
    ];
    for (var i = 0; i < LudoColor.values.length; i++) {
      final local = ((progress - i * 0.12) / 0.64).clamp(0.0, 1.0).toDouble();
      if (local <= 0) {
        continue;
      }
      final eased = Curves.easeOutBack.transform(local);
      final outward = Offset(
            (corners[i][0].dx + corners[i][1].dx) / 2 - centre.dx,
            (corners[i][0].dy + corners[i][1].dy) / 2 - centre.dy,
          ) *
          (1 - eased) *
          0.6;
      final path = Path()
        ..moveTo(corners[i][0].dx + outward.dx, corners[i][0].dy + outward.dy)
        ..lineTo(corners[i][1].dx + outward.dx, corners[i][1].dy + outward.dy)
        ..lineTo(centre.dx + outward.dx, centre.dy + outward.dy)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..color = LudoPalette.seat(LudoColor.values[i])
              .withValues(alpha: math.min(1.0, local * 1.4)),
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = LudoPalette.boardSurface
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.035
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  @override
  bool shouldRepaint(_LogoPainter oldDelegate) => oldDelegate.progress != progress;
}

/// The LUDO wordmark set in heavy, widely spaced type.
class LudoWordmark extends StatelessWidget {
  const LudoWordmark({super.key, this.fontSize = 34, this.color});

  final double fontSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      'LUDO',
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        letterSpacing: fontSize * 0.22,
        height: 1,
        color: color ?? Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

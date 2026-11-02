import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

/// A six-sided die drawn in Flutter. Shows a tumbling face while [rolling]
/// and the engine's result otherwise. Disabled when it is not a person's
/// turn to roll.
class LudoDice extends StatefulWidget {
  const LudoDice({
    super.key,
    required this.value,
    required this.rolling,
    required this.enabled,
    required this.accent,
    required this.onRoll,
    required this.reduceMotion,
    required this.semanticLabel,
    this.size = 76,
  });

  final int? value;
  final bool rolling;
  final bool enabled;
  final Color accent;
  final VoidCallback onRoll;
  final bool reduceMotion;
  final String semanticLabel;
  final double size;

  @override
  State<LudoDice> createState() => _LudoDiceState();
}

class _LudoDiceState extends State<LudoDice> with SingleTickerProviderStateMixin {
  late final AnimationController _tumble = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 420));

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(LudoDice oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rolling != widget.rolling ||
        oldWidget.reduceMotion != widget.reduceMotion) {
      _sync();
    }
  }

  void _sync() {
    if (widget.rolling && !widget.reduceMotion) {
      _tumble.repeat();
    } else {
      _tumble.stop();
      _tumble.value = 0;
    }
  }

  @override
  void dispose() {
    _tumble.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled && !widget.rolling;
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        onTap: enabled ? widget.onRoll : null,
        child: AnimatedScale(
          scale: widget.rolling ? 0.94 : 1,
          duration: const Duration(milliseconds: 160),
          child: AnimatedOpacity(
            opacity: widget.enabled || widget.rolling ? 1 : 0.6,
            duration: const Duration(milliseconds: 200),
            child: AnimatedBuilder(
              animation: _tumble,
              builder: (context, child) {
                final t = _tumble.value;
                final tumbling = widget.rolling && !widget.reduceMotion;
                final face = tumbling
                    ? 1 + (t * 18).floor() % 6
                    : (widget.value ?? 6);
                return Transform.rotate(
                  angle: tumbling ? math.sin(t * math.pi * 2) * 0.45 : 0,
                  child: CustomPaint(
                    size: Size.square(widget.size),
                    painter: _DicePainter(
                      face: face,
                      accent: widget.accent,
                      glowing: enabled,
                      blank: widget.value == null && !widget.rolling,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _DicePainter extends CustomPainter {
  const _DicePainter({
    required this.face,
    required this.accent,
    required this.glowing,
    required this.blank,
  });

  final int face;
  final Color accent;
  final bool glowing;
  final bool blank;

  static const Map<int, List<Offset>> _pips = <int, List<Offset>>{
    1: <Offset>[Offset(0.5, 0.5)],
    2: <Offset>[Offset(0.28, 0.28), Offset(0.72, 0.72)],
    3: <Offset>[Offset(0.27, 0.27), Offset(0.5, 0.5), Offset(0.73, 0.73)],
    4: <Offset>[
      Offset(0.28, 0.28),
      Offset(0.72, 0.28),
      Offset(0.28, 0.72),
      Offset(0.72, 0.72),
    ],
    5: <Offset>[
      Offset(0.27, 0.27),
      Offset(0.73, 0.27),
      Offset(0.5, 0.5),
      Offset(0.27, 0.73),
      Offset(0.73, 0.73),
    ],
    6: <Offset>[
      Offset(0.28, 0.25),
      Offset(0.72, 0.25),
      Offset(0.28, 0.5),
      Offset(0.72, 0.5),
      Offset(0.28, 0.75),
      Offset(0.72, 0.75),
    ],
  };

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    final rect = Offset.zero & Size.square(side);
    final body = RRect.fromRectAndRadius(
        rect.deflate(side * 0.06), Radius.circular(side * 0.22));

    if (glowing) {
      canvas.drawRRect(
        body.inflate(side * 0.02),
        Paint()
          ..color = accent.withValues(alpha: 0.55)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, side * 0.08),
      );
    }
    canvas.drawRRect(
      body.shift(Offset(0, side * 0.04)),
      Paint()..color = Colors.black.withValues(alpha: 0.25),
    );
    canvas.drawRRect(body, Paint()..color = LudoPalette.boardSurface);
    canvas.drawRRect(
      body,
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = side * 0.055,
    );
    if (blank) {
      return;
    }
    final pipPaint = Paint()..color = LudoPalette.boardInk;
    final inner = body.outerRect;
    for (final pip in _pips[face] ?? const <Offset>[]) {
      canvas.drawCircle(
        Offset(inner.left + pip.dx * inner.width, inner.top + pip.dy * inner.height),
        side * 0.072,
        pipPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_DicePainter oldDelegate) =>
      oldDelegate.face != face ||
      oldDelegate.accent != accent ||
      oldDelegate.glowing != glowing ||
      oldDelegate.blank != blank;
}

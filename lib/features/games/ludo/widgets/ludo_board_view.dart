import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../controllers/ludo_match_controller.dart';
import '../engine/board_geometry.dart';
import '../models/game_state.dart';
import '../models/ludo_color.dart';
import '../models/ludo_move.dart';
import 'board_painter.dart';
import 'token_layout.dart';

/// The interactive board: static board layer, animated tokens, legal-move
/// highlights and token taps. It only draws [state]; it never changes it.
class LudoBoardView extends StatefulWidget {
  const LudoBoardView({
    super.key,
    required this.state,
    required this.animation,
    required this.movableTokens,
    required this.onTokenTap,
    required this.reduceMotion,
    required this.semanticLabel,
  });

  final GameState state;
  final TokenAnimation? animation;
  final Set<int> movableTokens;
  final ValueChanged<int> onTokenTap;
  final bool reduceMotion;
  final String semanticLabel;

  @override
  State<LudoBoardView> createState() => _LudoBoardViewState();
}

class _LudoBoardViewState extends State<LudoBoardView>
    with TickerProviderStateMixin {
  late final AnimationController _move =
      AnimationController(vsync: this, value: 1);
  late final AnimationController _pulse = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1100));

  @override
  void initState() {
    super.initState();
    _syncMove(null);
    _syncPulse();
  }

  @override
  void didUpdateWidget(LudoBoardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncMove(oldWidget.animation);
    _syncPulse();
  }

  void _syncMove(TokenAnimation? previous) {
    final animation = widget.animation;
    if (animation == null) {
      _move.value = 1;
      return;
    }
    if (previous != null && previous.id == animation.id) {
      return;
    }
    if (animation.total <= Duration.zero) {
      _move.value = 1;
      return;
    }
    _move.duration = animation.total;
    _move.forward(from: 0);
  }

  void _syncPulse() {
    final wantsPulse = widget.movableTokens.isNotEmpty;
    if (wantsPulse && !widget.reduceMotion) {
      if (!_pulse.isAnimating) {
        _pulse.repeat(reverse: true);
      }
    } else {
      _pulse.stop();
      _pulse.value = wantsPulse ? 1 : 0;
    }
  }

  @override
  void dispose() {
    _move.dispose();
    _pulse.dispose();
    super.dispose();
  }

  void _handleTap(Offset position, double side) {
    if (widget.movableTokens.isEmpty) {
      return;
    }
    final cell = side / LudoBoardGeometry.gridSize;
    final tap = BoardPoint(position.dx / cell, position.dy / cell);
    final visuals = TokenLayout.compute(
      state: widget.state,
      animation: widget.animation,
      progress: _move.value,
      movableTokens: widget.movableTokens,
      pulse: _pulse.value,
    );
    int? best;
    var bestDistance = double.infinity;
    for (final visual in visuals) {
      if (!visual.movable) {
        continue;
      }
      final dx = visual.point.x - tap.x;
      final dy = visual.point.y - tap.y;
      final distance = math.sqrt(dx * dx + dy * dy);
      if (distance < bestDistance) {
        bestDistance = distance;
        best = visual.ref.token;
      }
    }
    if (best != null && bestDistance <= 1.0) {
      widget.onTokenTap(best);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeColors =
        widget.state.players.map((seat) => seat.color).toSet();
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = math.min(constraints.maxWidth, constraints.maxHeight);
        return Semantics(
          label: widget.semanticLabel,
          child: SizedBox.square(
            dimension: side,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) => _handleTap(details.localPosition, side),
              child: Stack(
                children: <Widget>[
                  RepaintBoundary(
                    child: CustomPaint(
                      size: Size.square(side),
                      painter: LudoBoardPainter(activeColors: activeColors),
                    ),
                  ),
                  CustomPaint(
                    size: Size.square(side),
                    painter: _TokenPainter(
                      state: widget.state,
                      animation: widget.animation,
                      movableTokens: widget.movableTokens,
                      move: _move,
                      pulse: _pulse,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TokenPainter extends CustomPainter {
  _TokenPainter({
    required this.state,
    required this.animation,
    required this.movableTokens,
    required this.move,
    required this.pulse,
  }) : super(repaint: Listenable.merge(<Listenable>[move, pulse]));

  final GameState state;
  final TokenAnimation? animation;
  final Set<int> movableTokens;
  final Animation<double> move;
  final Animation<double> pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.shortestSide / LudoBoardGeometry.gridSize;
    final visuals = TokenLayout.compute(
      state: state,
      animation: animation,
      progress: move.value,
      movableTokens: movableTokens,
      pulse: pulse.value,
    );
    for (final visual in visuals) {
      paintToken(canvas, cell, visual, pulse.value);
    }
  }

  @override
  bool shouldRepaint(_TokenPainter oldDelegate) =>
      oldDelegate.state != state ||
      oldDelegate.animation != animation ||
      !_sameSet(oldDelegate.movableTokens, movableTokens);

  static bool _sameSet(Set<int> a, Set<int> b) =>
      a.length == b.length && a.containsAll(b);
}

/// Draws one token. Also used by the static board artwork.
void paintToken(Canvas canvas, double cell, TokenVisual visual, double pulse) {
  final radius = cell * 0.36 * visual.scale;
  final ground = Offset(visual.point.x * cell, visual.point.y * cell);
  final centre = ground.translate(0, -visual.lift * cell);
  final seat = LudoPalette.seat(visual.color);

  final shadowScale = 1 - math.min(0.4, visual.lift);
  canvas.drawOval(
    Rect.fromCenter(
      center: ground.translate(0, radius * 0.55),
      width: radius * 1.9 * shadowScale,
      height: radius * 0.75 * shadowScale,
    ),
    Paint()..color = Colors.black.withValues(alpha: 0.22 * shadowScale),
  );

  if (visual.movable) {
    final ringRadius = radius * (1.32 + 0.12 * pulse);
    canvas.drawCircle(
      centre,
      ringRadius,
      Paint()
        ..color = LudoPalette.boardInk.withValues(alpha: 0.55 + 0.35 * pulse)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.5, radius * 0.16),
    );
  }

  canvas.drawCircle(centre, radius, Paint()..color = Colors.white);
  canvas.drawCircle(
    centre,
    radius,
    Paint()
      ..color = LudoPalette.boardInk.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, radius * 0.08),
  );
  final inner = radius * 0.74;
  final highlight = Color.lerp(seat, Colors.white, 0.35) ?? seat;
  canvas.drawCircle(
    centre,
    inner,
    Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.4),
        radius: 1.0,
        colors: <Color>[highlight, seat],
      ).createShader(Rect.fromCircle(center: centre, radius: inner)),
  );
  canvas.drawCircle(
    centre.translate(-inner * 0.28, -inner * 0.32),
    inner * 0.22,
    Paint()..color = Colors.white.withValues(alpha: 0.45),
  );
}

/// A static, non-interactive board with a few tokens, used as artwork on the
/// home and games screens.
class LudoBoardArt extends StatelessWidget {
  const LudoBoardArt({super.key, this.size = 160});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: const LudoBoardPainter(),
        foregroundPainter: _ArtTokensPainter(),
      ),
    );
  }
}

class _ArtTokensPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.shortestSide / LudoBoardGeometry.gridSize;
    const sample = <(LudoColor, int, int)>[
      (LudoColor.red, 0, 4),
      (LudoColor.red, 1, -1),
      (LudoColor.red, 2, -1),
      (LudoColor.green, 0, 9),
      (LudoColor.green, 1, -1),
      (LudoColor.yellow, 0, 52),
      (LudoColor.yellow, 1, -1),
      (LudoColor.yellow, 2, -1),
      (LudoColor.blue, 0, 20),
      (LudoColor.blue, 1, -1),
      (LudoColor.blue, 2, -1),
      (LudoColor.blue, 3, -1),
    ];
    for (final (color, token, progress) in sample) {
      paintToken(
        canvas,
        cell,
        TokenVisual(
          ref: TokenRef(color.index, token),
          color: color,
          point: LudoBoardGeometry.tokenPoint(color, token, progress),
          scale: 1,
          lift: 0,
          movable: false,
          inMotion: false,
        ),
        0,
      );
    }
  }

  @override
  bool shouldRepaint(_ArtTokensPainter oldDelegate) => false;
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/app_scope.dart';
import '../../../../app/router.dart';
import '../../../../app/theme.dart';
import '../../../../core/widgets/common.dart';
import '../../../game_setup/setup_memory.dart';
import '../models/ludo_constants.dart';
import '../models/match_summary.dart';

class LudoResultsScreen extends StatefulWidget {
  const LudoResultsScreen({super.key, required this.summary});

  final MatchSummary summary;

  @override
  State<LudoResultsScreen> createState() => _LudoResultsScreenState();
}

class _LudoResultsScreenState extends State<LudoResultsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _celebration = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2600));
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }
    _started = true;
    if (context.reduceMotion) {
      _celebration.value = 1;
    } else {
      _celebration.forward();
    }
  }

  @override
  void dispose() {
    _celebration.dispose();
    super.dispose();
  }

  void _playAgain() {
    final services = context.services;
    final setup = SeatPlanner.refreshNames(
      widget.summary.setup,
      yourName: services.profile.displayName,
      strings: context.strings,
    );
    Navigator.of(context).pushReplacementNamed(AppRoutes.match, arguments: setup);
  }

  void _newGame() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.setup,
        arguments: widget.summary.setup.mode);
  }

  void _home() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.strings;
    final theme = Theme.of(context);
    final summary = widget.summary;
    final local = summary.localSeat;
    final winner = summary.winner;
    final winnerColor = LudoPalette.seat(winner.color);
    final youWon = local != null && summary.placementOf(local) == 1;
    final headline = youWon
        ? l10n.youWon
        : (summary.setup.humanCount == 1 && local != null
            ? l10n.youPlaced(l10n.placement(summary.placementOf(local)))
            : l10n.playerWins(winner.name));

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _celebration,
                builder: (context, _) => CustomPaint(
                  painter: _ConfettiPainter(
                    progress: _celebration.value,
                    active: youWon || summary.setup.humanCount > 1,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: ContentWidth(
              maxWidth: 560,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
                children: <Widget>[
                  Center(
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: winnerColor.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                        border: Border.all(color: winnerColor, width: 3),
                      ),
                      child: Icon(Icons.emoji_events_rounded,
                          size: 48, color: winnerColor),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(headline,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 6),
                  Text(
                    l10n.matchTime(formatDuration(summary.duration)),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  SectionTitle(l10n.finalStandings),
                  Panel(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      children: <Widget>[
                        for (var place = 0;
                            place < summary.placements.length;
                            place++)
                          _StandingRow(
                            place: place + 1,
                            summary: summary,
                            seatIndex: summary.placements[place],
                          ),
                      ],
                    ),
                  ),
                  if (local != null) ...<Widget>[
                    SectionTitle(l10n.yourRecord),
                    Panel(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: StatTile(
                              value: '${summary.captures[local]}',
                              label: l10n.statCaptures,
                            ),
                          ),
                          Expanded(
                            child: StatTile(
                              value: '${summary.tokensLost[local]}',
                              label: l10n.statTokensLost,
                            ),
                          ),
                          Expanded(
                            child: StatTile(
                              value: '${summary.turns}',
                              label: l10n.statTurns,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: _playAgain,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(l10n.playAgain),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _newGame,
                    child: Text(l10n.newGame),
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: _home,
                    child: Text(l10n.backHome),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StandingRow extends StatelessWidget {
  const _StandingRow({
    required this.place,
    required this.summary,
    required this.seatIndex,
  });

  final int place;
  final MatchSummary summary;
  final int seatIndex;

  @override
  Widget build(BuildContext context) {
    final l10n = context.strings;
    final theme = Theme.of(context);
    final seat = summary.players[seatIndex];
    final home = summary.finishedTokens[seatIndex];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 44,
            child: Text(l10n.placement(place),
                style: theme.textTheme.titleMedium),
          ),
          PlayerAvatar(
            name: seat.name,
            color: LudoPalette.seat(seat.color),
            size: 36,
            icon: seat.isComputer ? Icons.smart_toy_rounded : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(seat.name,
                    style: theme.textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(
                  home == LudoConstants.tokensPerPlayer
                      ? l10n.allTokensHome
                      : l10n.tokensHomeLong(home),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Falling confetti in the four seat colours. Deterministic so it can be
/// replayed and costs nothing when [progress] is complete.
class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress, required this.active});

  final double progress;
  final bool active;

  static final List<_Piece> _pieces = _buildPieces();

  static List<_Piece> _buildPieces() {
    final random = math.Random(7);
    const colors = <Color>[
      LudoPalette.red,
      LudoPalette.green,
      LudoPalette.yellow,
      LudoPalette.blue,
      LudoPalette.purple,
    ];
    return <_Piece>[
      for (var i = 0; i < 70; i++)
        _Piece(
          x: random.nextDouble(),
          delay: random.nextDouble() * 0.35,
          speed: 0.7 + random.nextDouble() * 0.6,
          drift: (random.nextDouble() - 0.5) * 0.25,
          spin: random.nextDouble() * math.pi * 4,
          size: 6 + random.nextDouble() * 6,
          color: colors[i % colors.length],
        ),
    ];
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (!active || progress <= 0 || progress >= 1) {
      return;
    }
    for (final piece in _pieces) {
      final t = ((progress - piece.delay) / (1 - piece.delay))
          .clamp(0.0, 1.0)
          .toDouble();
      if (t <= 0) {
        continue;
      }
      final y = -20 + t * piece.speed * (size.height + 40);
      final x = (piece.x + piece.drift * t) * size.width +
          math.sin(t * math.pi * 3 + piece.spin) * 12;
      final opacity = t > 0.8 ? (1 - t) / 0.2 : 1.0;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(piece.spin * t);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset.zero, width: piece.size, height: piece.size * 0.55),
          const Radius.circular(1.5),
        ),
        Paint()..color = piece.color.withValues(alpha: opacity.toDouble()),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.active != active;
}

class _Piece {
  const _Piece({
    required this.x,
    required this.delay,
    required this.speed,
    required this.drift,
    required this.spin,
    required this.size,
    required this.color,
  });

  final double x;
  final double delay;
  final double speed;
  final double drift;
  final double spin;
  final double size;
  final Color color;
}

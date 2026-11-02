import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../bots/ludo_bot.dart';
import '../engine/board_geometry.dart';
import '../engine/dice.dart';
import '../engine/ludo_engine.dart';
import '../models/game_state.dart';
import '../models/ludo_event.dart';
import '../models/ludo_move.dart';
import '../models/match_setup.dart';
import '../models/match_summary.dart';
import 'match_timing.dart';

/// A token captured by the move being animated.
class CapturedToken {
  const CapturedToken({
    required this.player,
    required this.token,
    required this.from,
  });

  final int player;
  final int token;

  /// Where the token stood before it was captured.
  final BoardPoint from;
}

/// Describes the move currently being animated on the board. The engine
/// state has already been updated; this only tells the board how to draw
/// the transition.
class TokenAnimation {
  const TokenAnimation({
    required this.id,
    required this.player,
    required this.token,
    required this.path,
    required this.travel,
    required this.captured,
    required this.captureReturn,
  });

  final int id;
  final int player;
  final int token;
  final List<BoardPoint> path;
  final Duration travel;
  final List<CapturedToken> captured;
  final Duration captureReturn;

  Duration get total =>
      travel + (captured.isEmpty ? Duration.zero : captureReturn);

  /// Share of [total] spent travelling, from 0 to 1.
  double get travelFraction {
    final totalMs = total.inMicroseconds;
    if (totalMs <= 0) {
      return 1;
    }
    return travel.inMicroseconds / totalMs;
  }
}

/// Runs one offline Classic Ludo match: asks the engine for every rule
/// decision, drives computer seats, and paces the match so animations finish
/// before the next action. The board always renders [state], which is the
/// engine's state.
class LudoMatchController extends ChangeNotifier {
  LudoMatchController({
    required this.setup,
    required MatchTiming timing,
    this.autoMoveSingleOption = true,
    DiceRoller? dice,
    LudoBot? bot,
    LudoEngine engine = const LudoEngine(),
    DateTime Function()? clock,
  })  : _timing = timing,
        _dice = dice ?? DiceRoller(),
        _bot = bot ?? LudoBot(),
        _engine = engine,
        _clock = clock ?? DateTime.now {
    _state = _engine.newGame(players: setup.players, rules: setup.rules);
    _startedAt = _clock();
  }

  final MatchSetup setup;
  final DiceRoller _dice;
  final LudoBot _bot;
  final LudoEngine _engine;
  final DateTime Function() _clock;
  final MatchTiming _timing;
  bool autoMoveSingleOption;

  /// Called with the events of every engine action (for sound, haptics and
  /// notices).
  void Function(List<LudoEvent> events)? onEvents;

  /// Called when a roll starts, before the result is known.
  VoidCallback? onRollStarted;

  /// Called once when the match finishes.
  VoidCallback? onFinished;

  late GameState _state;
  late DateTime _startedAt;
  DateTime? _finishedAt;
  int? _lastRoll;
  bool _rolling = false;
  TokenAnimation? _animation;
  int _animationSeq = 0;
  int _generation = 0;
  bool _driving = false;
  bool _disposed = false;
  bool _finishAnnounced = false;
  final List<LudoEvent> _log = <LudoEvent>[];
  final Map<int, int> _captures = <int, int>{};
  final Map<int, int> _losses = <int, int>{};
  final Set<Timer> _timers = <Timer>{};
  final Set<Completer<void>> _pending = <Completer<void>>{};

  static const int _maxLog = 120;

  GameState get state => _state;
  int? get lastRoll => _lastRoll;
  bool get isRolling => _rolling;
  TokenAnimation? get animation => _animation;
  bool get isBusy => _rolling || _animation != null;
  List<LudoEvent> get log => List<LudoEvent>.unmodifiable(_log);
  Duration get elapsed => (_finishedAt ?? _clock()).difference(_startedAt);
  int capturesBy(int player) => _captures[player] ?? 0;
  int tokensLostBy(int player) => _losses[player] ?? 0;

  /// True when a person at this device may roll right now.
  bool get canRoll =>
      !_disposed &&
      !isBusy &&
      _state.phase == TurnPhase.awaitingRoll &&
      _state.currentSeat.isHuman;

  /// Tokens the person at this device may move right now.
  Set<int> get movableTokens {
    if (_disposed ||
        isBusy ||
        _state.phase != TurnPhase.awaitingMove ||
        _state.currentSeat.isComputer) {
      return const <int>{};
    }
    return _engine.legalMoves(_state).map((move) => move.token).toSet();
  }

  /// Starts computer play if a computer seat moves first.
  void start() => unawaited(_drive());

  Future<void> rollDice() async {
    if (!canRoll) {
      return;
    }
    await _roll();
    await _drive();
  }

  Future<void> selectToken(int token) async {
    if (!movableTokens.contains(token)) {
      return;
    }
    await _move(token);
    await _drive();
  }

  /// Resets the board with the same seats and rules.
  void restart() {
    _generation++;
    _cancelTimers();
    _state = _engine.restart(_state);
    _startedAt = _clock();
    _finishedAt = null;
    _lastRoll = null;
    _rolling = false;
    _animation = null;
    _finishAnnounced = false;
    _log.clear();
    _captures.clear();
    _losses.clear();
    _notify();
    unawaited(_drive());
  }

  MatchSummary summary() {
    final players = _state.players;
    return MatchSummary(
      setup: setup,
      players: players,
      placements: _state.placements,
      finishedTokens: <int>[
        for (var i = 0; i < players.length; i++) _state.finishedTokenCount(i),
      ],
      captures: <int>[for (var i = 0; i < players.length; i++) capturesBy(i)],
      tokensLost: <int>[
        for (var i = 0; i < players.length; i++) tokensLostBy(i),
      ],
      duration: elapsed,
      turns: _state.turnNumber,
      endedAt: _finishedAt ?? _clock(),
    );
  }

  Future<void> _roll() async {
    final generation = _generation;
    _rolling = true;
    onRollStarted?.call();
    _notify();
    final value = _dice.roll();
    await _wait(_timing.roll);
    if (!_alive(generation)) {
      return;
    }
    _rolling = false;
    _lastRoll = value;
    _apply(_engine.roll(_state, value));
  }

  Future<void> _move(int token) async {
    final generation = _generation;
    final before = _state;
    LudoMove? chosen;
    for (final move in _engine.legalMoves(before)) {
      if (move.token == token) {
        chosen = move;
        break;
      }
    }
    if (chosen == null) {
      return;
    }
    final color = before.players[chosen.player].color;
    var path =
        LudoBoardGeometry.movePath(color, token, chosen.from, chosen.to);
    if (_timing.collapsePaths && path.length > 2) {
      path = <BoardPoint>[path.first, path.last];
    }
    final animation = TokenAnimation(
      id: ++_animationSeq,
      player: chosen.player,
      token: token,
      path: path,
      travel: _timing.hop * (path.length - 1),
      captured: <CapturedToken>[
        for (final victim in chosen.captures)
          CapturedToken(
            player: victim.player,
            token: victim.token,
            from: LudoBoardGeometry.tokenPoint(
              before.players[victim.player].color,
              victim.token,
              before.tokens[victim.player][victim.token],
            ),
          ),
      ],
      captureReturn: _timing.captureReturn,
    );
    _animation = animation;
    _apply(_engine.move(before, token));
    await _wait(animation.total);
    if (!_alive(generation)) {
      return;
    }
    _animation = null;
    _notify();
  }

  void _apply(ActionResult result) {
    _state = result.state;
    for (final event in result.events) {
      _log.add(event);
      if (event.type == LudoEventType.tokenCaptured) {
        _captures[event.player] = capturesBy(event.player) + 1;
        final victim = event.otherPlayer;
        if (victim != null) {
          _losses[victim] = tokensLostBy(victim) + 1;
        }
      }
    }
    if (_log.length > _maxLog) {
      _log.removeRange(0, _log.length - _maxLog);
    }
    if (_state.isFinished && _finishedAt == null) {
      _finishedAt = _clock();
    }
    onEvents?.call(result.events);
    _notify();
  }

  Future<void> _drive() async {
    if (_driving || _disposed) {
      return;
    }
    _driving = true;
    final generation = _generation;
    try {
      while (_alive(generation) && !isBusy) {
        final current = _state;
        if (current.isFinished) {
          _announceFinish();
          break;
        }
        final seat = current.currentSeat;
        final version = current.version;
        if (current.phase == TurnPhase.awaitingRoll) {
          if (seat.isHuman) {
            break;
          }
          await _wait(_timing.botRoll);
          if (!_alive(generation) || _state.version != version || isBusy) {
            continue;
          }
          await _roll();
        } else if (current.phase == TurnPhase.awaitingMove) {
          final moves = _engine.legalMoves(current);
          int token;
          if (seat.isComputer) {
            await _wait(_timing.botMove);
            if (!_alive(generation) || _state.version != version || isBusy) {
              continue;
            }
            token = _bot.chooseToken(_state, seat.difficulty);
          } else if (autoMoveSingleOption && _allEquivalent(moves)) {
            await _wait(_timing.autoMove);
            if (!_alive(generation) || _state.version != version || isBusy) {
              continue;
            }
            token = moves.first.token;
          } else {
            break;
          }
          await _move(token);
        } else {
          break;
        }
      }
    } finally {
      _driving = false;
      if (!_disposed && generation != _generation) {
        unawaited(_drive());
      }
    }
  }

  /// True when every legal move lands the same way (for example several
  /// tokens leaving the base), so choosing between them makes no difference.
  static bool _allEquivalent(List<LudoMove> moves) {
    if (moves.isEmpty) {
      return false;
    }
    final first = moves.first;
    return moves.every((move) => move.from == first.from && move.to == first.to);
  }

  void _announceFinish() {
    if (_finishAnnounced) {
      return;
    }
    _finishAnnounced = true;
    onFinished?.call();
  }

  bool _alive(int generation) => !_disposed && generation == _generation;

  Future<void> _wait(Duration duration) {
    if (_disposed || duration <= Duration.zero) {
      return Future<void>.value();
    }
    final completer = Completer<void>();
    _pending.add(completer);
    late final Timer timer;
    timer = Timer(duration, () {
      _timers.remove(timer);
      _pending.remove(completer);
      if (!completer.isCompleted) {
        completer.complete();
      }
    });
    _timers.add(timer);
    return completer.future;
  }

  void _cancelTimers() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
    final pending = List<Completer<void>>.of(_pending);
    _pending.clear();
    for (final completer in pending) {
      if (!completer.isCompleted) {
        completer.complete();
      }
    }
  }

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _cancelTimers();
    super.dispose();
  }
}

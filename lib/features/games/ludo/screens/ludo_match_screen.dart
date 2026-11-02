import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/app_scope.dart';
import '../../../../app/router.dart';
import '../../../../app/theme.dart';
import '../../../../core/l10n/app_strings.dart';
import '../controllers/ludo_match_controller.dart';
import '../controllers/match_timing.dart';
import '../models/game_state.dart';
import '../models/ludo_color.dart';
import '../models/ludo_event.dart';
import '../models/match_setup.dart';
import '../models/player_seat.dart';
import '../widgets/ludo_board_view.dart';
import '../widgets/ludo_dice.dart';
import '../widgets/player_pod.dart';

class LudoMatchScreen extends StatefulWidget {
  const LudoMatchScreen({super.key, required this.setup});

  final MatchSetup setup;

  @override
  State<LudoMatchScreen> createState() => _LudoMatchScreenState();
}

class _LudoMatchScreenState extends State<LudoMatchScreen> {
  LudoMatchController? _controller;
  String? _notice;
  Timer? _noticeTimer;
  Timer? _finishTimer;

  LudoMatchController get _match => _controller!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null) {
      return;
    }
    final services = context.services;
    final controller = LudoMatchController(
      setup: widget.setup,
      timing: MatchTiming.forSettings(services.settings.speed,
          reduceMotion: context.reduceMotion),
      autoMoveSingleOption: services.settings.autoMoveSingleOption,
    );
    controller.onEvents = _handleEvents;
    controller.onRollStarted = services.feedback.diceRoll;
    controller.onFinished = _handleFinished;
    _controller = controller;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        controller.start();
      }
    });
  }

  @override
  void dispose() {
    _noticeTimer?.cancel();
    _finishTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  void _handleEvents(List<LudoEvent> events) {
    if (!mounted) {
      return;
    }
    final feedback = context.services.feedback;
    final l10n = context.strings;
    final state = _match.state;
    String? notice;
    for (final event in events) {
      final name = state.players[event.player].name;
      switch (event.type) {
        case LudoEventType.tokenEntered:
        case LudoEventType.tokenMoved:
          feedback.tokenMove();
        case LudoEventType.tokenCaptured:
          feedback.capture();
          final victim = event.otherPlayer;
          notice = l10n.noticeCapture(
              name, victim == null ? '' : state.players[victim].name);
        case LudoEventType.tokenFinished:
          feedback.tokenHome();
          notice = l10n.noticeTokenHome(name);
        case LudoEventType.noLegalMoves:
          notice = l10n.noticeNoMoves(name, event.value ?? 0);
        case LudoEventType.sixLimitReached:
          notice = l10n.noticeSixLimit(name);
        case LudoEventType.playerFinished:
          notice = l10n.noticePlayerFinished(
              name, l10n.placement(event.value ?? 1));
        case LudoEventType.matchFinished:
          feedback.win();
        case LudoEventType.rolled:
        case LudoEventType.extraTurn:
        case LudoEventType.turnPassed:
          break;
      }
    }
    if (notice != null) {
      _showNotice(notice);
    }
  }

  void _showNotice(String text) {
    _noticeTimer?.cancel();
    setState(() => _notice = text);
    _noticeTimer = Timer(const Duration(milliseconds: 1900), () {
      if (mounted) {
        setState(() => _notice = null);
      }
    });
  }

  void _handleFinished() {
    if (!mounted) {
      return;
    }
    final summary = _match.summary();
    context.services.profile.recordMatch(summary);
    final delay = context.reduceMotion
        ? const Duration(milliseconds: 400)
        : const Duration(milliseconds: 1200);
    _finishTimer = Timer(delay, () {
      if (!mounted) {
        return;
      }
      Navigator.of(context)
          .pushReplacementNamed(AppRoutes.results, arguments: summary);
    });
  }

  Future<bool> _confirm({
    required String title,
    required String body,
    required String confirm,
    required String cancel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(confirm),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _confirmLeave() async {
    if (_match.state.isFinished) {
      Navigator.of(context).pop();
      return;
    }
    final l10n = context.strings;
    final leave = await _confirm(
      title: l10n.leaveTitle,
      body: l10n.leaveBody,
      confirm: l10n.leave,
      cancel: l10n.keepPlaying,
    );
    if (!leave || !mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  Future<void> _confirmRestart() async {
    final l10n = context.strings;
    final restart = await _confirm(
      title: l10n.restartTitle,
      body: l10n.restartBody,
      confirm: l10n.restart,
      cancel: l10n.keepPlaying,
    );
    if (!restart || !mounted) {
      return;
    }
    _noticeTimer?.cancel();
    setState(() => _notice = null);
    _match.restart();
  }

  void _showLog() {
    final l10n = context.strings;
    final state = _match.state;
    final lines = <String>[
      for (final event in _match.log.reversed)
        if (describeEvent(event, state, l10n) case final String line) line,
    ];
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.7),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Text(l10n.moveLog, style: theme.textTheme.titleLarge),
                ),
                if (lines.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    child: Text(l10n.moveLogEmpty,
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: lines.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(lines[index],
                            style: theme.textTheme.bodyMedium),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _seatSubtitle(PlayerSeat seat, AppStrings l10n) {
    if (seat.isLocalProfile) {
      return l10n.you;
    }
    if (seat.isComputer) {
      return l10n.computerSeatLabel(seat.difficulty);
    }
    return l10n.personSeatLabel;
  }

  String _prompt(AppStrings l10n) {
    final match = _match;
    final state = match.state;
    final winner = state.winner;
    if (state.isFinished && winner != null) {
      return l10n.logMatchFinished(state.players[winner].name);
    }
    if (match.isRolling) {
      return l10n.rolling;
    }
    final seat = state.currentSeat;
    if (seat.isComputer) {
      return l10n.computerPlaying(seat.name);
    }
    final soloHuman = match.setup.humanCount == 1;
    if (state.phase == TurnPhase.awaitingMove) {
      final roll = state.dice ?? 0;
      return soloHuman
          ? l10n.pickToken(roll)
          : l10n.playerPickToken(seat.name, roll);
    }
    return soloHuman ? l10n.yourTurnRoll : l10n.playerTurnRoll(seat.name);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          unawaited(_confirmLeave());
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: ListenableBuilder(
            listenable: _match,
            builder: (context, _) => _buildContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final l10n = context.strings;
    final theme = Theme.of(context);
    final match = _match;
    final state = match.state;
    final reduceMotion = context.reduceMotion;
    final settings = context.services.settings;
    final seatIndexByColor = <LudoColor, int>{
      for (var i = 0; i < state.playerCount; i++) state.players[i].color: i,
    };

    Widget pod(LudoColor color, {bool alignEnd = false}) {
      final index = seatIndexByColor[color];
      if (index == null) {
        return const SizedBox(height: 56);
      }
      final seat = state.players[index];
      final place = state.placementOf(index);
      return PlayerPod(
        seat: seat,
        subtitle: _seatSubtitle(seat, l10n),
        tokensHome: state.finishedTokenCount(index),
        active: !state.isFinished && state.currentPlayer == index,
        placementLabel: place == null ? null : l10n.placement(place),
        alignEnd: alignEnd,
      );
    }

    final board = LudoBoardView(
      state: state,
      animation: match.animation,
      movableTokens: match.movableTokens,
      onTokenTap: (token) => unawaited(match.selectToken(token)),
      reduceMotion: reduceMotion,
      semanticLabel: l10n.board,
    );

    final lastRoll = match.lastRoll;
    final dice = LudoDice(
      value: lastRoll,
      rolling: match.isRolling,
      enabled: match.canRoll,
      accent: LudoPalette.seat(state.currentSeat.color),
      onRoll: () => unawaited(match.rollDice()),
      reduceMotion: reduceMotion,
      semanticLabel: match.canRoll
          ? '${l10n.dice}. ${l10n.tapToRoll}'
          : (lastRoll == null ? l10n.dice : l10n.diceShowing(lastRoll)),
      size: 80,
    );

    final notice = _notice;
    final status = AnimatedSwitcher(
      duration: Duration(milliseconds: reduceMotion ? 0 : 200),
      child: Text(
        notice ?? _prompt(l10n),
        key: ValueKey<String>(notice ?? 'prompt-${state.version}-${match.isRolling}'),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleMedium?.copyWith(
          color: notice != null
              ? theme.colorScheme.secondary
              : theme.colorScheme.onSurface,
        ),
      ),
    );

    final topBar = Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
      child: Row(
        children: <Widget>[
          IconButton(
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => unawaited(_confirmLeave()),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(l10n.classicLudo, style: theme.textTheme.titleMedium),
                Text(
                  l10n.turnNumber(state.turnNumber),
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: l10n.moveLog,
            icon: const Icon(Icons.list_alt_rounded),
            onPressed: _showLog,
          ),
          IconButton(
            tooltip: l10n.restart,
            icon: const Icon(Icons.refresh_rounded),
            onPressed: state.isFinished ? null : () => unawaited(_confirmRestart()),
          ),
          PopupMenuButton<String>(
            tooltip: l10n.matchOptions,
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) {
              if (value == 'sound') {
                settings.setSoundEffects(!settings.soundEffects);
              } else if (value == 'vibration') {
                settings.setVibration(!settings.vibration);
              }
            },
            itemBuilder: (menuContext) => <PopupMenuEntry<String>>[
              CheckedPopupMenuItem<String>(
                value: 'sound',
                checked: settings.soundEffects,
                child: Text(l10n.soundEffects),
              ),
              CheckedPopupMenuItem<String>(
                value: 'vibration',
                checked: settings.vibration,
                child: Text(l10n.vibration),
              ),
            ],
          ),
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 720 &&
            constraints.maxWidth > constraints.maxHeight * 1.1;
        if (wide) {
          return Column(
            children: <Widget>[
              topBar,
              Expanded(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(child: board),
                      ),
                    ),
                    SizedBox(
                      width: 320,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 16, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            for (final color in LudoColor.values)
                              if (seatIndexByColor.containsKey(color))
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: pod(color),
                                  ),
                                ),
                            const Spacer(),
                            status,
                            const SizedBox(height: 16),
                            Center(child: dice),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
        return Column(
          children: <Widget>[
            topBar,
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: pod(LudoColor.red),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: pod(LudoColor.green, alignEnd: true),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Center(child: board),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: pod(LudoColor.blue),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: pod(LudoColor.yellow, alignEnd: true),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 10),
              child: SizedBox(height: 48, child: Center(child: status)),
            ),
            dice,
            const SizedBox(height: 18),
          ],
        );
      },
    );
  }
}

/// Human-readable move-log line for [event], or null for events that are not
/// shown in the log.
String? describeEvent(LudoEvent event, GameState state, AppStrings l10n) {
  final name = state.players[event.player].name;
  final victim = event.otherPlayer;
  return switch (event.type) {
    LudoEventType.rolled => l10n.logRolled(name, event.value ?? 0),
    LudoEventType.tokenEntered => l10n.logEntered(name),
    LudoEventType.tokenMoved => l10n.logMoved(name, event.value ?? 0),
    LudoEventType.tokenCaptured =>
      l10n.noticeCapture(name, victim == null ? '' : state.players[victim].name),
    LudoEventType.tokenFinished => l10n.noticeTokenHome(name),
    LudoEventType.noLegalMoves => l10n.noticeNoMoves(name, event.value ?? 0),
    LudoEventType.sixLimitReached => l10n.noticeSixLimit(name),
    LudoEventType.playerFinished =>
      l10n.noticePlayerFinished(name, l10n.placement(event.value ?? 1)),
    LudoEventType.extraTurn => l10n.noticeExtraTurn(name),
    LudoEventType.matchFinished => l10n.logMatchFinished(name),
    LudoEventType.turnPassed => null,
  };
}

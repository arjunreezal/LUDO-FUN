import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/widgets/common.dart';
import '../games/ludo/models/ludo_color.dart';
import '../games/ludo/models/ludo_ruleset.dart';
import '../games/ludo/models/match_setup.dart';
import '../games/ludo/models/player_seat.dart';
import 'setup_memory.dart';

/// Configures a local Classic Ludo match: seat count, colour, who plays each
/// seat, computer level and house rules.
class GameSetupScreen extends StatefulWidget {
  const GameSetupScreen({super.key, required this.mode});

  final MatchMode mode;

  @override
  State<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> {
  bool _initialized = false;
  int _playerCount = 4;
  LudoColor _yourColor = LudoColor.red;
  BotDifficulty _difficulty = BotDifficulty.medium;
  final List<SeatController> _controllers = <SeatController>[
    SeatController.human,
    SeatController.computer,
    SeatController.computer,
    SeatController.computer,
  ];
  final Map<int, String> _names = <int, String>{};
  LudoRuleset _rules = LudoRuleset.standard;

  bool get _isComputerMode => widget.mode == MatchMode.computer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }
    _initialized = true;
    if (!_isComputerMode) {
      _playerCount = 2;
      for (var i = 1; i < _controllers.length; i++) {
        _controllers[i] = SeatController.human;
      }
    }
    final last = context.services.setupMemory.last(widget.mode);
    if (last != null) {
      _restore(last);
    }
  }

  void _restore(MatchSetup last) {
    PlayerSeat? local;
    for (final seat in last.players) {
      if (seat.isLocalProfile) {
        local = seat;
      }
    }
    if (local == null) {
      return;
    }
    _playerCount = last.players.length;
    _yourColor = local.color;
    _difficulty = last.difficulty ?? BotDifficulty.medium;
    _rules = last.rules;
    final colors = SeatPlanner.colorsFor(_playerCount, _yourColor);
    for (var i = 1; i < colors.length; i++) {
      for (final seat in last.players) {
        if (seat.color == colors[i]) {
          _controllers[i] = seat.controller;
          if (seat.isHuman) {
            _names[i] = seat.name;
          }
        }
      }
    }
  }

  MatchSetup _buildSetup(AppStrings l10n) {
    return SeatPlanner.build(
      mode: widget.mode,
      yourColor: _yourColor,
      controllers: _controllers.take(_playerCount).toList(),
      difficulty: _difficulty,
      rules: _rules,
      yourName: context.services.profile.displayName,
      strings: l10n,
      names: _names,
    );
  }

  void _start() {
    final services = context.services;
    final setup = _buildSetup(context.strings);
    services.setupMemory.remember(setup);
    services.feedback.button();
    Navigator.of(context).pushReplacementNamed(AppRoutes.match, arguments: setup);
  }

  Future<void> _rename(int seat, String current) async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => _RenameDialog(initial: current),
    );
    if (name == null || !mounted) {
      return;
    }
    setState(() => _names[seat] = name);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.strings;
    final theme = Theme.of(context);
    final preview = _buildSetup(l10n);
    final hasComputers = preview.computerCount > 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isComputerMode ? l10n.playWithComputer : l10n.playWithFriends),
      ),
      body: SafeArea(
        top: false,
        child: ContentWidth(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            children: <Widget>[
              if (!_isComputerMode)
                Text(
                  l10n.setupFriendsHint,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              SectionTitle(l10n.players),
              SegmentedButton<int>(
                showSelectedIcon: false,
                segments: const <ButtonSegment<int>>[
                  ButtonSegment<int>(value: 2, label: Text('2')),
                  ButtonSegment<int>(value: 3, label: Text('3')),
                  ButtonSegment<int>(value: 4, label: Text('4')),
                ],
                selected: <int>{_playerCount},
                onSelectionChanged: (selection) =>
                    setState(() => _playerCount = selection.first),
              ),
              SectionTitle(l10n.yourColor),
              Row(
                children: <Widget>[
                  for (final color in LudoColor.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: _ColorSwatch(
                        color: color,
                        label: l10n.colorName(color),
                        selected: color == _yourColor,
                        onTap: () => setState(() => _yourColor = color),
                      ),
                    ),
                ],
              ),
              SectionTitle(l10n.seats),
              Panel(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: <Widget>[
                    for (var i = 0; i < preview.players.length; i++)
                      _SeatRow(
                        seat: preview.players[i],
                        caption: i == 0
                            ? l10n.you
                            : (preview.players[i].isComputer
                                ? l10n.seatComputer
                                : l10n.seatPerson),
                        controller: _isComputerMode || i == 0
                            ? null
                            : _controllers[i],
                        onControllerChanged: (value) =>
                            setState(() => _controllers[i] = value),
                        onRename: i > 0 && preview.players[i].isHuman
                            ? () => _rename(i, preview.players[i].name)
                            : null,
                      ),
                  ],
                ),
              ),
              if (hasComputers) ...<Widget>[
                SectionTitle(l10n.computerLevel),
                SegmentedButton<BotDifficulty>(
                  showSelectedIcon: false,
                  segments: <ButtonSegment<BotDifficulty>>[
                    for (final level in BotDifficulty.values)
                      ButtonSegment<BotDifficulty>(
                        value: level,
                        label: Text(l10n.difficultyName(level)),
                      ),
                  ],
                  selected: <BotDifficulty>{_difficulty},
                  onSelectionChanged: (selection) =>
                      setState(() => _difficulty = selection.first),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.difficultyHint(_difficulty),
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
              const SizedBox(height: 20),
              Panel(
                padding: EdgeInsets.zero,
                child: Theme(
                  data: theme.copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    leading: const Icon(Icons.tune_rounded),
                    title: Text(l10n.houseRules),
                    childrenPadding: const EdgeInsets.only(bottom: 8),
                    children: <Widget>[
                      SwitchListTile(
                        title: Text(l10n.ruleEnterOnOne),
                        value: _rules.entryRolls.contains(1),
                        onChanged: (value) => setState(() => _rules =
                            _rules.copyWith(
                                entryRolls: value ? <int>{1, 6} : <int>{6})),
                      ),
                      SwitchListTile(
                        title: Text(l10n.ruleThreeSixes),
                        value: _rules.maxConsecutiveSixes > 0,
                        onChanged: (value) => setState(() => _rules = _rules
                            .copyWith(maxConsecutiveSixes: value ? 3 : 0)),
                      ),
                      SwitchListTile(
                        title: Text(l10n.ruleSafeSquares),
                        value: _rules.safeSquaresEnabled,
                        onChanged: (value) => setState(() =>
                            _rules = _rules.copyWith(safeSquaresEnabled: value)),
                      ),
                      SwitchListTile(
                        title: Text(l10n.ruleCaptureBonus),
                        value: _rules.extraTurnOnCapture,
                        onChanged: (value) => setState(() =>
                            _rules = _rules.copyWith(extraTurnOnCapture: value)),
                      ),
                      SwitchListTile(
                        title: Text(l10n.ruleFirstFinisher),
                        value:
                            _rules.endCondition == MatchEndCondition.firstFinisher,
                        onChanged: (value) => setState(() => _rules =
                            _rules.copyWith(
                                endCondition: value
                                    ? MatchEndCondition.firstFinisher
                                    : MatchEndCondition.fullRanking)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: _start,
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(l10n.startMatch),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.color,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final LudoColor color;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fill = LudoPalette.seat(color);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkResponse(
        onTap: onTap,
        radius: 30,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: fill,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected
                  ? Theme.of(context).colorScheme.onSurface
                  : Colors.transparent,
              width: 3,
            ),
          ),
          child: selected
              ? Icon(Icons.check_rounded, color: LudoPalette.onSeat(color))
              : null,
        ),
      ),
    );
  }
}

class _SeatRow extends StatelessWidget {
  const _SeatRow({
    required this.seat,
    required this.caption,
    required this.controller,
    required this.onControllerChanged,
    required this.onRename,
  });

  final PlayerSeat seat;
  final String caption;
  final SeatController? controller;
  final ValueChanged<SeatController> onControllerChanged;
  final VoidCallback? onRename;

  @override
  Widget build(BuildContext context) {
    final l10n = context.strings;
    final theme = Theme.of(context);
    final current = controller;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: <Widget>[
          PlayerAvatar(
            name: seat.name,
            color: LudoPalette.seat(seat.color),
            size: 36,
            icon: seat.isComputer ? Icons.smart_toy_rounded : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: onRename,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(seat.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall),
                        ),
                        if (onRename != null) ...<Widget>[
                          const SizedBox(width: 6),
                          Icon(Icons.edit_rounded,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant,
                              semanticLabel: l10n.rename),
                        ],
                      ],
                    ),
                    Text(caption,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ),
          ),
          if (current != null)
            SegmentedButton<SeatController>(
              showSelectedIcon: false,
              segments: <ButtonSegment<SeatController>>[
                ButtonSegment<SeatController>(
                  value: SeatController.human,
                  icon: const Icon(Icons.person_rounded),
                  tooltip: l10n.seatPerson,
                ),
                ButtonSegment<SeatController>(
                  value: SeatController.computer,
                  icon: const Icon(Icons.smart_toy_rounded),
                  tooltip: l10n.seatComputer,
                ),
              ],
              selected: <SeatController>{current},
              onSelectionChanged: (selection) =>
                  onControllerChanged(selection.first),
            ),
        ],
      ),
    );
  }
}

class _RenameDialog extends StatefulWidget {
  const _RenameDialog({required this.initial});

  final String initial;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final TextEditingController _text =
      TextEditingController(text: widget.initial);
  String? _error;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _text.text.trim();
    if (value.isEmpty) {
      setState(() => _error = context.strings.nameEmpty);
      return;
    }
    Navigator.of(context).pop(value.length > 20 ? value.substring(0, 20) : value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.strings;
    return AlertDialog(
      title: Text(l10n.rename),
      content: TextField(
        controller: _text,
        autofocus: true,
        maxLength: 20,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(labelText: l10n.displayName, errorText: _error),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.save)),
      ],
    );
  }
}

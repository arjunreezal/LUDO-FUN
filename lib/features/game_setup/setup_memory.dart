import 'dart:async';
import 'dart:convert';

import '../../core/l10n/app_strings.dart';
import '../../core/storage/key_value_store.dart';
import '../games/ludo/models/ludo_color.dart';
import '../games/ludo/models/ludo_ruleset.dart';
import '../games/ludo/models/match_setup.dart';
import '../games/ludo/models/player_seat.dart';

/// Remembers the last match configuration for each mode so Quick play and
/// the setup screen can start from it.
class SetupMemory {
  static const _kComputer = 'setup.last.computer';
  static const _kPassAndPlay = 'setup.last.pass';

  KeyValueStore _store = MemoryStore();

  void attach(KeyValueStore store) => _store = store;

  MatchSetup? last(MatchMode mode) {
    final raw = _store.getString(_key(mode));
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      return MatchSetup.fromJson(jsonDecode(raw));
    } on FormatException {
      return null;
    }
  }

  void remember(MatchSetup setup) {
    unawaited(_store.setString(_key(setup.mode), jsonEncode(setup.toJson())));
  }

  static String _key(MatchMode mode) =>
      mode == MatchMode.computer ? _kComputer : _kPassAndPlay;
}

/// Builds seat lists for the setup screen and Quick play.
abstract final class SeatPlanner {
  /// Colours used for [count] seats, starting with the local player's colour
  /// and keeping opponents spread around the board.
  static List<LudoColor> colorsFor(int count, LudoColor yours) {
    if (count == 2) {
      return <LudoColor>[yours, yours.opposite];
    }
    return <LudoColor>[
      for (var i = 0; i < count; i++)
        LudoColor.values[(yours.index + i) % LudoColor.values.length],
    ];
  }

  /// [controllers] holds one entry per seat; seat 0 is always the local
  /// person. [names] can override the generated names of person seats.
  static MatchSetup build({
    required MatchMode mode,
    required LudoColor yourColor,
    required List<SeatController> controllers,
    required BotDifficulty difficulty,
    required LudoRuleset rules,
    required String yourName,
    required AppStrings strings,
    Map<int, String> names = const <int, String>{},
  }) {
    final colors = colorsFor(controllers.length, yourColor);
    var computerNumber = 0;
    final seats = <PlayerSeat>[];
    for (var i = 0; i < controllers.length; i++) {
      final isComputer = i > 0 && controllers[i] == SeatController.computer;
      final String name;
      if (i == 0) {
        name = yourName;
      } else if (isComputer) {
        computerNumber++;
        name = strings.computerName(computerNumber);
      } else {
        name = names[i] ?? strings.playerName(i + 1);
      }
      seats.add(PlayerSeat(
        id: 'seat-$i',
        name: name,
        color: colors[i],
        controller: isComputer ? SeatController.computer : SeatController.human,
        difficulty: difficulty,
        isLocalProfile: i == 0,
      ));
    }
    return MatchSetup(players: seats, mode: mode, rules: rules);
  }

  /// The setup Quick play starts: the last computer match, or the player
  /// against three medium computers.
  static MatchSetup quickPlay({
    required MatchSetup? last,
    required String yourName,
    required AppStrings strings,
  }) {
    if (last != null && last.mode == MatchMode.computer) {
      return refreshNames(last, yourName: yourName, strings: strings);
    }
    return build(
      mode: MatchMode.computer,
      yourColor: LudoColor.red,
      controllers: const <SeatController>[
        SeatController.human,
        SeatController.computer,
        SeatController.computer,
        SeatController.computer,
      ],
      difficulty: BotDifficulty.medium,
      rules: LudoRuleset.standard,
      yourName: yourName,
      strings: strings,
    );
  }

  /// Updates the local seat's name and regenerates computer names in the
  /// current language.
  static MatchSetup refreshNames(MatchSetup setup,
      {required String yourName, required AppStrings strings}) {
    var computerNumber = 0;
    final seats = <PlayerSeat>[
      for (final seat in setup.players)
        if (seat.isLocalProfile)
          seat.copyWith(name: yourName)
        else if (seat.isComputer)
          seat.copyWith(name: strings.computerName(++computerNumber))
        else
          seat,
    ];
    return MatchSetup(players: seats, mode: setup.mode, rules: setup.rules);
  }
}

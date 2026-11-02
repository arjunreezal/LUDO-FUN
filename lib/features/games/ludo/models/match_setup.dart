import 'ludo_ruleset.dart';
import 'player_seat.dart';

/// How a local match was started.
enum MatchMode {
  computer,
  passAndPlay;

  static MatchMode fromName(String? name) =>
      name == MatchMode.passAndPlay.name ? MatchMode.passAndPlay : MatchMode.computer;
}

/// Everything needed to start (or restart) a Classic Ludo match.
class MatchSetup {
  const MatchSetup({
    required this.players,
    required this.mode,
    this.rules = LudoRuleset.standard,
  });

  final List<PlayerSeat> players;
  final MatchMode mode;
  final LudoRuleset rules;

  int get computerCount => players.where((seat) => seat.isComputer).length;
  int get humanCount => players.where((seat) => seat.isHuman).length;

  /// Difficulty of the computer seats, or null when there are none.
  BotDifficulty? get difficulty {
    for (final seat in players) {
      if (seat.isComputer) {
        return seat.difficulty;
      }
    }
    return null;
  }

  Map<String, Object> toJson() => <String, Object>{
        'mode': mode.name,
        'players': <Object>[for (final seat in players) seat.toJson()],
        'rules': rules.toJson(),
      };

  static MatchSetup? fromJson(Object? json) {
    if (json is! Map) {
      return null;
    }
    final rawPlayers = json['players'];
    if (rawPlayers is! List) {
      return null;
    }
    final players = <PlayerSeat>[];
    for (final raw in rawPlayers) {
      final seat = PlayerSeat.fromJson(raw);
      if (seat != null) {
        players.add(seat);
      }
    }
    if (players.length < 2 || players.length > 4) {
      return null;
    }
    if (players.map((seat) => seat.color).toSet().length != players.length) {
      return null;
    }
    final modeName = json['mode'];
    return MatchSetup(
      players: players,
      mode: MatchMode.fromName(modeName is String ? modeName : null),
      rules: LudoRuleset.fromJson(json['rules']),
    );
  }
}

import 'dart:math' as math;

/// Lifetime Classic Ludo statistics for this device's profile.
class LudoStats {
  const LudoStats({
    this.matchesPlayed = 0,
    this.wins = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.captures = 0,
    this.tokensLost = 0,
    this.tokensHome = 0,
    this.flawlessWins = 0,
    this.winsVsHard = 0,
    this.fastestWinSeconds,
  });

  final int matchesPlayed;
  final int wins;
  final int currentStreak;
  final int bestStreak;
  final int captures;
  final int tokensLost;
  final int tokensHome;

  /// Wins in which none of the player's tokens were captured.
  final int flawlessWins;

  /// Wins in matches that included at least one hard computer.
  final int winsVsHard;
  final int? fastestWinSeconds;

  double get winRate => matchesPlayed == 0 ? 0 : wins / matchesPlayed;

  LudoStats withMatch(MatchRecord record, {required bool againstHard}) {
    final won = record.won;
    final streak = won ? currentStreak + 1 : 0;
    final fastest = fastestWinSeconds;
    return LudoStats(
      matchesPlayed: matchesPlayed + 1,
      wins: wins + (won ? 1 : 0),
      currentStreak: streak,
      bestStreak: math.max(bestStreak, streak),
      captures: captures + record.captures,
      tokensLost: tokensLost + record.tokensLost,
      tokensHome: tokensHome + record.tokensHome,
      flawlessWins: flawlessWins + (won && record.tokensLost == 0 ? 1 : 0),
      winsVsHard: winsVsHard + (won && againstHard ? 1 : 0),
      fastestWinSeconds: !won
          ? fastest
          : (fastest == null
              ? record.durationSeconds
              : math.min(fastest, record.durationSeconds)),
    );
  }

  Map<String, Object> toJson() => <String, Object>{
        'matchesPlayed': matchesPlayed,
        'wins': wins,
        'currentStreak': currentStreak,
        'bestStreak': bestStreak,
        'captures': captures,
        'tokensLost': tokensLost,
        'tokensHome': tokensHome,
        'flawlessWins': flawlessWins,
        'winsVsHard': winsVsHard,
        'fastestWinSeconds': ?fastestWinSeconds,
      };

  static LudoStats fromJson(Object? json) {
    if (json is! Map) {
      return const LudoStats();
    }
    final Map<dynamic, dynamic> map = json;
    int read(String key) {
      final value = map[key];
      return value is int && value >= 0 ? value : 0;
    }

    final fastest = json['fastestWinSeconds'];
    return LudoStats(
      matchesPlayed: read('matchesPlayed'),
      wins: read('wins'),
      currentStreak: read('currentStreak'),
      bestStreak: read('bestStreak'),
      captures: read('captures'),
      tokensLost: read('tokensLost'),
      tokensHome: read('tokensHome'),
      flawlessWins: read('flawlessWins'),
      winsVsHard: read('winsVsHard'),
      fastestWinSeconds: fastest is int && fastest > 0 ? fastest : null,
    );
  }
}

/// One finished match in the local history, from this profile's point of view.
class MatchRecord {
  const MatchRecord({
    required this.endedAtMs,
    required this.durationSeconds,
    required this.mode,
    required this.playerCount,
    required this.computerCount,
    required this.placement,
    required this.captures,
    required this.tokensLost,
    required this.tokensHome,
    required this.color,
    this.difficulty,
  });

  final int endedAtMs;
  final int durationSeconds;

  /// [MatchMode] name.
  final String mode;
  final int playerCount;
  final int computerCount;

  /// [BotDifficulty] name of the computer seats, if any.
  final String? difficulty;
  final int placement;
  final int captures;
  final int tokensLost;
  final int tokensHome;

  /// [LudoColor] name this profile played.
  final String color;

  bool get won => placement == 1;
  DateTime get endedAt => DateTime.fromMillisecondsSinceEpoch(endedAtMs);

  Map<String, Object> toJson() => <String, Object>{
        'endedAtMs': endedAtMs,
        'durationSeconds': durationSeconds,
        'mode': mode,
        'playerCount': playerCount,
        'computerCount': computerCount,
        'difficulty': ?difficulty,
        'placement': placement,
        'captures': captures,
        'tokensLost': tokensLost,
        'tokensHome': tokensHome,
        'color': color,
      };

  static MatchRecord? fromJson(Object? json) {
    if (json is! Map) {
      return null;
    }
    final Map<dynamic, dynamic> map = json;
    int? read(String key) {
      final value = map[key];
      return value is int ? value : null;
    }

    final mode = json['mode'];
    final color = json['color'];
    final difficulty = json['difficulty'];
    final endedAtMs = read('endedAtMs');
    final placement = read('placement');
    final playerCount = read('playerCount');
    if (mode is! String ||
        color is! String ||
        endedAtMs == null ||
        placement == null ||
        playerCount == null) {
      return null;
    }
    return MatchRecord(
      endedAtMs: endedAtMs,
      durationSeconds: read('durationSeconds') ?? 0,
      mode: mode,
      playerCount: playerCount,
      computerCount: read('computerCount') ?? 0,
      difficulty: difficulty is String ? difficulty : null,
      placement: placement,
      captures: read('captures') ?? 0,
      tokensLost: read('tokensLost') ?? 0,
      tokensHome: read('tokensHome') ?? 0,
      color: color,
    );
  }
}

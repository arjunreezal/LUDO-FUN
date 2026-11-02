/// How a match decides when it is over.
enum MatchEndCondition {
  /// Play on until every seat but one has brought all tokens home.
  fullRanking,

  /// Stop as soon as the first seat brings all tokens home. Remaining seats
  /// are ranked by how far their tokens have travelled.
  firstFinisher,
}

/// Configurable Classic Ludo rules. See `docs/LUDO_RULES.md` for the
/// documented default ruleset that ships in the first release.
class LudoRuleset {
  const LudoRuleset({
    this.entryRolls = const <int>{6},
    this.extraTurnOnSix = true,
    this.maxConsecutiveSixes = 3,
    this.extraTurnOnCapture = true,
    this.extraTurnOnFinish = true,
    this.safeSquaresEnabled = true,
    this.endCondition = MatchEndCondition.fullRanking,
    this.rankComputersWhenHumansDone = true,
  });

  /// The documented default ruleset.
  static const LudoRuleset standard = LudoRuleset();

  /// Dice values that let a token leave the base onto its start square.
  final Set<int> entryRolls;

  /// Rolling a six earns another roll.
  final bool extraTurnOnSix;

  /// Rolling this many sixes in a row forfeits the rest of the turn. The
  /// roll that reaches the limit cannot be used. `0` disables the limit.
  final int maxConsecutiveSixes;

  /// Capturing an opponent's token earns another roll.
  final bool extraTurnOnCapture;

  /// Bringing a token to the centre earns another roll.
  final bool extraTurnOnFinish;

  /// Start squares and star squares protect every token standing on them.
  final bool safeSquaresEnabled;

  final MatchEndCondition endCondition;

  /// When every human seat has finished and only computer seats remain, the
  /// computers are ranked by progress instead of playing on alone.
  final bool rankComputersWhenHumansDone;

  /// Throws [ArgumentError] when the configuration cannot be played.
  void validate() {
    if (entryRolls.isEmpty) {
      throw ArgumentError.value(
          entryRolls, 'entryRolls', 'At least one entry roll is required');
    }
    for (final roll in entryRolls) {
      if (roll < 1 || roll > 6) {
        throw ArgumentError.value(
            roll, 'entryRolls', 'Entry rolls must be between 1 and 6');
      }
    }
    if (maxConsecutiveSixes < 0) {
      throw ArgumentError.value(maxConsecutiveSixes, 'maxConsecutiveSixes',
          'Must be zero (no limit) or positive');
    }
  }

  LudoRuleset copyWith({
    Set<int>? entryRolls,
    bool? extraTurnOnSix,
    int? maxConsecutiveSixes,
    bool? extraTurnOnCapture,
    bool? extraTurnOnFinish,
    bool? safeSquaresEnabled,
    MatchEndCondition? endCondition,
    bool? rankComputersWhenHumansDone,
  }) {
    return LudoRuleset(
      entryRolls: entryRolls ?? this.entryRolls,
      extraTurnOnSix: extraTurnOnSix ?? this.extraTurnOnSix,
      maxConsecutiveSixes: maxConsecutiveSixes ?? this.maxConsecutiveSixes,
      extraTurnOnCapture: extraTurnOnCapture ?? this.extraTurnOnCapture,
      extraTurnOnFinish: extraTurnOnFinish ?? this.extraTurnOnFinish,
      safeSquaresEnabled: safeSquaresEnabled ?? this.safeSquaresEnabled,
      endCondition: endCondition ?? this.endCondition,
      rankComputersWhenHumansDone:
          rankComputersWhenHumansDone ?? this.rankComputersWhenHumansDone,
    );
  }

  Map<String, Object> toJson() {
    final rolls = entryRolls.toList()..sort();
    return <String, Object>{
      'entryRolls': rolls,
      'extraTurnOnSix': extraTurnOnSix,
      'maxConsecutiveSixes': maxConsecutiveSixes,
      'extraTurnOnCapture': extraTurnOnCapture,
      'extraTurnOnFinish': extraTurnOnFinish,
      'safeSquaresEnabled': safeSquaresEnabled,
      'endCondition': endCondition.name,
      'rankComputersWhenHumansDone': rankComputersWhenHumansDone,
    };
  }

  static LudoRuleset fromJson(Object? json) {
    const defaults = LudoRuleset.standard;
    if (json is! Map) {
      return defaults;
    }
    final rawRolls = json['entryRolls'];
    final rolls = <int>{};
    if (rawRolls is List) {
      for (final value in rawRolls) {
        if (value is int && value >= 1 && value <= 6) {
          rolls.add(value);
        }
      }
    }
    final maxSixes = json['maxConsecutiveSixes'];
    final endName = json['endCondition'];
    return LudoRuleset(
      entryRolls: rolls.isEmpty ? defaults.entryRolls : rolls,
      extraTurnOnSix: _bool(json['extraTurnOnSix'], defaults.extraTurnOnSix),
      maxConsecutiveSixes: maxSixes is int && maxSixes >= 0
          ? maxSixes
          : defaults.maxConsecutiveSixes,
      extraTurnOnCapture:
          _bool(json['extraTurnOnCapture'], defaults.extraTurnOnCapture),
      extraTurnOnFinish:
          _bool(json['extraTurnOnFinish'], defaults.extraTurnOnFinish),
      safeSquaresEnabled:
          _bool(json['safeSquaresEnabled'], defaults.safeSquaresEnabled),
      endCondition: endName == MatchEndCondition.firstFinisher.name
          ? MatchEndCondition.firstFinisher
          : MatchEndCondition.fullRanking,
      rankComputersWhenHumansDone: _bool(json['rankComputersWhenHumansDone'],
          defaults.rankComputersWhenHumansDone),
    );
  }

  static bool _bool(Object? value, bool fallback) =>
      value is bool ? value : fallback;
}

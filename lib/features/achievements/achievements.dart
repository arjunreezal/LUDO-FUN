import 'dart:math' as math;

import '../../core/l10n/app_strings.dart';
import '../profile/profile_models.dart';

/// An achievement and how close this profile is to it. Progress comes only
/// from recorded statistics; nothing is granted without a finished match.
class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.current,
    required this.target,
  });

  final String id;
  final String title;
  final String description;
  final int current;
  final int target;

  bool get unlocked => current >= target;
  double get progress => target <= 0 ? 1.0 : math.min(1.0, current / target);
}

List<Achievement> buildAchievements(LudoStats stats, AppStrings strings) =>
    <Achievement>[
      Achievement(
        id: 'first_match',
        title: strings.achFirstMatch,
        description: strings.achFirstMatchDesc,
        current: stats.matchesPlayed,
        target: 1,
      ),
      Achievement(
        id: 'first_win',
        title: strings.achFirstWin,
        description: strings.achFirstWinDesc,
        current: stats.wins,
        target: 1,
      ),
      Achievement(
        id: 'five_wins',
        title: strings.achFiveWins,
        description: strings.achFiveWinsDesc,
        current: stats.wins,
        target: 5,
      ),
      Achievement(
        id: 'ten_matches',
        title: strings.achTenMatches,
        description: strings.achTenMatchesDesc,
        current: stats.matchesPlayed,
        target: 10,
      ),
      Achievement(
        id: 'hunter',
        title: strings.achHunter,
        description: strings.achHunterDesc,
        current: stats.captures,
        target: 25,
      ),
      Achievement(
        id: 'untouchable',
        title: strings.achUntouchable,
        description: strings.achUntouchableDesc,
        current: stats.flawlessWins,
        target: 1,
      ),
      Achievement(
        id: 'beat_hard',
        title: strings.achBeatHard,
        description: strings.achBeatHardDesc,
        current: stats.winsVsHard,
        target: 1,
      ),
    ];

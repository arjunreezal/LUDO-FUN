import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../core/widgets/common.dart';
import '../games/game_catalog/game_art.dart';
import '../games/game_catalog/game_catalog.dart';

/// Personal bests per game on this device. Global, per-game rankings arrive
/// with online play; ratings from different games are never combined.
class LeaderboardsScreen extends StatelessWidget {
  const LeaderboardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = context.services;
    final l10n = context.strings;
    final theme = Theme.of(context);
    return SafeArea(
      child: ListenableBuilder(
        listenable: services.profile,
        builder: (context, _) {
          final stats = services.profile.stats;
          final fastest = stats.fastestWinSeconds;
          final rows = <(String, String)>[
            (l10n.statWins, '${stats.wins}'),
            (l10n.statPlayed, '${stats.matchesPlayed}'),
            (l10n.statWinRate, '${(stats.winRate * 100).round()}%'),
            (l10n.statBestStreak, '${stats.bestStreak}'),
            (
              l10n.statFastestWin,
              fastest == null ? '–' : formatDuration(Duration(seconds: fastest)),
            ),
            (l10n.statCaptures, '${stats.captures}'),
            (l10n.statWinsVsHard, '${stats.winsVsHard}'),
          ];
          return ContentWidth(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              children: <Widget>[
                Text(l10n.navRankings, style: theme.textTheme.headlineMedium),
                const SizedBox(height: 6),
                Text(
                  l10n.globalLater,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                SectionTitle(l10n.yourBests),
                Panel(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const GameArt(game: GameId.classicLudo, size: 44),
                          const SizedBox(width: 12),
                          Text(l10n.classicLudo,
                              style: theme.textTheme.titleLarge),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (stats.matchesPlayed == 0)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            l10n.noRankingYet,
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant),
                          ),
                        )
                      else
                        for (final (label, value) in rows)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(label,
                                      style: theme.textTheme.bodyLarge),
                                ),
                                Text(value, style: theme.textTheme.titleMedium),
                              ],
                            ),
                          ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

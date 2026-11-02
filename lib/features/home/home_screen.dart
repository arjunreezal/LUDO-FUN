import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/widgets/common.dart';
import '../achievements/achievements.dart';
import '../game_setup/setup_memory.dart';
import '../games/game_catalog/game_art.dart';
import '../games/game_catalog/game_catalog.dart';
import '../games/ludo/models/match_setup.dart';
import '../games/ludo/models/player_seat.dart';
import '../games/ludo/widgets/ludo_board_view.dart';
import '../profile/match_record_tile.dart';
import 'home_shell.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onOpenTab});

  final ValueChanged<int> onOpenTab;

  @override
  Widget build(BuildContext context) {
    final services = context.services;
    final l10n = context.strings;
    final theme = Theme.of(context);

    return SafeArea(
      child: ListenableBuilder(
        listenable: services.profile,
        builder: (context, _) {
          final profile = services.profile;
          final stats = profile.stats;
          final achievements = buildAchievements(stats, l10n);
          final unlocked = achievements.where((a) => a.unlocked).length;
          final history = profile.history.take(3).toList();
          final upcoming =
              GameId.values.where((game) => !game.available).toList();

          return ContentWidth(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: <Widget>[
                Row(
                  children: <Widget>[
                    PlayerAvatar(
                      name: profile.displayName,
                      color: LudoPalette.avatars[profile.avatarIndex],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(l10n.greeting(profile.displayName),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleLarge),
                          Text(
                            l10n.playingOffline,
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.settings,
                      icon: const Icon(Icons.settings_rounded),
                      onPressed: () =>
                          Navigator.of(context).pushNamed(AppRoutes.settings),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _ClassicLudoHero(yourName: profile.displayName),
                SectionTitle(
                  l10n.yourRecord,
                  trailing: TextButton(
                    onPressed: () => onOpenTab(HomeTabs.profile),
                    child: Text(l10n.achievementsProgress(
                        unlocked, achievements.length)),
                  ),
                ),
                Panel(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: StatTile(
                            value: '${stats.matchesPlayed}',
                            label: l10n.statPlayed),
                      ),
                      Expanded(
                        child: StatTile(
                            value: '${stats.wins}', label: l10n.statWins),
                      ),
                      Expanded(
                        child: StatTile(
                          value: '${(stats.winRate * 100).round()}%',
                          label: l10n.statWinRate,
                        ),
                      ),
                    ],
                  ),
                ),
                SectionTitle(l10n.moreGames),
                SizedBox(
                  height: 132,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: upcoming.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 12),
                    itemBuilder: (context, index) =>
                        _UpcomingGameTile(game: upcoming[index]),
                  ),
                ),
                SectionTitle(l10n.recentMatches),
                Panel(
                  padding: history.isEmpty
                      ? const EdgeInsets.all(16)
                      : const EdgeInsets.symmetric(vertical: 4),
                  child: history.isEmpty
                      ? Text(
                          l10n.noMatchesYet,
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant),
                        )
                      : Column(
                          children: <Widget>[
                            for (final record in history)
                              MatchRecordTile(record: record),
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

class _ClassicLudoHero extends StatelessWidget {
  const _ClassicLudoHero({required this.yourName});

  final String yourName;

  @override
  Widget build(BuildContext context) {
    final services = context.services;
    final l10n = context.strings;
    final theme = Theme.of(context);
    final quick = SeatPlanner.quickPlay(
      last: services.setupMemory.last(MatchMode.computer),
      yourName: yourName,
      strings: l10n,
    );
    final difficulty = l10n.difficultyName(quick.difficulty ?? BotDifficulty.medium);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(l10n.classicLudo, style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 6),
                    Text(
                      l10n.classicLudoTagline,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const LudoBoardArt(size: 108),
            ],
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () {
              services.feedback.button();
              Navigator.of(context).pushNamed(AppRoutes.match, arguments: quick);
            },
            icon: const Icon(Icons.bolt_rounded),
            label: Text(l10n.quickPlay),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.quickPlayDetail(quick.computerCount, difficulty),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context)
                      .pushNamed(AppRoutes.setup, arguments: MatchMode.computer),
                  icon: const Icon(Icons.smart_toy_rounded, size: 20),
                  label: Text(l10n.vsComputerShort,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed(
                      AppRoutes.setup,
                      arguments: MatchMode.passAndPlay),
                  icon: const Icon(Icons.groups_rounded, size: 20),
                  label: Text(l10n.withFriendsShort,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UpcomingGameTile extends StatelessWidget {
  const _UpcomingGameTile({required this.game});

  final GameId game;

  @override
  Widget build(BuildContext context) {
    final l10n = context.strings;
    final theme = Theme.of(context);
    return Container(
      width: 124,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Opacity(opacity: 0.75, child: GameArt(game: game, size: 52)),
          const Spacer(),
          Text(game.title(l10n),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall),
          Text(
            l10n.comingSoon,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

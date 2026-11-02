import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../app/router.dart';
import '../../../core/widgets/common.dart';
import '../ludo/models/match_setup.dart';
import 'game_art.dart';
import 'game_catalog.dart';

/// The game library. Classic Ludo is playable; the other five are listed as
/// in development and cannot be started.
class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.strings;
    final theme = Theme.of(context);
    return SafeArea(
      child: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: <Widget>[
            Text(l10n.navGames, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 16),
            for (final game in GameId.values) ...<Widget>[
              _GameCard(game: game),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({required this.game});

  final GameId game;

  @override
  Widget build(BuildContext context) {
    final l10n = context.strings;
    final theme = Theme.of(context);
    final available = game.available;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: available
              ? game.accent.withValues(alpha: 0.6)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Opacity(
            opacity: available ? 1 : 0.8,
            child: GameArt(game: game, size: available ? 88 : 64),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(game.title(l10n), style: theme.textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  game.description(l10n),
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: <Widget>[
                    for (final mode in game.modes(l10n))
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(mode, style: theme.textTheme.labelSmall),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (available)
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).pushNamed(
                        AppRoutes.setup,
                        arguments: MatchMode.computer),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(l10n.play),
                  )
                else
                  Row(
                    children: <Widget>[
                      Icon(Icons.hourglass_empty_rounded,
                          size: 16, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text(
                        l10n.inDevelopment,
                        style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

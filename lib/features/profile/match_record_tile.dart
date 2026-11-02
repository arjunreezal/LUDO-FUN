import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../core/widgets/common.dart';
import '../games/ludo/models/ludo_color.dart';
import '../games/ludo/models/match_setup.dart';
import '../games/ludo/models/player_seat.dart';
import 'profile_models.dart';

/// One line of match history.
class MatchRecordTile extends StatelessWidget {
  const MatchRecordTile({super.key, required this.record});

  final MatchRecord record;

  @override
  Widget build(BuildContext context) {
    final l10n = context.strings;
    final theme = Theme.of(context);
    final color =
        LudoPalette.seat(LudoColor.fromName(record.color, LudoColor.red));
    final title = record.won
        ? l10n.resultWon
        : l10n.resultPlace(l10n.placement(record.placement));
    final subtitle = MatchMode.fromName(record.mode) == MatchMode.computer
        ? l10n.vsComputers(record.computerCount,
            l10n.difficultyName(BotDifficulty.fromName(record.difficulty)))
        : l10n.passAndPlayPlayers(record.playerCount);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              record.won ? Icons.emoji_events_rounded : Icons.flag_rounded,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: theme.textTheme.titleSmall),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(formatDuration(Duration(seconds: record.durationSeconds)),
                  style: theme.textTheme.labelLarge),
              Text(
                formatDate(record.endedAt),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

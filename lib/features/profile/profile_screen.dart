import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/widgets/common.dart';
import '../achievements/achievements.dart';
import 'match_record_tile.dart';
import 'profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _editName(BuildContext context, ProfileController profile) async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => _NameDialog(initial: profile.displayName),
    );
    if (name != null) {
      profile.setDisplayName(name);
    }
  }

  Future<void> _resetStats(BuildContext context, ProfileController profile) async {
    final l10n = context.strings;
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.resetStatsTitle),
        content: Text(l10n.resetStatsBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(dialogContext).colorScheme.error),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.reset),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      profile.resetStats();
      messenger.showSnackBar(SnackBar(content: Text(l10n.statsReset)));
    }
  }

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
          final fastest = stats.fastestWinSeconds;
          final achievements = buildAchievements(stats, l10n);
          return ContentWidth(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              children: <Widget>[
                Row(
                  children: <Widget>[
                    PlayerAvatar(
                      name: profile.displayName,
                      color: LudoPalette.avatars[profile.avatarIndex],
                      size: 72,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(profile.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.headlineSmall),
                          const SizedBox(height: 2),
                          SelectableText(
                            '${l10n.playerId}: ${profile.playerId}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant),
                          ),
                          Text(
                            l10n.storedOnDevice,
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.editName,
                      icon: const Icon(Icons.edit_rounded),
                      onPressed: () => _editName(context, profile),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(l10n.avatarColor, style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    for (var i = 0; i < ProfileController.avatarCount; i++)
                      Semantics(
                        button: true,
                        selected: i == profile.avatarIndex,
                        label: '${l10n.avatarColor} ${i + 1}',
                        child: InkResponse(
                          radius: 26,
                          onTap: () => profile.setAvatar(i),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: LudoPalette.avatars[i],
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: i == profile.avatarIndex
                                    ? theme.colorScheme.onSurface
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                SectionTitle(l10n.statistics),
                Panel(
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                              child: StatTile(
                                  value: '${stats.matchesPlayed}',
                                  label: l10n.statPlayed)),
                          Expanded(
                              child: StatTile(
                                  value: '${stats.wins}', label: l10n.statWins)),
                          Expanded(
                              child: StatTile(
                                  value: '${(stats.winRate * 100).round()}%',
                                  label: l10n.statWinRate)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: <Widget>[
                          Expanded(
                              child: StatTile(
                                  value: '${stats.bestStreak}',
                                  label: l10n.statBestStreak)),
                          Expanded(
                              child: StatTile(
                                  value: '${stats.captures}',
                                  label: l10n.statCaptures)),
                          Expanded(
                              child: StatTile(
                                  value: fastest == null
                                      ? '–'
                                      : formatDuration(
                                          Duration(seconds: fastest)),
                                  label: l10n.statFastestWin)),
                        ],
                      ),
                    ],
                  ),
                ),
                SectionTitle(l10n.achievements),
                Panel(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    children: <Widget>[
                      for (final achievement in achievements)
                        _AchievementRow(achievement: achievement),
                    ],
                  ),
                ),
                SectionTitle(l10n.matchHistory),
                Panel(
                  padding: profile.history.isEmpty
                      ? const EdgeInsets.all(16)
                      : const EdgeInsets.symmetric(vertical: 4),
                  child: profile.history.isEmpty
                      ? Text(l10n.noMatchesYet,
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant))
                      : Column(
                          children: <Widget>[
                            for (final record in profile.history)
                              MatchRecordTile(record: record),
                          ],
                        ),
                ),
                SectionTitle(l10n.account),
                Panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(l10n.accountOfflineNote,
                          style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: <Widget>[
                          OutlinedButton.icon(
                            onPressed: () =>
                                Navigator.of(context).pushNamed(AppRoutes.settings),
                            icon: const Icon(Icons.settings_rounded),
                            label: Text(l10n.settings),
                          ),
                          OutlinedButton.icon(
                            onPressed: () =>
                                Navigator.of(context).pushNamed(AppRoutes.privacy),
                            icon: const Icon(Icons.privacy_tip_outlined),
                            label: Text(l10n.privacyAndTerms),
                          ),
                          TextButton.icon(
                            onPressed: profile.stats.matchesPlayed == 0 &&
                                    profile.history.isEmpty
                                ? null
                                : () => _resetStats(context, profile),
                            icon: const Icon(Icons.delete_outline_rounded),
                            label: Text(l10n.resetStats),
                            style: TextButton.styleFrom(
                                foregroundColor: theme.colorScheme.error),
                          ),
                        ],
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

class _AchievementRow extends StatelessWidget {
  const _AchievementRow({required this.achievement});

  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unlocked = achievement.unlocked;
    final accent = unlocked ? LudoPalette.yellow : theme.colorScheme.outline;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: unlocked ? 0.2 : 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              unlocked ? Icons.military_tech_rounded : Icons.lock_outline_rounded,
              color: accent,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(achievement.title, style: theme.textTheme.titleSmall),
                Text(
                  achievement.description,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                if (!unlocked && achievement.target > 1) ...<Widget>[
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: achievement.progress,
                      minHeight: 6,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${achievement.current.clamp(0, achievement.target)}/${achievement.target}',
            style: theme.textTheme.labelLarge,
          ),
        ],
      ),
    );
  }
}

class _NameDialog extends StatefulWidget {
  const _NameDialog({required this.initial});

  final String initial;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
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
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.strings;
    return AlertDialog(
      title: Text(l10n.editName),
      content: TextField(
        controller: _text,
        autofocus: true,
        maxLength: ProfileController.maxNameLength,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        decoration:
            InputDecoration(labelText: l10n.displayName, errorText: _error),
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

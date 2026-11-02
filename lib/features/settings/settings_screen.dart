import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/router.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/ludo_logo.dart';
import 'settings_controller.dart';

/// App version shown in About. Keep in step with `version:` in pubspec.yaml.
const String appVersion = '1.0.0';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.services.settings;
    return Scaffold(
      appBar: AppBar(title: Text(context.strings.settings)),
      body: SafeArea(
        top: false,
        child: ListenableBuilder(
          listenable: settings,
          builder: (context, _) {
            final l10n = settings.strings;
            final theme = Theme.of(context);
            return ContentWidth(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                children: <Widget>[
                  SectionTitle(l10n.soundAndFeel),
                  Panel(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      children: <Widget>[
                        SwitchListTile(
                          secondary: const Icon(Icons.volume_up_rounded),
                          title: Text(l10n.soundEffects),
                          value: settings.soundEffects,
                          onChanged: settings.setSoundEffects,
                        ),
                        SwitchListTile(
                          secondary: const Icon(Icons.vibration_rounded),
                          title: Text(l10n.vibration),
                          value: settings.vibration,
                          onChanged: settings.setVibration,
                        ),
                      ],
                    ),
                  ),
                  SectionTitle(l10n.display),
                  Panel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(l10n.theme, style: theme.textTheme.labelLarge),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<AppThemePreference>(
                            showSelectedIcon: false,
                            segments: <ButtonSegment<AppThemePreference>>[
                              ButtonSegment<AppThemePreference>(
                                  value: AppThemePreference.dark,
                                  label: Text(l10n.themeDark)),
                              ButtonSegment<AppThemePreference>(
                                  value: AppThemePreference.light,
                                  label: Text(l10n.themeLight)),
                              ButtonSegment<AppThemePreference>(
                                  value: AppThemePreference.system,
                                  label: Text(l10n.themeSystem)),
                            ],
                            selected: <AppThemePreference>{settings.theme},
                            onSelectionChanged: (value) =>
                                settings.setTheme(value.first),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          secondary: const Icon(Icons.motion_photos_off_rounded),
                          title: Text(l10n.reduceMotion),
                          subtitle: Text(l10n.reduceMotionHint),
                          value: settings.reduceMotion,
                          onChanged: settings.setReduceMotion,
                        ),
                      ],
                    ),
                  ),
                  SectionTitle(l10n.gameplay),
                  Panel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(l10n.gameSpeed, style: theme.textTheme.labelLarge),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<GameSpeed>(
                            showSelectedIcon: false,
                            segments: <ButtonSegment<GameSpeed>>[
                              ButtonSegment<GameSpeed>(
                                  value: GameSpeed.relaxed,
                                  label: Text(l10n.speedRelaxed)),
                              ButtonSegment<GameSpeed>(
                                  value: GameSpeed.normal,
                                  label: Text(l10n.speedNormal)),
                              ButtonSegment<GameSpeed>(
                                  value: GameSpeed.fast,
                                  label: Text(l10n.speedFast)),
                            ],
                            selected: <GameSpeed>{settings.speed},
                            onSelectionChanged: (value) =>
                                settings.setSpeed(value.first),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          secondary: const Icon(Icons.touch_app_rounded),
                          title: Text(l10n.autoMove),
                          value: settings.autoMoveSingleOption,
                          onChanged: settings.setAutoMoveSingleOption,
                        ),
                      ],
                    ),
                  ),
                  SectionTitle(l10n.languageLabel),
                  Panel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<AppLanguage>(
                            showSelectedIcon: false,
                            segments: const <ButtonSegment<AppLanguage>>[
                              ButtonSegment<AppLanguage>(
                                  value: AppLanguage.en, label: Text('English')),
                              ButtonSegment<AppLanguage>(
                                  value: AppLanguage.ne, label: Text('नेपाली')),
                            ],
                            selected: <AppLanguage>{settings.language},
                            onSelectionChanged: (value) =>
                                settings.setLanguage(value.first),
                          ),
                        ),
                        if (settings.language == AppLanguage.ne) ...<Widget>[
                          const SizedBox(height: 8),
                          Text(
                            l10n.nepaliNote,
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SectionTitle(l10n.help),
                  Panel(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          leading: const Icon(Icons.help_outline_rounded),
                          title: Text(l10n.howToPlay),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => Navigator.of(context)
                              .pushNamed(AppRoutes.howToPlay),
                        ),
                        ListTile(
                          leading: const Icon(Icons.privacy_tip_outlined),
                          title: Text(l10n.privacyAndTerms),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () =>
                              Navigator.of(context).pushNamed(AppRoutes.privacy),
                        ),
                      ],
                    ),
                  ),
                  SectionTitle(l10n.about),
                  Panel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            const LudoLogoMark(size: 48),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const LudoWordmark(fontSize: 22),
                                const SizedBox(height: 4),
                                Text(l10n.version(appVersion),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(l10n.aboutBody, style: theme.textTheme.bodyMedium),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => showLicensePage(
                            context: context,
                            applicationName: 'LUDO',
                            applicationVersion: appVersion,
                          ),
                          child: Text(l10n.licenses),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

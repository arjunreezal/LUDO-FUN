import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../core/l10n/app_strings.dart';

/// Every game the platform plans to offer. Only [available] games can be
/// started; the rest are shown as in development, never as playable.
enum GameId {
  classicLudo(available: true, accent: LudoPalette.purple),
  snakeLudo(available: false, accent: LudoPalette.green),
  chess(available: false, accent: LudoPalette.blue),
  callBreak(available: false, accent: LudoPalette.red),
  teenPatti(available: false, accent: LudoPalette.yellow),
  marriage(available: false, accent: Color(0xFFFF8A5B));

  const GameId({required this.available, required this.accent});

  final bool available;
  final Color accent;

  String title(AppStrings l10n) => switch (this) {
        GameId.classicLudo => l10n.classicLudo,
        GameId.snakeLudo => l10n.snakeLudo,
        GameId.chess => l10n.chess,
        GameId.callBreak => l10n.callBreak,
        GameId.teenPatti => l10n.teenPatti,
        GameId.marriage => l10n.marriage,
      };

  String description(AppStrings l10n) => switch (this) {
        GameId.classicLudo => l10n.classicLudoDesc,
        GameId.snakeLudo => l10n.snakeLudoDesc,
        GameId.chess => l10n.chessDesc,
        GameId.callBreak => l10n.callBreakDesc,
        GameId.teenPatti => l10n.teenPattiDesc,
        GameId.marriage => l10n.marriageDesc,
      };

  /// Modes the game supports now (for available games) or will support.
  List<String> modes(AppStrings l10n) => switch (this) {
        GameId.classicLudo => <String>[
            l10n.vsComputerShort,
            l10n.modePassAndPlay,
            l10n.modeOnlineLater,
          ],
        GameId.callBreak || GameId.teenPatti || GameId.marriage => <String>[
            l10n.vsComputerShort,
            l10n.modeOnlineLater,
          ],
        GameId.snakeLudo || GameId.chess => <String>[
            l10n.vsComputerShort,
            l10n.modePassAndPlay,
            l10n.modeOnlineLater,
          ],
      };
}

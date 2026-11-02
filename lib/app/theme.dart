import 'package:flutter/material.dart';

import '../features/games/ludo/models/ludo_color.dart';

/// Brand colours.
abstract final class LudoPalette {
  static const Color navy = Color(0xFF101827);
  static const Color navyLow = Color(0xFF151F31);
  static const Color surface = Color(0xFF1B2638);
  static const Color surfaceHigh = Color(0xFF233049);
  static const Color surfaceHighest = Color(0xFF2C3A56);
  static const Color purple = Color(0xFF6C63FF);
  static const Color white = Color(0xFFF7F8FC);
  static const Color red = Color(0xFFE94F64);
  static const Color blue = Color(0xFF4388F5);
  static const Color green = Color(0xFF35B879);
  static const Color yellow = Color(0xFFFFC857);
  static const Color mutedDark = Color(0xFF94A0B8);
  static const Color mutedLight = Color(0xFF5B6680);

  /// Board-only neutrals (the board is always drawn light for contrast).
  static const Color boardSurface = Color(0xFFF7F8FC);
  static const Color boardLine = Color(0xFFD5DBE8);
  static const Color boardStar = Color(0xFFB4BDD0);
  static const Color boardInk = Color(0xFF101827);

  static Color seat(LudoColor color) => switch (color) {
        LudoColor.red => red,
        LudoColor.green => green,
        LudoColor.yellow => yellow,
        LudoColor.blue => blue,
      };

  /// Readable text/icon colour on top of a seat colour.
  static Color onSeat(LudoColor color) =>
      color == LudoColor.yellow ? navy : white;

  /// Avatar background colours, chosen in the profile.
  static const List<Color> avatars = <Color>[
    purple,
    red,
    blue,
    green,
    yellow,
    Color(0xFFFF8A5B),
    Color(0xFF2EC4C4),
    Color(0xFFB574F2),
  ];
}

abstract final class LudoTheme {
  static ThemeData dark() => _build(const ColorScheme(
        brightness: Brightness.dark,
        primary: LudoPalette.purple,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFF2E2A6B),
        onPrimaryContainer: Color(0xFFDCD9FF),
        secondary: LudoPalette.yellow,
        onSecondary: LudoPalette.navy,
        tertiary: LudoPalette.green,
        onTertiary: LudoPalette.navy,
        error: LudoPalette.red,
        onError: Colors.white,
        surface: LudoPalette.navy,
        onSurface: LudoPalette.white,
        surfaceContainerLowest: Color(0xFF0C1320),
        surfaceContainerLow: LudoPalette.navyLow,
        surfaceContainer: LudoPalette.surface,
        surfaceContainerHigh: LudoPalette.surfaceHigh,
        surfaceContainerHighest: LudoPalette.surfaceHighest,
        onSurfaceVariant: LudoPalette.mutedDark,
        outline: Color(0xFF4A5874),
        outlineVariant: Color(0xFF2A3650),
      ));

  static ThemeData light() => _build(const ColorScheme(
        brightness: Brightness.light,
        primary: Color(0xFF5A50F0),
        onPrimary: Colors.white,
        primaryContainer: Color(0xFFE3E1FF),
        onPrimaryContainer: Color(0xFF1E1863),
        secondary: Color(0xFFB7850F),
        onSecondary: Colors.white,
        tertiary: Color(0xFF1E8A57),
        onTertiary: Colors.white,
        error: Color(0xFFC9334A),
        onError: Colors.white,
        surface: LudoPalette.white,
        onSurface: LudoPalette.navy,
        surfaceContainerLowest: Colors.white,
        surfaceContainerLow: Color(0xFFF0F2F8),
        surfaceContainer: Color(0xFFE9ECF4),
        surfaceContainerHigh: Color(0xFFE1E5EF),
        surfaceContainerHighest: Color(0xFFD8DDE9),
        onSurfaceVariant: LudoPalette.mutedLight,
        outline: Color(0xFF9AA4BA),
        outlineVariant: Color(0xFFD3D9E5),
      ));

  static ThemeData _build(ColorScheme scheme) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: scheme.brightness,
    );
    final text = base.textTheme
        .copyWith(
          displaySmall: base.textTheme.displaySmall
              ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -1),
          headlineMedium: base.textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.6),
          headlineSmall: base.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.4),
          titleLarge: base.textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.2),
          titleMedium:
              base.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          titleSmall:
              base.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          labelLarge:
              base.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          bodyLarge: base.textTheme.bodyLarge?.copyWith(height: 1.45),
          bodyMedium: base.textTheme.bodyMedium?.copyWith(height: 1.45),
        )
        .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);

    final buttonShape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));
    const buttonText = TextStyle(fontSize: 16, fontWeight: FontWeight.w700);

    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      textTheme: text,
      cardTheme: CardThemeData(
        color: scheme.surfaceContainer,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: buttonShape,
          side: BorderSide(color: scheme.outline),
          foregroundColor: scheme.onSurface,
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        indicatorColor: scheme.primary.withValues(alpha: 0.22),
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainer,
        showDragHandle: true,
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      dividerTheme:
          DividerThemeData(color: scheme.outlineVariant, thickness: 1, space: 1),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

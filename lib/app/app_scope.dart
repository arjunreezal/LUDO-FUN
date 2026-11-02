import 'package:flutter/widgets.dart';

import '../core/l10n/app_strings.dart';
import 'app_services.dart';

/// Makes [AppServices] available to the widget tree. Rebuilds dependents
/// when the interface language changes.
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.services,
    required this.language,
    required super.child,
  });

  final AppServices services;
  final AppLanguage language;

  static AppScope _scopeOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No AppScope found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      oldWidget.services != services || oldWidget.language != language;
}

extension AppContext on BuildContext {
  AppServices get services => AppScope._scopeOf(this).services;
  AppStrings get strings => AppStrings(AppScope._scopeOf(this).language);

  /// True when the player or the platform asked for less motion.
  bool get reduceMotion =>
      services.settings.reduceMotion || MediaQuery.disableAnimationsOf(this);
}

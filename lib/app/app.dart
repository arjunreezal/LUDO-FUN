import 'package:flutter/material.dart';

import 'app_scope.dart';
import 'app_services.dart';
import 'router.dart';
import 'theme.dart';

class LudoApp extends StatefulWidget {
  const LudoApp({super.key, this.services});

  /// Injected in tests; created automatically otherwise.
  final AppServices? services;

  @override
  State<LudoApp> createState() => _LudoAppState();
}

class _LudoAppState extends State<LudoApp> {
  late final AppServices _services = widget.services ?? AppServices();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _services.settings,
      builder: (context, _) {
        final settings = _services.settings;
        return AppScope(
          services: _services,
          language: settings.language,
          child: MaterialApp(
            title: 'LUDO',
            debugShowCheckedModeBanner: false,
            theme: LudoTheme.light(),
            darkTheme: LudoTheme.dark(),
            themeMode: settings.themeMode,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRouter.onGenerateRoute,
            onUnknownRoute: AppRouter.onUnknownRoute,
          ),
        );
      },
    );
  }
}

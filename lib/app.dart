import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'config/app_router.dart';
import 'core/config/bergerie_config.dart';
import 'core/theme/app_theme.dart';

class SetsiApp extends StatelessWidget {
  const SetsiApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Configuration actuelle de référence.
    // Elle sera ensuite chargée dynamiquement selon la bergerie
    // connectée / le build personnalisé.
    final bergerieConfig = BergerieConfig.defaut();

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: bergerieConfig.nomApplication,
      theme: AppTheme.lightThemeForBergerie(bergerieConfig),
      routerConfig: appRouter,

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('en', 'US'),
      ],

      locale: const Locale('fr', 'FR'),
    );
  }
}

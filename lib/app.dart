import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'config/app_router.dart';
import 'core/config/current_bergerie_config.dart';
import 'core/theme/app_theme.dart';

class SetsiApp extends StatelessWidget {
  const SetsiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CurrentBergerieConfig.instance,
      builder: (context, _) {
        // La configuration est chargée au démarrage selon le bergerieId
        // de l'utilisateur connecté. Le même écouteur permet aussi de
        // reconstruire immédiatement le thème après une personnalisation.
        final bergerieConfig = CurrentBergerieConfig.instance.config;

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
      },
    );
  }
}
